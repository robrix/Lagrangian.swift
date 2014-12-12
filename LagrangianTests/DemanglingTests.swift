//  Copyright (c) 2014 Rob Rix. All rights reserved.

import Lagrangian
import XCTest

final class DemanglingTests: XCTestCase {
	func testParsesIdentifiers() {
		assertEqual(identifier("10Lagrangian")?.0, "Lagrangian")
	}


	// MARK: Assertions

	func assertEqual<T: Equatable>(actual: @autoclosure () -> T?, _ expected: @autoclosure () -> T?, _ file: String = __FILE__, line: UInt = __LINE__) {
		let (e, a) = (expected(), actual())
		if e != a { XCTFail("\(a) is not equal to \(e)") }
	}
}
