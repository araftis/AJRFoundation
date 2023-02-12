/*
 AJRConstantExpression.m
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

#import "AJRConstantExpression.h"

#import "AJRFunctions.h"

@implementation AJRConstantExpression
{
    // Used to help with some latter logic
    BOOL _isString;
}

#pragma mark - Creation

+ (AJRConstantExpression *)expressionWithValue:(id)value
{
    return [[self alloc] initWithValue:value];
}

- (id)initWithValue:(id)value
{
    if ((self = [super init])) {
        self.value = value;
    }
    return self;
}

#pragma mark - Properties

- (void)setValue:(id)value
{
    if (_value != value) {
        _value = value;
        _isString = [_value isKindOfClass:[NSString class]];
    }
}

#pragma mark - Actions

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    return _value;
}

#pragma mark - NSObject

- (NSString *)description
{
    if (_isString) {
        NSMutableString    *string = [[NSMutableString alloc] initWithString:@"\""];
        [string appendString:[_value description]];
        [string appendString:@"\""];
        return string;
    }
    return [_value description];
}

- (BOOL)isEqualToExpression:(AJRConstantExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_value, other->_value));
}

#pragma mark - Property Lists

- (id)initWithPropertyListValue:(id)value error:(NSError **)error
{
    NSError *localError = nil;
    if ((self = [super initWithPropertyListValue:value error:error])) {
        id decodedValue = [[AJRExpression alloc] initWithPropertyListValue:[value objectForKey:@"value"] error:&localError];
        if (localError == nil) {
            [self setValue:decodedValue];
        } else {
            self = nil;
        }
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (NSDictionary    *)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    [dictionary setObject:[_value propertyListValue] forKey:@"value"];
    return dictionary;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.value = [coder decodeObjectForKey:@"value"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_value forKey:@"value"];
}

@end
