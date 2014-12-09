//  Copyright (c) 2014 Rob Rix. All rights reserved.

public struct Image {
	public init() {
		self.init(handle: dlopen(nil, RTLD_LOCAL | RTLD_LAZY))
	}

	public init?(path: String) {
		self.init(handle: dlopen(path, RTLD_LOCAL | RTLD_LAZY))
	}


	public subscript (name: String) -> Symbol {
		return Symbol(name: name, handle: dlsym(handle, name))
	}


	// MARK: Private

	private init?(handle: UnsafeMutablePointer<Void>) {
		self.handle = handle
		if handle == nil { return nil }
	}

	private let handle: UnsafeMutablePointer<Void>
}

public struct Header: DebugPrintable {
	public let path: String

	public static var loadedHeaders: [Header] {
		return map(0..<Int(_dyld_image_count())) {
			let path = String.fromCString(_dyld_get_image_name(UInt32($0)))!
			return Header(path: path, handle: unsafeBitCast(_dyld_get_image_header(UInt32($0)), UnsafePointer<mach_header_64>.self))
		}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return path
	}


	// MARK: Private

	private init(path: String, handle: UnsafePointer<mach_header_64>) {
		self.path = path
		self.handle = handle
	}

	private var info: Dl_info? {
		var info: Dl_info = Dl_info(dli_fname: nil, dli_fbase: nil, dli_sname: nil, dli_saddr: nil)
		if dladdr(handle, &info) == 0 { return nil }
		return info
	}

	private var commands: [UnsafePointer<load_command>] {
		let next: UnsafePointer<load_command> -> UnsafePointer<load_command> = {
			UnsafePointer<load_command>(UnsafePointer<Int8>($0).advancedBy(Int($0.memory.cmdsize)))
		}
		let initial = UnsafePointer<load_command>(self.handle.successor())
		return reduce(1..<Int(self.handle.memory.ncmds), (initial, [initial])) { into, _ in
			(next(into.0), into.1 + [next(into.0)])
		}.1
	}

	public var symbols: [String] {
		var text: UnsafePointer<segment_command_64>?
		var linkedit: UnsafePointer<segment_command_64>?
		var symtab: UnsafePointer<symtab_command>?

		iterate: for each in self.commands {
			switch Int32(each.memory.cmd) {
			case LC_SEGMENT_64:
				let segment = UnsafePointer<segment_command_64>(each)
				let c = segment.memory.segname
				let name = [c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7, c.8, c.9, c.10, c.11, c.12, c.13, c.14, c.15].withUnsafeBufferPointer { String.fromCString($0.baseAddress) }

				if name == SEG_TEXT {
					text = segment
				} else if name == SEG_LINKEDIT {
					linkedit = segment
				}

			case LC_SYMTAB:
				let symtab = UnsafePointer<symtab_command>(each)

			default:
				if text != nil && linkedit != nil && symtab != nil { break iterate }
			}
		}

		if let (text, (linkedit, symtab)) = text <*> linkedit <*> symtab {
			let base = UnsafePointer<Int8>(self.handle)
			let fileSlide = Int(linkedit.memory.vmaddr) - Int(text.memory.vmaddr) - Int(linkedit.memory.fileoff)
			let strings = UnsafePointer<UnsafePointer<CChar>>(base.advancedBy(fileSlide))
			var sym = UnsafePointer<nlist_64>(base.advancedBy(Int(symtab.memory.symoff) + fileSlide))

			let stringify: UnsafePointer<nlist_64> -> String? = {
				(Int32(sym.memory.n_type) & N_EXT != N_EXT) ?
					String.fromCString(strings.advancedBy(Int(L3StringIndexOfSymbolTableEntry($0))).memory)
				:	nil
			}

			return reduce(0..<Int(symtab.memory.nsyms), (sym, [])) { (into: (UnsafePointer<nlist_64>, [String]), _) in
				(into.0.successor(), into.1 + (stringify(into.0).map { [$0] } ?? []))
			}.1
		}

		return []
	}

	private let handle: UnsafePointer<mach_header_64>
}


public struct Symbol {
	public init(name: String, handle: UnsafeMutablePointer<Void>) {
		self.name = name
		self.handle = handle
	}

	public let name: String


	// MARK: Private

	private let handle: UnsafeMutablePointer<Void>
}


infix operator <*> { associativity right }
func <*> <X, Y> (left: X?, right: Y?) -> (X, Y)? {
	if let left = left {
		if let right = right {
			return (left, right)
		}
	}
	return nil
}

private func find<S: SequenceType>(domain: S, predicate: S.Generator.Element -> Bool) -> S.Generator.Element? {
	for each in domain {
		if predicate(each) { return each }
	}
	return nil
}



// MARK: - Imports

import Darwin
import MachO
import MachO.nlist
