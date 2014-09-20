//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// The subject of a test.
final class Subject<T> {
	var _thunk: () -> T
	
	lazy var value: T = { return self._thunk() }()
	
	init(_ value: @autoclosure () -> T) {
		_thunk = value
	}
}


/// Printable conformance.
extension Subject : Printable {
	var description: String {
		return toString(value)
	}
}
