//  Copyright (c) 2014 Rob Rix. All rights reserved.

#import "Bridging.h"

uint32_t L3StringIndexOfSymbolTableEntry(const struct nlist_64 *entry) {
	return entry ? entry->n_un.n_strx : 0;
}
