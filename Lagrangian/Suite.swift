//  Copyright (c) 2014 Rob Rix. All rights reserved.

func test(body: () -> ()) -> Test {
	return test(Suite.Registry.defaultSuite, body)
}

func test(suiteName: String, body: () -> ()) -> Test {
	var suite = Suite.Registry.get(suiteName)!
	return test(suite, body)
}

func test(suite: Suite, body: () -> ()) -> Test {
	let test = Test(body: body)
	suite.tests.append(test)
	return test
}


struct Test {
	let body: () -> ()
	
	// fixme: file a radar about the lack of postfix function call syntax overloading
	func perform() {
		body()
	}
}

class Suite {
	struct Registry {
		// fixme: file a radar about the distinction between static & class for type properties
		static var defaultSuite = Suite(name: "")
		static var _suites = [defaultSuite.name: defaultSuite]
		
		// fixme: file a radar about the lack of static subscripts
		static func add(suite: Suite) {
			_suites[suite.name] = suite
		}
		
		static func get(name: String) -> Suite? {
			return _suites[name]
		}
	}
	
	let name: String
	var tests = Test[]()
	
	init(name: String) {
		self.name = name
	}
	
	func perform() {
		for test in tests {
			test.perform()
		}
	}
}


func suite(string: String) -> (Void -> Void) -> Test {
	let suite = Suite(name: string)
	Suite.Registry.add(suite)
	return { body in test(suite, body) }
}
