//  Copyright (c) 2014 Rob Rix. All rights reserved.

public struct Image {
	public init() {
		self.init(handle: dlopen(nil, RTLD_LOCAL | RTLD_LAZY))
	}

	public init?(path: String) {
		self.init(handle: dlopen(path, RTLD_LOCAL | RTLD_LAZY))
	}


	public subscript (name: String) -> Symbol? {
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
	public var path: String {
		return String.fromCString(_dyld_get_image_name(index))!
	}

	public let index: UInt32

	public static var loadedHeaders: [Header] {
		return map(0..<Int(_dyld_image_count())) { Header(index: UInt32($0)) }
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return path
	}


	// MARK: Private

	private init(index: UInt32) {
		self.index = index
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
		let initial = UnsafePointer<load_command>(handle.successor())
		return reduce(1..<Int(handle.memory.ncmds), (initial, [initial])) { into, _ in
			(next(into.0), into.1 + [next(into.0)])
		}.1
	}

	public var symbols: [String] {
		var text: UnsafePointer<segment_command_64>?
		var linkedit: UnsafePointer<segment_command_64>?
		var symtab: UnsafePointer<symtab_command>?

		iterate: for each in commands {
			switch each.memory.cmd {
			case UInt32(LC_SEGMENT_64):
				let segment = UnsafePointer<segment_command_64>(each)
				if segment.memory.name == SEG_TEXT {
					text = segment
				} else if segment.memory.name == SEG_LINKEDIT {
					linkedit = segment
				}

			case UInt32(LC_SYMTAB):
				symtab = UnsafePointer<symtab_command>(each)

			default:
				if text != nil && linkedit != nil && symtab != nil { break iterate }
			}
		}

		if let (text, (linkedit, symtab)) = text <*> linkedit <*> symtab {
			let base = UnsafePointer<Int8>(handle)
			let fileSlide = 0

			let sym = UnsafePointer<nlist_64>(base.advancedBy(Int(symtab.memory.symoff) + fileSlide))

			let stroff = Int(symtab.memory.stroff)

			let stringAtOffset: Int -> String = {
				String.fromCString(UnsafePointer<CChar>(base.advancedBy($0 + stroff + fileSlide)))!
			}

			let stringify: UnsafePointer<nlist_64> -> String? = { s in
				(((Int32(s.memory.n_type) & N_EXT) != N_EXT) || (s.memory.n_value == 0)) ?
					nil
				:	stringAtOffset(Int(L3StringIndexOfSymbolTableEntry(s)))
			}

			return reduce(0..<Int(symtab.memory.nsyms), (sym, [])) { (into: (UnsafePointer<nlist_64>, [String]), _) in
				(into.0.successor(), into.1 + (stringify(into.0).map { [$0] } ?? []))
			}.1
		}

		return []
	}

	private var image: Image? {
		return Image(path: self.path)
	}

	private var handle: UnsafePointer<mach_header_64> {
		return unsafeBitCast(_dyld_get_image_header(index), UnsafePointer<mach_header_64>.self)
	}

	private var vmaddrSlide: Int {
		return _dyld_get_image_vmaddr_slide(index)
	}
}


public struct Symbol: DebugPrintable {
	public init?(name: String, handle: UnsafeMutablePointer<Void>) {
		self.name = name
		self.handle = handle
		if handle == nil { return nil }
	}

	public let name: String


	// MARK: DebugPrintable

	public var debugDescription: String {
		return "\(name) @ \(handle)"
	}


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

extension symtab_command: DebugPrintable {
	public var debugDescription: String {
		return "(cmd: \(cmd), cmdsize: \(cmdsize), symoff: \(symoff), nsyms: \(nsyms), stroff: \(stroff), strsize: \(strsize))"
	}
}

extension mach_header_64: DebugPrintable {
	public var debugDescription: String {
		return "(magic: \(magic), cputype: \(cputype), cpusubtype: \(cpusubtype), filetype: \(filetype), ncmds: \(ncmds), sizeofcmds: \(sizeofcmds), flags: \(flags), reserved: \(reserved))"
	}
}

extension segment_command_64: DebugPrintable {
	private var name: String {
		let c = segname
		return [c.0, c.1, c.2, c.3, c.4, c.5, c.6, c.7, c.8, c.9, c.10, c.11, c.12, c.13, c.14, c.15].withUnsafeBufferPointer { String.fromCString($0.baseAddress) }!
	}
	public var debugDescription: String {
		return "(cmd: \(cmd), cmdsize: \(cmdsize), segname: \(name), vmaddr: \(vmaddr), vmsize: \(vmsize), fileoff: \(fileoff), filesize: \(filesize), maxprot: \(maxprot), initprot: \(initprot), nsects: \(nsects), flags: \(flags))"
	}
}


// MARK: - Imports

import Darwin
import MachO
import MachO.nlist
