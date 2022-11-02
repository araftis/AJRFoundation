/*
 AJRProtocolPropertyEnumerator.m
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

#import "AJRProtocolPropertyEnumerator.h"

@implementation AJRProtocolPropertyEnumerator
{
    objc_property_t *_list;
    
    unsigned int _count;
    unsigned int _index;
    
    BOOL _enumeratingRequired;
    BOOL _enumeratingClassProperties;
}

+ (id)propertyEnumeratorWithProtocol:(Protocol *)enumeratedProtocol {
    return [[self alloc] initWithProtocol:enumeratedProtocol];
}

- (id)initWithProtocol:(Protocol *)protocol {
    if ((self = [super init])) {
        _enumeratedProtocol = protocol;
        
        _enumeratingRequired = YES;
        _enumeratingClassProperties = YES;
        
        _list = protocol_copyPropertyList2(_enumeratedProtocol, &_count, _enumeratingRequired, _enumeratingClassProperties);
    }
    return self;
}

- (id)nextObject {
    objc_property_t next = [self nextProperty];
    return next ? [NSValue valueWithPointer:next] : nil;
}

- (objc_property_t)nextProperty {
    if (_enumeratedProtocol == nil) {
        return nil;
    }
    
    if (_index >= _count || _list == NULL) { // _list == NULL happens when a protcol has no required or class properties.
        _index = 0;
        if (_enumeratingRequired && _enumeratingClassProperties) {
            _enumeratingRequired = YES;
            _enumeratingClassProperties = NO;
        } else if (_enumeratingRequired && !_enumeratingClassProperties) {
            _enumeratingRequired = NO;
            _enumeratingClassProperties = YES;
        } else if (!_enumeratingRequired && _enumeratingClassProperties) {
            _enumeratingClassProperties = NO;
            _enumeratingRequired = NO;
        } else {
            _enumeratedProtocol = nil;
            _count = 0;
        }
        
        if (_enumeratedProtocol) {
            _list = protocol_copyPropertyList2(_enumeratedProtocol, &_count, _enumeratingRequired, _enumeratingClassProperties);
        }
        
        return [self nextProperty];
    }
    
    return _list[_index++];
}

@end
