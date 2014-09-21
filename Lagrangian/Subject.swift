//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// The subject of a test.
public final class Subject<T> {
	private var thunk: (() -> T)?

	lazy var value: T = {
		let v = self.thunk!()
		self.thunk = nil
		return v
	}()

	init(_ value: @autoclosure () -> T) {
		thunk = value
	}

	public func when<U>(body: inout T -> U) -> Subject<U> {
		return Subject<U>(body(&value))
	}

	public func expect<L : BooleanType>(body: Subject<T> -> L) -> Subject<T> {
		return self
	}
}


/// Printable conformance.
extension Subject : Printable {
	public var description: String {
		return toString(value)
	}
}


public func given<T>(value: @autoclosure () -> T) -> Subject<T> {
	return Subject(value)
}
