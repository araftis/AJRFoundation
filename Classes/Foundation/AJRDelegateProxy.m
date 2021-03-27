
#import "AJRDelegateProxy.h"

@implementation AJRDelegateProxy

+ (instancetype)delegateProxyWithDelegate:(id)delegate andInterloper:(id)interloper {
    return [self delegateProxyWithDelegate:delegate andInterloper:interloper returnValuesFromInterloper:NO];
}

+ (instancetype)delegateProxyWithDelegate:(id)delegate andInterloper:(id)interloper returnValuesFromInterloper:(BOOL)flag {
    return [[self alloc] initWithDelegate:delegate andInterloper:interloper returnValuesFromInterloper:flag];
}

- (instancetype)initWithDelegate:(id)delegate andInterloper:(id)interloper returnValuesFromInterloper:(BOOL)flag {
    // NOTE: Can't call super, because we're an NSProxy subclass.
    _delegate = delegate;
    _interloper = interloper;
    _returnValuesFromInterloper = flag;
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [_delegate respondsToSelector:selector] || [_interloper respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [_delegate methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = [invocation selector];
    
    if (_returnValuesFromInterloper) {
        if ([_delegate respondsToSelector:selector]) {
            [invocation invokeWithTarget:_delegate];
        }
        if ([_interloper respondsToSelector:selector]) {
            [invocation invokeWithTarget:_interloper];
        }
    } else {
        if ([_interloper respondsToSelector:selector]) {
            [invocation invokeWithTarget:_interloper];
        }
        if ([_delegate respondsToSelector:selector]) {
            [invocation invokeWithTarget:_delegate];
        }
    }
}

@end
