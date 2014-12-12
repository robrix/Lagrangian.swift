//  Copyright (c) 2014 Rob Rix. All rights reserved.

// MARK: - Parsers

let marker = ignore("_T")

let count = (%("0"..."9"))+ --> { strtol("".join($0), nil, 10) }

let many: Int -> Parser<String>.Function = { n in any * n --> { "".join($0) } }

public let identifier: Parser<String>.Function = { count($0).map { many($0)($1) } ?? nil }

public let mangled = marker ++ identifier+ --> { ".".join($0) }


public func find<S: SequenceType>(domain: S, predicate: S.Generator.Element -> Bool) -> S.Generator.Element? {
	for each in domain {
		if predicate(each) { return each }
	}
	return nil
}


// MARK: - Imports

import Madness
