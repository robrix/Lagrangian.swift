//  Copyright (c) 2014 Rob Rix. All rights reserved.

import Lagrangian
import XCTest

final class DemanglingTests: XCTestCase {
	func testParsesIdentifiers() {
		assertEqual(parseIdentifier("10Lagrangian")?.0, "Lagrangian")
	}

	func testParsesMangledNames() {
		let Lagrangian = find(Header.loadedHeaders) {
			($0.path as NSString).lastPathComponent == "Prelude"
		}
		for symbol in Lagrangian?.symbols ?? [] {
			if !startsWith(symbol.name, "_T") { continue }
			let parsed = mangled(symbol.name)
			if let result = assertNotNil(parsed?.0) {
//				println("\(symbol.name) → \(result)")
				if let rest = assertNil(parsed?.1) {
					println(symbol.name)
				}
			} else {
				println(symbol.name)
			}
		}
	}


	// MARK: Assertions

	func assertEqual<T: Equatable>(actual: @autoclosure () -> T?, _ expected: @autoclosure () -> T?, file: String = __FILE__, line: UInt = __LINE__) -> T? {
		let (e, a) = (expected(), actual())
		return e != a ? (failure("\(a) is not equal to \(e)", file: file, line: line) ?? a) : nil
	}

	func assertNotEqual<T: Equatable>(actual: @autoclosure () -> T?, _ unexpected: @autoclosure () -> T?, file: String = __FILE__, line: UInt = __LINE__) {
		let (e, a) = (unexpected(), actual())
		if e == a { XCTFail("\(a) is equal to \(e)", file: file, line: line) }
	}

	func assertNotNil<T>(actual: @autoclosure () -> T?, file: String = __FILE__, line: UInt = __LINE__) -> T? {
		return actual().map {
			$0
		} ?? failure("unexpected nil", file: file, line: line)
	}

	func assertNil<T>(actual: @autoclosure () -> T?, file: String = __FILE__, line: UInt = __LINE__) -> T? {
		let x = actual()
		return x.map { value in
			self.failure("expected nil, got \(value)", file: file, line: line)
		} ?? nil
	}

	func failure(message: String, file: String = __FILE__, line: UInt = __LINE__) -> Bool {
		XCTFail(message, file: file, line: line)
		return false
	}

	func failure<T>(message: String, file: String = __FILE__, line: UInt = __LINE__) -> T? {
		XCTFail(message, file: file, line: line)
		return nil
	}
}
