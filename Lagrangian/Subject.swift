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


	func map<U>(f: T -> U) -> Subject<U> {
		return Subject<U>(f(value))
	}


	public func when<U>(body: inout T -> U) -> Subject<U> {
		return Subject<U>(body(&value))
	}

	public func expect<H : HypothesisType>(body: Subject<T> -> Expectation<H>) -> Expectation<H> {
		return body(self)
	}

	public func expect<H : HypothesisType>(body: (Subject<T>, Subject<T>) -> H) -> Subject<T> {
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
