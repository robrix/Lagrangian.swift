//  Copyright (c) 2014 Rob Rix. All rights reserved.

let _expectationTest = suite("Expectation")

/// An expectation is the combination of a subject & hypothesis.
public struct Expectation<T, H : Hypothesis where H.SubjectType == T> {
	private var subject: Subject<T>
	private let hypothesis: H

	public init(subject: Subject<T>, hypothesis: H) {
		self.subject = subject
		self.hypothesis = hypothesis
	}
}


extension Expectation : Printable {
	public var description: String {
		return "\(subject) should \(hypothesis)"
	}
}


public func == <T, H : Hypothesis where H.SubjectType == T> (a: Expectation<T, H>, b: Expectation<T, H>) -> Bool {
	return a.description == b.description
}

extension Expectation : Equatable {}


extension Expectation : Hashable {
	public var hashValue: Int {
		return description.hashValue
	}
}

/// fixme: file a radar about gensyms
/// fixme: file a radar about metaprogramming to define constants
/// fixme: file a radar about strict globals/constructor funcs
let _t0 =
	given([Int]())
	.when { x in x.append(1) ; return x }
	.expect { (x: Subject<[Int]>) in x.value.count == x.value.count + 1 }
//	.expect { x, y in x[x.count - 1] == y }
//	%2 == 23
//	%"" == ""



/// Constructs an \c Expectation that a \c Subject will equal some other value.
public func == <T : Equatable> (subject: Subject<T>, object: T) -> Expectation<T, Equal<T>> {
	return Expectation(subject: subject, hypothesis: Equal(object: object))
}


/// Constructs an \c Expectation that a \c Subject will not equal some other value.
public func != <T : Equatable> (subject: Subject<T>, object: T) -> Expectation<T, Not<T, Equal<T>>> {
	return Expectation(subject: subject, hypothesis: Not(hypothesis: Equal(object: object)))
}
