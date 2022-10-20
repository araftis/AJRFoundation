/*
AJRXMLCollectionPlaceholder.m
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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

#import "AJRXMLCollectionPlaceholder.h"

#import "AJRXMLArchiver.h"

@implementation AJRXMLCollectionPlaceholder

- (id)initWithFinalClass:(Class)finalClass {
    if ((self = [super init])) {
        _finalClass = finalClass;
        _max = 16;
        _index = 0;
        _objects = (id __strong *)NSZoneCalloc(NULL, _max, sizeof(id));
    }
    return self;
}

- (void)dealloc {
    // Make sure these are freed. They usually are down in the finalizeXMLDecoding method, but if an error occurred, they could be sticking around.
    for (NSInteger x = 0; x < _index; x++) {
        _objects[x] = nil;
    }
    _index = 0;
    NSZoneFree(NULL, _objects);
}

- (void)appendObject:(id)object {
    if (_index >= _max) {
        NSInteger oldMax = _max;
        if (_max < 256) {
            _max = _max + _max;
        } else {
            _max += 128;
        }
        _objects = (id __strong *)NSZoneRealloc(NULL, _objects, _max * sizeof(id));
        // Make sure to zero these, or we're going to crash when ARC tries to release a random pointer.
        memset(_objects + oldMax, 0, sizeof(id) * (_max - oldMax));
    }
    _objects[_index] = object;
    _index += 1;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeObjectUsingSetter:^(id object) {
        [self appendObject:object];
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    NSSet *result = [[_finalClass alloc] initWithObjects:_objects count:_index];
    // For now, give up ownership of the objects immediately. This can help with tracking down bugs.
    for (NSInteger x = 0; x < _index; x++) {
        _objects[x] = nil;
    }
    _index = 0;
    return result;
}

@end
