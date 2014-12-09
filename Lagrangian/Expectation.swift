//  Copyright (c) 2014 Rob Rix. All rights reserved.

let _expectationTest = suite("Expectation")

/// An expectation is the combination of a subject & hypothesis.
public final class Expectation<H : HypothesisType> : Printable, Hashable {
	private var subject: Subject<H.Subject>
	private let hypothesis: H

	public init(_ subject: Subject<H.Subject>, _ hypothesis: H) {
		self.subject = subject
		self.hypothesis = hypothesis
	}

	public var description: String {
		return "\(subject) should \(hypothesis)"
	}

	public var hashValue: Int {
		return description.hashValue
	}
}

public func == <H : HypothesisType> (a: Expectation<H>, b: Expectation<H>) -> Bool {
	return a.description == b.description
}

/// fixme: file a radar about gensyms
/// fixme: file a radar about metaprogramming to define constants
/// fixme: file a radar about strict globals/constructor funcs
//private let _t0 =
//	given([Int]())
//	.when { x in x.append(1) ; return x }
//	.expect { (x: Subject<[Int]>) in
////		x.map { $0.count } == 1
//		x.value.count == 1
//	}
//	.expect { x, y in x[x.count - 1] == y }


/// Constructs an \c Expectation that a \c Subject will equal some other value.
public func == <T : Equatable> (subject: Subject<T>, object: T) -> Expectation<Equal<T>> {
	return Expectation(subject, Equal(object))
}

/// Constructs an \c Expectation that a \c Subject will not equal some other value.
public func != <T : Equatable> (subject: Subject<T>, object: T) -> Expectation<Not<Equal<T>>> {
	return Expectation(subject, Not(Equal(object)))
}


/// Negates a hypothesis.
public prefix func ! <H : HypothesisType> (hypothesis: H) -> Not<H> {
	return Not(hypothesis)
}
