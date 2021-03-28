/*
AJRAutoreleasedMemory.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AJRAutoreleasedMemory.h"

static NSInteger AJRDefaultMallocMemoryCapacity = 500;
static NSString * const AJRMallocMemoryKey = @"AJRAutoreleaseMalloc";

@implementation AJRAutoreleasedMemory  {
    void *_bytes;
    NSUInteger _bytesUsed;
    NSUInteger _capacity;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    if ((self = [super init])) {
        _bytes = calloc(capacity, 1);
        _bytesUsed = 0;
        _capacity = capacity;
    }
    return self;
}

- (NSUInteger)remainingCapacityForAlignment:(size_t)alignment {
    // Round _length up to the nearest aligned byte based on alignment.
    // NOTE: We're making the assumption here that because we're asking for an alignment, we're going to use that alignment, and therefore we need to round up _length. However, even is this assumption is wrong, at most we'll loose a few bytes of capacity. Still, the assumption shouldn't be wrong, because this is our internal method.
    _bytesUsed = _bytesUsed + (_bytesUsed % alignment);
    return _capacity - _bytesUsed;
}

- (void *)mallocMemoryWithCapacity:(NSUInteger)capacity {
    void *returnValue = _bytes + _bytesUsed;
    _bytesUsed += capacity;
    return returnValue;
}

- (void)dealloc {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    
    if ([[threadDictionary objectForKey:AJRMallocMemoryKey] nonretainedObjectValue] == self) {
        [threadDictionary removeObjectForKey:AJRMallocMemoryKey];
    }
    
    free(_bytes);
    [super dealloc];
}

+ (void *)autoreleasedMemoryWithCapacity:(NSUInteger)capacity {
    return [self autoreleasedMemoryWithCapacity:capacity alignment:1];
}

+ (void *)autoreleasedMemoryWithCapacity:(NSUInteger)capacity alignment:(size_t)alignment {
    AJRAutoreleasedMemory *toBeUsed = nil;
    
    if (capacity > AJRDefaultMallocMemoryCapacity) {
        // Definitely need a new one...
        toBeUsed = [[[AJRAutoreleasedMemory alloc] initWithCapacity:capacity] autorelease];
        return [toBeUsed mallocMemoryWithCapacity:capacity];
    } else {
        NSUInteger remainingCapacityInExistingOne;
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        toBeUsed = [[threadDictionary objectForKey:AJRMallocMemoryKey] nonretainedObjectValue];
        remainingCapacityInExistingOne = toBeUsed ? [toBeUsed remainingCapacityForAlignment:alignment] : 0;
        
        if (capacity > remainingCapacityInExistingOne) {
            // Not enough room in existing one...
            toBeUsed = [[[AJRAutoreleasedMemory alloc] initWithCapacity:AJRDefaultMallocMemoryCapacity] autorelease];
            [threadDictionary setObject:[NSValue valueWithNonretainedObject:toBeUsed] forKey:AJRMallocMemoryKey];
        }
        return [toBeUsed mallocMemoryWithCapacity:capacity];
    }
}

@end
