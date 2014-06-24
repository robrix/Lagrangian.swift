//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// An expectation is the combination of a subject & hypothesis.
struct Expectation<T, H : Hypothesis where H.SubjectType == T> {
	var _subject: Subject<T>
	let _hypothesis: H
	
	init(subject: Subject<T>, hypothesis: H) {
		_subject = subject
		_hypothesis = hypothesis
	}
}


extension Expectation : Printable {
	var description: String {
		return "\(_subject) should \(_hypothesis)"
	}
}


func == <T, H : Hypothesis where H.SubjectType == T> (a: Expectation<T, H>, b: Expectation<T, H>) -> Bool {
	return a.description == b.description
}

extension Expectation : Equatable {}


extension Expectation : Hashable {
	var hashValue: Int {
		return description.hashValue
	}
}


/// Constructs an \c Expectation that a \c Subject will equal some other value.
func == <T : Equatable> (subject: Subject<T>, object: T) -> Expectation<T, Equal<T>> {
	return Expectation(subject: subject, hypothesis: Equal(object: object))
}


/// Constructs an \c Expectation that a \c Subject will not equal some other value.
func != <T : Equatable> (subject: Subject<T>, object: T) -> Expectation<T, Not<T, Equal<T>>> {
	return Expectation(subject: subject, hypothesis: Not(hypothesis: Equal(object: object)))
}
