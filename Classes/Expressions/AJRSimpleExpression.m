/*
 AJRSimpleExpression.m
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

#import "AJRSimpleExpression.h"

#import "AJRFunctions.h"
#import "AJROperator.h"

@implementation AJRSimpleExpression

#pragma mark Creation

+ (AJRExpression *)expressionWithLeft:(id)left operator:(AJROperator *)anOperator right:(id)right
{
    return [[self alloc] initWithLeft:left operator:anOperator right:right];
}

- (id)initWithLeft:(id)left operator:(AJROperator *)operator right:(id)right
{
    if ((self = [super initWithOperator:operator])) {
        _left = left;
        _right = right;
    }
    return self;
}

#pragma mark Actions

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    AJRExpression *left = [AJRExpression evaluateValue:_left withObject:object error:&localError];
    AJRExpression *right = localError == nil ? [AJRExpression evaluateValue:_right withObject:object error:&localError] : nil;
    id result = localError == nil ? [self.operator performOperatorWithLeft:left andRight:right error:&localError] : nil;
    return AJRAssertOrPropagateError(result, error, localError);
}

#pragma mark NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%@ %@ %@)", _left, [[self.operator class] preferredToken], _right];
}

- (BOOL)isEqualToExpression:(AJRSimpleExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_left, other->_left)
            && AJREqual(_right, other->_right));
}

#pragma mark Property Lists

- (id)initWithPropertyListValue:(NSDictionary *)dictionary error:(NSError **)error
{
    if ((self = [super initWithPropertyListValue:dictionary error:error])) {
        _left = [[AJRExpression alloc] initWithPropertyListValue:[dictionary objectForKey:@"left"] error:NULL];
        _right = [[AJRExpression alloc] initWithPropertyListValue:[dictionary objectForKey:@"right"] error:NULL];
    }
    
    return self;
}

- (NSDictionary    *)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    
    [dictionary setObject:[_left propertyListValue] forKey:@"left"];
    [dictionary setObject:[_right propertyListValue] forKey:@"right"];

    return dictionary;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        _left = [coder decodeObjectForKey:@"left"];
        _right = [coder decodeObjectForKey:@"right"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_left forKey:@"left"];
    [coder encodeObject:_right forKey:@"right"];
}

@end
