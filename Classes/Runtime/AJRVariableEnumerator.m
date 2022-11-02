/*
 AJRVariableEnumerator.m
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

#import "AJRVariableEnumerator.h"

@implementation AJRVariableEnumerator {
    Class _currentClass;
    
    Ivar *_list;
    
    unsigned int _count;
    unsigned int _subindex;
    BOOL _enumeratingClassIvar;
}


+ (instancetype)variableEnumeratorWithClass:(Class)class {
    return [[self alloc] initWithClass:class];
}

- (instancetype)initWithClass:(Class)aClass {
    if ((self = [super init])) {
        //AJRLogDebug(@"enumerate: %s (0x%x, 0x%x)\n", aClass->name, aClass->info, aClass->isa->info);
        _enumeratedClass = aClass;
        _count = 0;
        _subindex = 0;
        _enumeratingClassIvar = YES;
        _enumerateSuperclasses = NO;
        _currentClass = object_getClass(_enumeratedClass);
        _list = class_copyIvarList(_currentClass, &_count);
    }
    return self;
}

- (void)dealloc {
    if (_list) {
        free(_list);
    }
}

- (id)nextObject {
    Ivar nextVariable = [self nextVariable];
    return nextVariable ? [NSValue valueWithPointer:nextVariable] : nil;
}

- (Ivar)nextVariable {
    if (!_currentClass) {
        return NULL;
    }
    
    while (_subindex >= _count) {
        _currentClass = class_getSuperclass(_currentClass);
        if (_currentClass == Nil || !_enumerateSuperclasses) {
            if (_enumeratingClassIvar) {
                _currentClass = _enumeratedClass;
                _enumeratingClassIvar = NO;
            } else {
                _currentClass = Nil;
                _count = 0;
                _subindex = 0;
                return NULL;
            }
        }
        _subindex = 0;
        if (_list) {
            free(_list);
        }
        _list = class_copyIvarList(_currentClass, &_count);
        
        return [self nextVariable];
    }
    
    return _list[_subindex++];
}

- (BOOL)isClassVariable {
    return _enumeratingClassIvar;
}

@end
