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
}


/// Printable conformance.
extension Subject : Printable {
	public var description: String {
		return toString(value)
	}
}


public func given<T>(value: @autoclosure () -> T) -> State<T> {
	return State(value)
}

public final class State<T> {
	private let thunk: () -> T
	public lazy var value: T = { return self.thunk() }()

	public init(_ f: @autoclosure () -> T) {
		thunk = f
	}

	public func when<U>(body: T -> U) -> State<U> {
		return State<U>(body(value))
	}

	public func expect<U>(body: Subject<T> -> U) {

	}
}
