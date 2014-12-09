//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A testable hypothesis about a subject.
public protocol HypothesisType : Printable {
	typealias Subject

	/// Test whether the hypothesis is valid for a given subject.
	func test(subject: Subject) -> Bool
}


/// Inverts a hypothesis.
public struct Not<H : HypothesisType> : HypothesisType {
	public let hypothesis: H

	public var description: String { return "not \(hypothesis.description)" }

	public init(_ hypothesis: H) {
		self.hypothesis = hypothesis
	}

	public func test(subject: H.Subject) -> Bool {
		return !hypothesis.test(subject)
	}
}


/// A hypothesis that the subject equals the object.
public struct Equal<T : Equatable> : HypothesisType {
	public let object: T

	public var description: String { return "equal \(object)" }

	public init(_ object: T) {
		self.object = object
	}

	public func test(subject: T) -> Bool {
		return subject == object
	}
}
