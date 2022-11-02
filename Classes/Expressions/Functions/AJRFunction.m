/*
 AJRFunction.m
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

#import "AJRFunction.h"

#import "AJRExpression.h"
#import "AJRExpressionParser.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRPlugInExtensionPoint.h"
#import "AJRPlugInManager.h"
#import "NSError+Extensions.h"

static NSMutableDictionary<NSString *, Class> *_functions = nil;

@implementation AJRFunction
{
    NSMutableArray *_arguments;
}

#pragma mark - Initialization

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _functions = [[NSMutableDictionary alloc] init];
    });
}

#pragma mark - Factory

+ (void)registerFunction:(Class)functionClass properties:(NSDictionary *)properties
{
    [_functions setObject:functionClass forKey:properties[@"name"]];
    [AJRExpressionParser addLiteralToken:properties[@"name"]];
}

+ (void)registerFunction:(Class)functionClass
{
    [self registerFunction:functionClass properties:@{@"name":[functionClass name]}];
}

+ (Class)functionClassForName:(NSString *)functionName
{
    return [_functions objectForKey:functionName];
}

+ (NSString *)name
{
    return [[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrfunction"] valueForProperty:@"name" onExtensionForClass:[self class]];
}

- (NSString *)name
{
    return [[self class] name];
}

+ (NSString *)prototype
{
    return [[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrfunction"] valueForProperty:@"prototype" onExtensionForClass:[self class]];
}

- (NSString *)prototype;
{
    return [[self class] prototype];
}

#pragma mark - Creation

- (id)init
{
    if ((self = [super init])) {
        _arguments = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Arguments

- (NSArray *)arguments
{
    return _arguments;
}

- (void)setArguments:(NSArray *)arguments
{
    _arguments = [arguments mutableCopy];
}

- (void)addArgument:(id)argument
{
    [_arguments addObject:argument];
}

#pragma mark - Actions

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    return AJRAbstract(nil);
}

#pragma mark - Utilities

- (NSError *)checkArgumentCount:(NSUInteger)count
{
    return [_arguments count] != count ? [NSError errorWithDomain:AJRExpressionErrorDomain format:@"Function %C expects %d argument%@", self, count, count == 1 ? @"" : @"s"] : nil;
}

- (NSError *)checkArgumentCountMin:(NSUInteger)min
{
    return [_arguments count] < min ? [NSError errorWithDomain:AJRExpressionErrorDomain format:@"Function %C expects at least %d argument%@", self, min, min == 1 ? @"" : @"s"] : nil;
}

- (NSError *)checkArgumentCountMin:(NSUInteger)min max:(NSUInteger)max
{
    return ([_arguments count] < min || [_arguments count] > max) ? [NSError errorWithDomain:AJRExpressionErrorDomain format:@"Function %C expects between %d and %d arguments", self, min, max] : nil;
}

- (NSError *)checkArgumentCountMax:(NSUInteger)max
{
    return ([_arguments count] > max) ? [NSError errorWithDomain:AJRExpressionErrorDomain format:@"Function %C expects at most %d argument%@", self, max, max == 1 ? @"" : @"s"] : nil;
}

- (NSString *)stringAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error
{
    return [AJRExpression valueAsString:[_arguments objectAtIndex:index] withObject:object error:error];
}

- (NSNumber *)numberAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error
{
    return [AJRExpression valueAsNumber:[_arguments objectAtIndex:index] withObject:object error:error];
}

- (BOOL)booleanAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error
{
    return [[AJRExpression valueAsNumber:[_arguments objectAtIndex:index] withObject:object error:error] boolValue];
}

- (NSInteger)integerAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error
{
    return [[AJRExpression valueAsNumber:[_arguments objectAtIndex:index] withObject:object error:error] integerValue];
}

- (double)doubleAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error
{
    return [[AJRExpression valueAsNumber:[_arguments objectAtIndex:index] withObject:object error:error] doubleValue];
}

- (id)collectionAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error
{
    return [AJRExpression valueAsCollection:[_arguments objectAtIndex:index] withObject:object error:error];
}

#pragma mark - NSObject

- (BOOL)isEqualToFunction:(AJRFunction *)other
{
    return ([self class] == [other class]
            && AJREqual(_arguments, other->_arguments));
}

- (BOOL)isEqual:(id)other
{
    return ([other isKindOfClass:[AJRFunction class]]
            && [self isEqualToFunction:(AJRFunction *)other]);
}

#pragma mark - AJRPropertyListCoding

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error
{
    NSError *localError = nil;
    if ([self class] == [AJRFunction class]) {
        Class expressionClass = NSClassFromString([value objectForKey:@"type"]);
        if (expressionClass) {
            self = [[expressionClass alloc] initWithPropertyListValue:value error:error];
        } else {
            self = nil;
            localError = [NSError errorWithDomain:AJRExpressionErrorDomain format:@"No known function class: %@", [value objectForKey:@"type"]];
        }
    } else {
        if ((self = [super init])) {
            _arguments = [NSMutableArray array];
            for (NSDictionary *argument in [value objectForKey:@"arguments"]) {
                id decodedArgument = [[AJRExpression alloc] initWithPropertyListValue:argument error:&localError];
                if (decodedArgument) {
                    [_arguments addObject:decodedArgument];
                } else if (localError) {
                    self = nil;
                    break;
                }
            }
        }
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (id)propertyListValue
{
    NSMutableArray *arguments = [NSMutableArray array];
    
    for (id argument in _arguments) {
        [arguments addObject:[argument propertyListValue]];
    }
    
    return @{@"type":NSStringFromClass([self class]), @"arguments":arguments};
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init])) {
        _arguments = [[coder decodeObjectForKey:@"arguments"] mutableCopy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_arguments forKey:@"arguments"];
}

@end
