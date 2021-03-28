/*
AJRExpression.m
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

#import "AJRExpression.h"

#import "AJROperator.h"
#import "AJRExpressionParser.h"
#import "AJRExpressionToken.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRPlugInManager.h"
#import "AJRSimpleExpression.h"
#import "NSDictionary+Extensions.h"
#import "NSError+Extensions.h"
#import "NSString+Extensions.h"

@class AJREnvironment;

NSString * const AJRExpressionErrorDomain = @"AJRExpressionError";

@implementation AJRExpression

#pragma mark - Creation

+ (instancetype)expressionWithExpressionFormat:(NSString *)format, ... {
    id result;
    va_list ap;
    
    va_start(ap, format);
    result = [self expressionWithExpressionFormat:format arguments:ap];
    va_end(ap);
    
    return result;
}

+ (instancetype)expressionWithExpressionFormat:(NSString *)format arguments:(va_list)args {
    AJRExpressionParser *parser;
    AJRExpression *expression;
    
    parser = [[AJRExpressionParser alloc] initWithStringFormat:format arguments:args];
    expression = [parser expression];
    
    return expression;
}

+ (instancetype)expressionWithString:(NSString *)string error:(NSError * _Nullable * _Nullable)error {
    AJRExpression *expression = nil;
    NSError *localError = nil;
    
    @try {
        expression = [[[AJRExpressionParser alloc] initWithStringFormat:string arguments:NULL] expression];
    } @catch (NSException *localException) {
        localError = [NSError errorWithDomain:@"AJRExpressionError" message:[localException description]];
    }

    return AJRAssertOrPropagateError(expression, error, localError);
}

#pragma mark Actions

+ (id)evaluateValue:(id)value withObject:(id)object error:(NSError * _Nullable * _Nullable)error {
    NSError *localError = nil;
    id returnValue = value;
    while ([returnValue isKindOfClass:[AJRExpression class]] && localError == nil) {
        returnValue = [(AJRExpression *)returnValue evaluateWithObject:object error:&localError];
    }
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

- (nullable id)evaluateWithObject:(nullable id)object error:(NSError * _Nullable * _Nullable)error {
    return AJRAbstract(nil);
}

#pragma mark - NSObject

- (BOOL)isEqualToExpression:(AJRExpression *)other {
    return ([self class] == [other class]
            && _protected == other->_protected);
}

- (BOOL)isEqual:(NSObject *)other {
    return [other isKindOfClass:[AJRExpression class]] ? [self isEqualToExpression:(AJRExpression *)other] : NO;
}

- (NSUInteger)hash {
    return AJRAbstract(0);
}

#pragma mark - Property Lists

- (instancetype)initWithPropertyListValue:(NSDictionary *)dictionary error:(NSError **)error {
    NSError *localError = nil;
    if ([self class] == [AJRExpression class]) {
        Class expressionClass = NSClassFromString([dictionary objectForKey:@"type"]);
        self = [[expressionClass alloc] initWithPropertyListValue:dictionary error:&localError];
    } else {
        if ((self = [super init])) {
            _protected = [dictionary boolForKey:@"protected" defaultValue:NO];
        }
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

+ (AJRExpression *)expressionForDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    return [[self alloc] initWithPropertyListValue:dictionary error:error];
}

+ (AJRExpression *)expressionForObject:(id)anObject error:(NSError **)error {
    if ([anObject isKindOfClass:[NSDictionary class]]) {
        return [self expressionForDictionary:anObject error:error];
    } else {
        // Couldn't make a dictionary, so it must be a string.
        return [self expressionWithString:[anObject description] error:error];
    }
}

- (NSDictionary *)propertyListValue {
    return @{@"type":NSStringFromClass([self class]), @"protected":@(_protected)};
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _protected = [coder decodeBoolForKey:@"protected"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:_protected forKey:@"protected"];
}

#pragma mark - Utilities

+ (id)value:(id)value withObject:(id)object error:(NSError **)error {
    NSError *localError = nil;
    
    while ([value isKindOfClass:[AJRExpression class]] && localError == nil) {
        value = [(AJRExpression *)value evaluateWithObject:object error:&localError];
    }

    return AJRAssertOrPropagateError(value, error, localError);
}

+ (id)valueAsCollection:(id)value withObject:(id)object error:(NSError **)error {
    NSError *localError = nil;
    id returnValue = value;
    
    // Iterate an expression values until we get a basic value of some sort returned.
    while ([returnValue isKindOfClass:[AJRExpression class]] && localError == nil) {
        returnValue = [(AJRExpression *)returnValue evaluateWithObject:object error:&localError];
    }

    if (localError == nil) {
        // Now see if we already have a collection class. If we do, we can just return it.
        if (![returnValue isKindOfClass:[NSArray class]] && ![returnValue isKindOfClass:[NSSet class]] && ![returnValue isKindOfClass:[NSDictionary class]]) {
            // Value isn't a collection so make it a collection.
            returnValue = [NSSet setWithObject:returnValue];
        }
    }
    
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

+ (id)valueAsNumber:(id)value withObject:(id)object error:(NSError **)error {
    static NSCharacterSet *numberSet = nil;

    NSError *localError = nil;
    id returnValue = value;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.+-eE"];
    });
    
    // Iterate an expression values until we get a basic value of some sort returned.
    while ([returnValue isKindOfClass:[AJRExpression class]] && localError == nil) {
        returnValue = [(AJRExpression *)returnValue evaluateWithObject:object error:&localError];
    }
    
    if (localError == nil) {
        if ([returnValue isKindOfClass:[NSNumber class]]) {
            // Nothing to do, we're good.
        } else if ([returnValue isKindOfClass:[NSString class]]) {
            // Convert a string to a number, if possible.
            if ([(NSString *)returnValue rangeOfCharacterFromSet:[numberSet invertedSet]].location == NSNotFound) {
                returnValue = [(NSString *)returnValue numberValue];
            } else {
                returnValue = nil;
            }
        }
        
        if (returnValue == nil) {
            // We don't have anything that can be converted to a value.
            localError = [NSError errorWithDomain:AJRExpressionErrorDomain format:@"Cannot convert value to a number: %@", value];
        }
    }

    return AJRAssertOrPropagateError(returnValue, error, localError);
}

+ (id)valueAsString:(id)value withObject:(id)object error:(NSError **)error {
    NSError *localError = nil;
    id returnValue = value;
    
    // Iterate an expression values until we get a basic value of some sort returned.
    while ([returnValue isKindOfClass:[AJRExpression class]] && localError == nil) {
        returnValue = [(AJRExpression *)returnValue evaluateWithObject:object error:&localError];
    }
    
    if (localError == nil) {
        // We have something basic, so just return it's description
        returnValue = [returnValue description];
    }
    
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end
