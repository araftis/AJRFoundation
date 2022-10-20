/*
AJRUnaryExpression.m
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

#import "AJRUnaryExpression.h"

#import "AJROperator.h"
#import "AJRUnaryOperator.h"

#import "AJRFunctions.h"

@implementation AJRUnaryExpression

#pragma mark Creation

+ (instancetype)expressionWithValue:(id)value operator:(AJROperator *)operator
{
    return [[self alloc] initWithValue:value operator:operator];
}

- (instancetype)initWithValue:(id)value operator:(AJROperator *)operator
{
    if ((self = [super initWithOperator:operator])) {
        self.value = value;
    }
    return self;
}

#pragma mark Actions

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    id value = [AJRExpression evaluateValue:_value withObject:object error:&localError];
    id result = localError == nil ? [(AJRUnaryOperator *)self.operator performOperatorWithValue:value error:&localError] : nil;
    return AJRAssertOrPropagateError(result, error, localError);
}

#pragma mark NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@%@", [[self.operator class] preferredToken], [_value description]];
}

- (BOOL)isEqualToExpression:(AJRUnaryExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_value, other->_value));
}

#pragma mark Property Lists

- (id)initWithPropertyListValue:(NSDictionary *)dictionary error:(NSError **)error
{
    NSError *localError = nil;
    if ((self = [super initWithPropertyListValue:dictionary error:&localError])) {
        _value = [[AJRExpression alloc] initWithPropertyListValue:[dictionary objectForKey:@"value"] error:&localError];
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (NSDictionary    *)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    [dictionary setObject:[_value propertyListValue] forKey:@"value"];
    return dictionary;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        _value = [coder decodeObjectForKey:@"value"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_value forKey:@"value"];
}

@end
