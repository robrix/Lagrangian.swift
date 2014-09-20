//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// The subject of a test.
final class Subject<T> {
	private var thunk: (() -> T)?
	
	lazy var value: T = {
		let v = self.thunk!()
		self.thunk = nil
		return v
	}()
	
	init(_ value: @autoclosure () -> T) {
		thunk = value
	}
}


/// Printable conformance.
extension Subject : Printable {
	var description: String {
		return toString(value)
	}
}
