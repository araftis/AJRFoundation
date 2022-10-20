/*
AJRConstant.m
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

#import "AJRConstant.h"

#import "AJRExpressionParser.h"
#import "AJRFunctions.h"
#import "AJRPlugInExtensionPoint.h"
#import "AJRPlugInManager.h"

static NSMutableDictionary    *_constants = nil;

@implementation AJRConstant

+ (void)initialize {
    if (_constants == nil) {
        _constants = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerConstant:(Class)constantClass properties:(NSDictionary *)properties {
    AJRConstant *constant = [[constantClass alloc] init];
    
    for (NSDictionary<NSString *, NSString *> *token in [properties objectForKey:@"tokens"]) {
        [_constants setObject:constant forKey:[token objectForKey:@"name"]];
        [AJRExpressionParser addLiteralToken:[token objectForKey:@"name"]];
    }
}

+ (void)registerConstant:(Class)constantClass {
    NSMutableArray *tokens = [NSMutableArray array];
    for (NSString *token in [constantClass tokens]) {
        [tokens addObject:@{@"name":token}];
    }
    [self registerConstant:constantClass properties:@{@"tokens":tokens}];
}

+ (AJRConstant *)constantForToken:(NSString *)token {
    return [_constants objectForKey:token];
}

+ (NSArray<NSString *> *)tokens {
    return [[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrconstant"] valueForProperty:@"tokens" onExtensionForClass:[self class]] valueForKey:@"name"];
}
     
+ (NSString *)preferredToken {
    NSString *preferredToken = [[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrconstant"] valueForProperty:@"preferredToken" onExtensionForClass:[self class]];
    return preferredToken ?: [[self tokens] firstObject];
}

- (id)value {
    return AJRAbstract(nil);
}

#pragma mark AJRUnaryExpression

- (id)evaluateWithObject:(id)object error:(NSError **)error {
    return [self value];
}

#pragma mark NSObject

- (NSString *)description {
    return [[self class] preferredToken];
}

- (NSUInteger)hash {
    return [[[self class] preferredToken] hash];
}

- (BOOL)isEqualToConstant:(AJRConstant *)other {
    return [[[self class] preferredToken] isEqualToString:[[other class] preferredToken]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AJRConstant class]] && [self isEqualToConstant:other];
}

#pragma mark AJRPropertyListCoding

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    return [AJRConstant constantForToken:[value objectForKey:@"name"]];
}

- (id)propertyListValue {
    return @{@"type":@"AJRConstant", @"name":[[self class] preferredToken]};
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        // Force a singleton type behavior.
        self = [AJRConstant constantForToken:[coder decodeObjectForKey:@"constant"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[[self class] preferredToken] forKey:@"constant"];
}

@end
