
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
