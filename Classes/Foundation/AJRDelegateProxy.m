/*
 AJRDelegateProxy.m
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
