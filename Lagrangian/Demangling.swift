//  Copyright (c) 2014 Rob Rix. All rights reserved.

// MARK: - Parsers

let marker = ignore("_T")

let count = (%("0"..."9"))+ --> { strtol("".join($0), nil, 10) }

let many: Int -> Parser<String>.Function = { n in any * n --> { "".join($0) } }

public let identifier: Parser<String>.Function = { count($0).map { many($0)($1) } ?? nil }

prefix func % (strings: [String]) -> Parser<String>.Function {
	return { input in
		find(strings, { startsWith(input, $0) }).map {
			($0, input[advance(input.startIndex, countElements($0), input.endIndex)..<input.endIndex])
		}
	}
}

enum Type {
	case Function()
	case Enum()
	case Struct()
	case Class()
	case Tuple([Type])
}

let types: [String: (Parser<Type>.Function)] = [
	"F": identifier* --> const(Type.Function()),
	"T": parseType* ++ ignore("_") --> { Type.Tuple($0) },
]

let typeParameters = ignore(%"U" ++ (%"_")+)

let symbols: [String: (Parser<String>.Function)] = [
	"F": identifier+ --> { ".".join($0) },
]

// fixme: this belongs in Madness probably
func never<T>() -> Parser<T>.Function {
	return const(nil)
}

/// fixme: this belongs in Madness probably
infix operator >>= {}
func >>= <T, U> (left: Parser<T>.Function, right: T -> (Parser<U>.Function)?) -> Parser<U>.Function {
	return {
		left($0).map { input, rest in
			right(input).map {
				$0(rest)
			} ?? nil
		} ?? nil
	}
}

let parseType: Parser<Type>.Function = annotation >>= {
	types[$0] != nil ? types[$0]! : never()
}

let parseSymbol: Parser<String>.Function = annotation >>= {
	symbols[$0] != nil ? symbols[$0]! : never()
}

let annotation = %["a", "C", "d", "E", "F", "g", "L", "m", "M", "n", "o", "O", "p", "P", "S", "T", "U", "v", "V", "W"]

public let mangled = marker ++ ignore(annotation) ++ identifier+ ++ parseType --> { identifier, type in ".".join(identifier) }


public func find<S: SequenceType>(domain: S, predicate: S.Generator.Element -> Bool) -> S.Generator.Element? {
	for each in domain {
		if predicate(each) { return each }
	}
	return nil
}


// MARK: - Imports

import Madness
import Prelude
