//  Copyright (c) 2014 Rob Rix. All rights reserved.

// MARK: - Parsers

let marker = ignore("_T")

let count = (%("0"..."9"))+ --> { strtol("".join($0), nil, 10) }

// todo: this belongs in Madness
let any: Parser<String>.Function = { x in (x[x.startIndex..<advance(x.startIndex, 1, x.endIndex)], x[advance(x.startIndex, 1, x.endIndex)..<x.endIndex]) }

let three = any * 3
let many: Int -> Parser<String>.Function = { n in any * n --> { "".join($0) } }

public let identifier: Parser<String>.Function = { count($0).map { many($0)($1) } ?? nil }

public let mangled = marker ++ identifier+ --> { ".".join($0) }


// MARK: - Imports

import Madness
