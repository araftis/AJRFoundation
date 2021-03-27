
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
