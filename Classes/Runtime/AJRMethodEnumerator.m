/* AJRMethodEnumerator.m created by alex on Wed 23-Aug-2000 */

#import "AJRMethodEnumerator.h"

@implementation AJRMethodEnumerator {
    Class _currentClass;
    
    Method *_list;
    
    unsigned int _count;
    unsigned int _subindex;
    BOOL _enumeratingClassMethods;
}

+ (instancetype)methodEnumeratorWithClass:(Class)class {
    return [[self alloc] initWithClass:class];
}

- (instancetype)initWithClass:(Class)aClass {
    if ((self = [super init])) {
        //AJRLogDebug(@"enumerate: %s (0x%x, 0x%x)\n", aClass->name, aClass->info, aClass->isa->info);
        _enumeratedClass = aClass;
        _count = 0;
        _subindex = 0;
        _enumeratingClassMethods = YES;
        _enumerateSuperclasses = NO;
        _currentClass = object_getClass(_enumeratedClass);
        _list = class_copyMethodList(_currentClass, &_count);
    }
    return self;
}

- (void)dealloc {
    if (_list) {
        free(_list);
    }
}

- (id)nextObject {
    Method nextMethod = [self nextMethod];
    return nextMethod ? [NSValue valueWithPointer:nextMethod] : nil;
}

- (Method)nextMethod {
    if (!_currentClass) {
        return NULL;
    }
    
    while (_subindex >= _count) {
        _currentClass = class_getSuperclass(_currentClass);
        if (_currentClass == Nil || !_enumerateSuperclasses) {
            if (_enumeratingClassMethods) {
                _currentClass = _enumeratedClass;
                _enumeratingClassMethods = NO;
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
        _list = class_copyMethodList(_currentClass, &_count);
        
        return [self nextMethod];
    }
    
    return _list[_subindex++];
}

- (BOOL)isClassMethod {
    return _enumeratingClassMethods;
}

@end
