/*
AJRKeyExpression.m
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

#import "AJRKeyExpression.h"

#import "AJRExpression.h"
#import "AJRFunctions.h"
#import "NSError+Extensions.h"

@implementation AJRKeyExpression

#pragma mark - Creation

+ (AJRKeyExpression *)expressionWithKey:(NSString *)key
{
    return [[self alloc] initWithKey:key];
}

- (id)initWithKey:(NSString *)key
{
    if ((self = [super init])) {
        self.key = key;
    }
    return self;
}

#pragma mark - Actions

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    id value;
    
    @try {
        value = [object valueForKeyPath:_key];
    } @catch (NSException *exception) {
        value = nil;
        localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:[exception description]];
    }
    return AJRAssertOrPropagateError(value, error, localError);
}

#pragma mark - NSObject

- (NSString *)description
{
    return _key;
}

- (BOOL)isEqualToExpression:(AJRKeyExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_key, other->_key));
}

#pragma mark - Property Lists

- (id)initWithPropertyListValue:(id)value error:(NSError **)error
{
    NSError *localError;
    if ((self = [super initWithPropertyListValue:value error:&localError])) {
        _key = [value objectForKey:@"key"];
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (NSDictionary    *)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    [dictionary setObject:_key forKey:@"key"];
    return dictionary;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.key = [coder decodeObjectForKey:@"key"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_key forKey:@"key"];
}

@end
