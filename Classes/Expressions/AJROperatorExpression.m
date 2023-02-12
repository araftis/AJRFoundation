/*
 AJROperatorExpression.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import "AJROperatorExpression.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJROperator.h"

@implementation AJROperatorExpression

#pragma mark - Creation

- (instancetype)initWithOperator:(AJROperator *)operator
{
    if ((self = [super init])) {
        _operator = operator;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqualToExpression:(AJROperatorExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_operator, other->_operator));
}

#pragma mark - AJRPropetyListCoding

- (id)initWithPropertyListValue:(id)value error:(NSError **)error
{
    NSError *localError = nil;
    if ((self = [super initWithPropertyListValue:value error:&localError])) {
        _operator = [[AJROperator alloc] initWithPropertyListValue:[value objectForKey:@"operator"] error:&localError];
        if (localError != nil) {
            self = nil;
        }
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (id)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    [dictionary setObject:[_operator propertyListValue] forKey:@"operator"];
    return dictionary;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.operator = [coder decodeObjectForKey:@"operator"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_operator forKey:@"operator"];
}

@end
