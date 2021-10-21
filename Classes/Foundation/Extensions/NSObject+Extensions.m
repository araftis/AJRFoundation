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

@interface NSObject (ObservancesDebug)

- (void)ajr_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)ajr_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)ajr_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)ajr_willChangeValueForKey:(NSString *)key;
- (void)ajr_didChangeValueForKey:(NSString *)key;

@end

@interface AJRObjectLoader : NSObject
@end

@implementation AJRObjectLoader

+ (void)load {
    Class class = objc_getClass("NSObject");
    if (getenv("DebugObservances") != NULL) {
        AJRSwizzleMethods(class, @selector(addObserver:forKeyPath:options:context:), class, @selector(ajr_addObserver:forKeyPath:options:context:));
        AJRSwizzleMethods(class, @selector(removeObserver:forKeyPath:context:), class, @selector(ajr_removeObserver:forKeyPath:context:));
        AJRSwizzleMethods(class, @selector(removeObserver:forKeyPath:), class, @selector(ajr_removeObserver:forKeyPath:));
    }
    if (getenv("DebugKVO") != NULL) {
        AJRSwizzleMethods(class, @selector(willChangeValueForKey:), class, @selector(ajr_willChangeValueForKey:));
        AJRSwizzleMethods(class, @selector(didChangeValueForKey:), class, @selector(ajr_didChangeValueForKey:));
    }
}

@end

@interface AJRObjectObserver : NSObject <AJRInvalidation>

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

- (void)invalidate {
    if (_observedObject != nil) {
        [_observedObject removeObserver:self forKeyPath:_keyPath];
        _keyPath = nil;
        _block = nil;
        _observedObject = nil;
    }
}

- (void)dealloc {
    [self invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    _block(object, keyPath, change);
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p, object: %@, keyPath: %@, block: %@>\n", self, self, _observedObject, _keyPath, _block);
}

@end

@implementation NSObject (Extensions)

- (BOOL)ajr_shouldLogObservances {
    return NO;
}

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

- (id <AJRInvalidation>)addObserver:(id)object forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock)block {
    return [[AJRObjectObserver alloc] initWithObservedObject:self keyPath:keyPath options:options block:block];
}

#pragma mark - Debugging

- (NSMutableDictionary<Class, NSMutableSet<NSString *> *> *)ajr_buildEnvironmentClassKeyDictionaryForVariable:(NSString *)envName {
    NSString *env = NSProcessInfo.processInfo.environment[envName];
    NSMutableDictionary<Class, NSMutableSet<NSString *> *> *debugDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *part in [env componentsSeparatedByString:@";"]) {
        NSArray *subparts = [part componentsSeparatedByString:@":"];
        if (!(subparts.count == 1 || subparts.count == 2)) {
            AJRLogWarning(@"DebugObservances: The DebugObservances format should be \"[<Class>[:key]][,...]\".");
        } else {
            Class class = NSClassFromString(subparts[0]);
            if (class == Nil) {
                AJRLogWarning(@"DebugObservances: No class named: \"%@\".", subparts[0]);
            } else {
                NSString *key = subparts.count == 2 ? subparts[1] : @"*ALL*";
                NSMutableSet *set = debugDictionary[class];
                if (set == nil) {
                    set = [NSMutableSet set];
                    debugDictionary[(id)class] = set;
                }
                [set addObject:key];
            }
        }
    }

    return debugDictionary;
}

static NSMutableDictionary<Class, NSMutableSet<NSString *> *> *_observancesDebug = nil;

- (BOOL)ajr_shouldObservanceLogKey:(NSString *)key forClass:(Class)class {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _observancesDebug = [self ajr_buildEnvironmentClassKeyDictionaryForVariable:@"DebugObservances"];
    });

    NSSet *set = _observancesDebug[(id)class];
    if (set != nil) {
        return [set containsObject:@"*"] || [set containsObject:key];
    }
    return NO;
}

- (void)ajr_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    if ([self ajr_shouldObservanceLogKey:keyPath forClass:self.class]) {
        AJRPrintf(@"addObserver: <%C: %p>, to: <%C: %p>, keyPath: %@, context: %p\n", observer, observer, self, self, keyPath, context);
    }
    [self ajr_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)ajr_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if ([self ajr_shouldObservanceLogKey:keyPath forClass:self.class]) {
        AJRPrintf(@"removeObserver: <%C: %p>, to: <%C: %p>, keyPath: %@, context: %p\n", observer, observer, self, self, keyPath, context);
    }
    [self ajr_removeObserver:observer forKeyPath:keyPath context:context];
}

- (void)ajr_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if ([self ajr_shouldObservanceLogKey:keyPath forClass:self.class]) {
        AJRPrintf(@"removeObserver: <%C: %p>, to: <%C: %p>, keyPath: %@\n", observer, observer, self, self, keyPath);
    }
    [self ajr_removeObserver:observer forKeyPath:keyPath];
}

static NSMutableDictionary<Class, NSMutableSet<NSString *> *> *_KVODebug = nil;

- (BOOL)ajr_shouldKVOLogKey:(NSString *)key forClass:(Class)class {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _KVODebug = [self ajr_buildEnvironmentClassKeyDictionaryForVariable:@"DebugKVO"];
    });

    NSSet *set = _KVODebug[(id)class];
    if (set != nil) {
        return [set containsObject:@"*"] || [set containsObject:key];
    }
    return NO;
}

- (void)ajr_willChangeValueForKey:(NSString *)keyPath {
    if ([self ajr_shouldKVOLogKey:keyPath forClass:self.class]) {
        id value = [self valueForKey:keyPath];
        AJRPrintf(@"willChangeValueForKey: <%C: %p>, keyPath: %@, value: <%C: %p>\n", self, self, keyPath, value, value);
    }
    [self ajr_willChangeValueForKey:keyPath];
}

- (void)ajr_didChangeValueForKey:(NSString *)keyPath {
    if ([self ajr_shouldKVOLogKey:keyPath forClass:self.class]) {
        id value = [self valueForKey:keyPath];
        AJRPrintf(@"didChangeValueForKey: <%C: %p>, keyPath: %@, value: <%C: %p>\n", self, self, keyPath, value, value);
    }
    [self ajr_didChangeValueForKey:keyPath];
}

@end
