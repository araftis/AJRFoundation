/*
 AJRFunctionExpression.m
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

#import "AJRFunctionExpression.h"

#import "AJRFunction.h"
#import "AJRFunctions.h"

@implementation AJRFunctionExpression

#pragma mark - Creation

+ (id)expressionWithFunction:(AJRFunction *)function
{
    return [[self alloc] initWithFunction:function];
}

- (id)initWithFunction:(AJRFunction *)function
{
    if ((self = [super init])) {
        self.function = function;
    }
    return self;
}

#pragma mark - AJRExpression

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    return [_function evaluateWithObject:object error:error];
}

#pragma mark - NSObject

- (NSString *)description
{
    NSMutableString    *description = [NSMutableString string];
    BOOL first = YES;
    
    [description appendString:[_function name]];
    [description appendString:@"("];
    for (id argument in [_function arguments]) {
        if (first) {
            first = NO;
        } else {
            [description appendString:@", "];
        }
        [description appendString:[argument description]];
    }
    [description appendString:@")"];
    
    return description;
}

- (BOOL)isEqualToExpression:(AJRFunctionExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_function, other->_function));
}

#pragma mark - AJRPropertyListCoding

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error
{
    NSError *localError;
    if ((self = [super initWithPropertyListValue:value error:&localError])) {
        _function = [[AJRFunction alloc] initWithPropertyListValue:[value objectForKey:@"function"] error:&localError];
        if (localError != nil) {
            self = nil;
        }
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (id)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    [dictionary setObject:[_function propertyListValue] forKey:@"function"];
    return dictionary;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.function = [coder decodeObjectForKey:@"function"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_function forKey:@"function"];
}

@end
