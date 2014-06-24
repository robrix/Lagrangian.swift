//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A testable hypothesis about a subject.
protocol Hypothesis : Printable {
	typealias SubjectType
	
	/// Test whether the hypothesis is valid for a given subject.
	func test(subject: SubjectType) -> Bool
}


/// Inverts a hypothesis.
struct Not<T, H : Hypothesis where H.SubjectType == T> : Hypothesis {
	let hypothesis: H
	
	var description: String { return "not \(hypothesis.description)" }
	
	func test(subject: T) -> Bool {
		return hypothesis.test(subject)
	}
}


/// A hypothesis that the subject equals the object.
struct Equal<T : Equatable> : Hypothesis {
	let object: T
	
	var description: String { return "equal \(object)" }
	
	func test(subject: T) -> Bool {
		return subject == object
	}
}
