//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A testable hypothesis about a subject.
public protocol Hypothesis : Printable {
	typealias SubjectType

	/// Test whether the hypothesis is valid for a given subject.
	func test(subject: SubjectType) -> Bool
}


/// Inverts a hypothesis.
public struct Not<T, H : Hypothesis where H.SubjectType == T> : Hypothesis {
	public let hypothesis: H

	public var description: String { return "not \(hypothesis.description)" }

	public func test(subject: T) -> Bool {
		return hypothesis.test(subject)
	}
}


/// A hypothesis that the subject equals the object.
public struct Equal<T : Equatable> : Hypothesis {
	public let object: T

	public var description: String { return "equal \(object)" }

	public func test(subject: T) -> Bool {
		return subject == object
	}
}
