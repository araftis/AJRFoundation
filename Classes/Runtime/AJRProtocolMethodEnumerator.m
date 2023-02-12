/*
 AJRProtocolMethodEnumerator.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import "AJRProtocolMethodEnumerator.h"

#import <objc/runtime.h>

@implementation AJRProtocolMethodEnumerator
{
    struct objc_method_description *_list;
    
    unsigned int _count;
    unsigned int _index;
    
    BOOL _enumeratingRequired;
    BOOL _enumeratingClassMethods;
}

+ (id)methodEnumeratorWithProtocol:(Protocol *)enumeratedProtocol {
    return [[self alloc] initWithProtocol:enumeratedProtocol];
}

- (id)initWithProtocol:(Protocol *)protocol {
    if ((self = [super init])) {
        _enumeratedProtocol = protocol;
        
        _enumeratingRequired = YES;
        _enumeratingClassMethods = YES;
        
        _list = protocol_copyMethodDescriptionList(_enumeratedProtocol, _enumeratingRequired, !_enumeratingClassMethods, &_count);
    }
    return self;
}

- (id)nextObject {
    struct objc_method_description *next = [self nextMethod];
    return next ? [NSValue valueWithPointer:next] : nil;
}

- (struct objc_method_description *)nextMethod {
    if (_enumeratedProtocol == nil) {
        return nil;
    }
    
    if (_index >= _count) {
        _index = 0;
        if (_enumeratingRequired && _enumeratingClassMethods) {
            _enumeratingRequired = YES;
            _enumeratingClassMethods = NO;
        } else if (_enumeratingRequired && !_enumeratingClassMethods) {
            _enumeratingRequired = NO;
            _enumeratingClassMethods = YES;
        } else if (!_enumeratingRequired && _enumeratingClassMethods) {
            _enumeratingClassMethods = NO;
            _enumeratingRequired = NO;
        } else {
            _enumeratedProtocol = nil;
            _count = 0;
        }
        
        if (_enumeratedProtocol) {
            _list = protocol_copyMethodDescriptionList(_enumeratedProtocol, _enumeratingRequired, !_enumeratingClassMethods, &_count);
        }
        
        return [self nextMethod];
    }
    
    return &_list[_index++];
}

- (BOOL)isClassMethod {
    return _enumeratingClassMethods;
}

- (BOOL)isRequired {
    return _enumeratingRequired;
}

@end
