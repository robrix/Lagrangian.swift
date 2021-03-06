//  Copyright (c) 2014 Rob Rix. All rights reserved.

import XCTest
import Lagrangian

class LagrangianTests: XCTestCase {
    func testPrintable() {
		let expectations = [
			(%"string" == "string", "string should equal string"),
			(%2 == 23, "2 should equal 23"),
//			(%[1] == [1], "[1] should equal [1]"),
		]
		for (expectation, description) in expectations {
			XCTAssertEqual(expectation.description, description, "")
		}
    }
}
