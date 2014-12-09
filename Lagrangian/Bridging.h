//  Copyright (c) 2014 Rob Rix. All rights reserved.

@import Foundation;
@import MachO.nlist;

/// Don’t use this, it’s an implementation detail.
extern uint32_t L3StringIndexOfSymbolTableEntry(const struct nlist_64 *entry);
