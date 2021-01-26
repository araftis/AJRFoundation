//
//  AJRVariableEnumerator.m
//  AJRFoundation
//
//  Created by Alex Raftis on 6/11/18.
//

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
    Ivar nextVariable = [self nextVariale];
    return nextVariable ? [NSValue valueWithPointer:nextVariable] : nil;
}

- (Ivar)nextVariale {
    if (!_enumeratedClass) {
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
                _enumeratedClass = Nil;
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
        
        return [self nextVariale];
    }
    
    return _list[_subindex++];
}

- (BOOL)isClassMethod {
    return _enumeratingClassIvar;
}

@end
