//  Copyright (c) 2014 Rob Rix. All rights reserved.

// MARK: - Parsers

let marker = ignore("_T")

let parseCount: Parser<Int>.Function = (%("0"..."9"))+ --> { strtol("".join($0), nil, 10) }

func many<T>(parser: Parser<T>.Function, n: Int) -> Parser<[T]>.Function {
	return parser * n
}

public let parseIdentifier: Parser<String>.Function = parseCount >>= { many(any, $0) --> { "".join($0) } }

prefix func % (strings: [String]) -> Parser<String>.Function {
	return { input in
		find(strings, { startsWith(input, $0) }).map {
			($0, input[advance(input.startIndex, countElements($0), input.endIndex)..<input.endIndex])
		}
	}
}

let fixityTable = [
	"op": "prefix",
	"oP": "postfix",
	"oi": "infix",
]
let parseFixity: Parser<String>.Function = %map(fixityTable.keys, id) --> { fixityTable[$0]! }

struct DemangledSymbol: Printable {
	let module: Module
	let identifier: String
	let type: Type

	var description: String {
		return "\(module).\(identifier): \(type)"
	}
}

struct Module: Printable {
	let name: String

	static func parse(input: String) -> (Module, String)? {
		return (parseIdentifier --> { Module(name: $0) })(input)
	}

	var description: String {
		return name
	}
}

let parseMangledSymbol: Parser<DemangledSymbol>.Function = (parseAnnotation >>= {
	Module.parse ++ (symbolTable[$0] != nil ? symbolTable[$0]! : never()) ++ parseType
}) --> {
	DemangledSymbol(module: $0, identifier: $1.0, type: $1.1)
}

let operatorTable = [
	"p": "+",
	"g": ">",
	"l": "<"
]
let parseOperatorName: Parser<String>.Function = (%map(operatorTable.keys, id) --> { operatorTable[$0]! })+ --> { "".join($0) }
let parseOperator: Parser<String>.Function = parseFixity ++ parseOperatorName --> { "\($0) \($1)" }
let parseFunctionSymbol: Parser<String>.Function = parseOperator | parseIdentifier

let symbolTable: [String: (Parser<String>.Function)] = [
	"F": parseFunctionSymbol,
]

let alphabet = { (string: $0, count: countElements($0)) }("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
let nth: ((string: String, count: Int), Int) -> String = {
	String($0.string[advance($0.string.startIndex, $1, $0.string.endIndex)])
}

func typeParameterName(n: Int) -> String {
	let wrapped = n % alphabet.count
	let letter = nth(alphabet, wrapped)
	let laps = (n - wrapped) / alphabet.count
	return reduce(0..<laps, letter) { into, _ in into + letter }
}

enum Type: Printable {
	case Function(Box<Type>, Box<Type>)
	case Enum()
	case Struct()
	case Class()
	case Tuple([Type])
	case Parameter(Int)
	case Parameterized(Int, Box<Type>)

	var description: String {
		switch self {
		case let .Function(argumentType, returnType):
			return argumentType.value.needsParentheses ?
				"(\(argumentType)) -> \(returnType)"
			:	"\(argumentType) -> \(returnType)"
		case let .Tuple(types):
			return types.count > 1 ?
				"(" + ", ".join(types.map(toString)) + ")"
			:	"".join(types.map(toString))
		case let .Parameter(index):
			return typeParameterName(index)
		case let .Parameterized(count, type):
			let parameters = map(0..<count, typeParameterName)
			return "<" + ", ".join(parameters) + "> \(type)"
		default:
			return ""
		}
	}

	var needsParentheses: Bool {
		switch self {
		case .Function:
			return true
		default:
			return false
		}
	}
}

let parseFunctionType: Parser<Type>.Function = parseType ++ parseType --> { Type.Function(Box($0), Box($1)) }
let parseTupleType: Parser<Type>.Function = parseType* ++ ignore("_") --> { Type.Tuple($0) }
let parseOptionalDigit: Parser<Int>.Function = ((%("0"..."9"))+ --> { strtol("".join($0), nil, 10) + 1 }) * (0..<1) --> { $0.last ?? 0 }
let parseTypeParameter: Parser<Type>.Function = parseOptionalDigit ++ ignore("_") --> { Type.Parameter($0) }

let types: [String: (Parser<Type>.Function)] = [
	"F": parseFunctionType,
	"T": parseTupleType,
	"Q": parseTypeParameter,
]


// fixme: this belongs in Madness probably
func never<T>() -> Parser<T>.Function {
	return const(nil)
}

/// fixme: this belongs in Madness probably
infix operator >>= {
	precedence 150
}
func >>= <T, U> (left: Parser<T>.Function, right: T -> (Parser<U>.Function)?) -> Parser<U>.Function {
	return {
		left($0).map { input, rest in
			right(input).map {
				$0(rest)
			} ?? nil
		} ?? nil
	}
}

let parseUnparameterizedType: Parser<Type>.Function = parseAnnotation >>= { types[$0] != nil ? types[$0]! : never() }
let parseParameterizedType: Parser<Type>.Function = (ignore("U") ++ (%"_")+ --> { $0.count - 1 }) ++ parseUnparameterizedType --> { Type.Parameterized($0, Box($1)) }
let parseType: Parser<Type>.Function = parseUnparameterizedType | parseParameterizedType


let parseAnnotation = %["a", "C", "d", "E", "F", "g", "L", "m", "M", "n", "o", "O", "p", "P", "Q", "S", "T", "v", "V", "W"]

public let mangled: Parser<String>.Function = marker ++ parseMangledSymbol --> toString


public func find<S: SequenceType>(domain: S, predicate: S.Generator.Element -> Bool) -> S.Generator.Element? {
	for each in domain {
		if predicate(each) { return each }
	}
	return nil
}


// MARK: - Imports

import Box
import Madness
import Prelude
