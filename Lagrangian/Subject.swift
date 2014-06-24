//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// The subject of a test.
struct Subject<T> {
	var _delayedValue: () -> T
	
	init(_ value: @auto_closure () -> T) {
		_delayedValue = value
	}
}


operator prefix % {}

/// Make a \c Subject from \c value.
@prefix func % <T> (value: @auto_closure () -> T) -> Subject<T> {
	return Subject(value)
}
