/*
AJRPropertyEnumerator.m
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

#import "AJRPropertyEnumerator.h"

#import <objc/runtime.h>

@implementation AJRPropertyEnumerator {
    Class _currentClass;
    
    objc_property_t *_list;

    unsigned int _count;
    unsigned int _subindex;
    BOOL _enumeratingClassMethods;
}

+ (instancetype)propertyEnumeratorWithClass:(Class)enumeratedClass {
    return [[self alloc] initWithEnumeratorClass:enumeratedClass];
}

- (instancetype)initWithEnumeratorClass:(Class)enumeratedClass {
    if ((self = [super init])) {
        _enumeratedClass = enumeratedClass;
        
        _count = 0;
        _subindex = 0;
        _enumeratesSuperclasses = NO;
        _currentClass = _enumeratedClass;
        _enumeratingClassMethods = YES;
        _list = class_copyPropertyList(object_getClass(_enumeratedClass), &_count);
        
    }
    return self;
}

- (id)nextObject {
    // Because we're an enumerator and we have to implement this.
    objc_property_t nextProperty = [self nextProperty];
    return nextProperty ? [NSValue valueWithPointer:nextProperty] : nil;
}

- (objc_property_t)nextProperty {
    if (!_enumeratedClass) {
        return NULL;
    }
    
    while (_subindex >= _count) {
        _currentClass = class_getSuperclass(_currentClass);
        if (_currentClass == Nil || !_enumeratesSuperclasses) {
            if (_enumeratingClassMethods) {
                _currentClass = _enumeratedClass;
                _enumeratingClassMethods = NO;
            } else {
                _currentClass = Nil;
                _enumeratedClass = Nil;
                _count = 0;
                _subindex = 0;
                return NULL;
            }
        }
        _subindex = 0;
        if (_list) {
            free(_list);
            _list = NULL;
        }
        _list = class_copyPropertyList(_currentClass, &_count);

        return [self nextProperty];
    }
    
    return _list[_subindex++];
}

- (BOOL)isClassProperty {
    return _enumeratingClassMethods;
}

@end
