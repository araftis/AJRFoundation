/*
NSObject+Extensions.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "NSObject+Extensions.h"

#import "AJRExpression.h"
#import "AJRFunctions.h"
#import "AJRTranslator.h"

#import <objc/message.h>
#import <objc/runtime.h>
#import <AJRFoundation/AJRFoundation.h>

@interface AJRObjectObserver : NSObject

@property (nonatomic,weak) id observedObject;
@property (nonatomic,strong) NSString *keyPath;
@property (nonatomic,assign) NSUInteger options;
@property (nonatomic,strong) AJRObserverBlock block;

- (instancetype)initWithObservedObject:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock)block;

@end

@implementation AJRObjectObserver

- (instancetype)initWithObservedObject:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock) block {
    if ((self = [super init])) {
        _observedObject = observedObject;
        _keyPath = keyPath;
        _options = options;
        _block = block;
        [_observedObject addObserver:self forKeyPath:keyPath options:options context:NULL];
    }
    return self;
}

- (void)dealloc {
    [_observedObject removeObserver:self forKeyPath:_keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    _block(object, keyPath, change);
}

@end

@implementation NSObject (Extensions)

#pragma mark - Miscellaneous

- (id)copyToSubclass:(Class)subclass {
    id <NSCoding> codableObject = AJRObjectIfConformsToProtocol(self, NSCoding);
    return codableObject != nil ? AJRCopyCodableObject(codableObject, subclass) : nil;
}

#pragma mark Key/Value Expression

- (id)valueForKeyExpression:(NSString *)keyExpression {
    return [[AJRExpression expressionWithString:keyExpression error:NULL] evaluateWithObject:self error:NULL];
}

#pragma mark - Reflection

- (BOOL)overridesSelector:(SEL)selector {
    IMP selfImp = [self methodForSelector:selector];
    IMP superImp = [[self superclass] instanceMethodForSelector:selector];
    
    return selfImp != superImp;
}

+ (BOOL)overridesSelector:(SEL)selector {
    IMP selfImp = [self instanceMethodForSelector:selector];
    IMP superImp = [[self superclass] instanceMethodForSelector:selector];
    
    return selfImp != superImp;
}

- (id)addObserver:(id)object forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock)block {
    return [[AJRObjectObserver alloc] initWithObservedObject:self keyPath:keyPath options:options block:block];
}

@end
