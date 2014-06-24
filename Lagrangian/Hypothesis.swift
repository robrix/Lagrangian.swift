//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A testable hypothesis about a subject.
protocol Hypothesis {
	typealias SubjectType
	
	func test(subject: SubjectType)
}


/// Inverts a hypothesis.
struct Not<T, H : Hypothesis where H.SubjectType == T> : Hypothesis {
	let hypothesis: H
	
	func test(subject: T) {
		hypothesis.test(subject)
	}
}


/// A hypothesis that the subject equals the object.
struct Equal<T : Equatable> : Hypothesis {
	let object: T
	
	func test(subject: T) {
		subject == object
	}
}
