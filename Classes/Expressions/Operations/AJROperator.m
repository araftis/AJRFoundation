//
//  AJROperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/2/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJROperator.h"

#import "AJRExpression.h"
#import "AJRExpressionParser.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRPlugInExtensionPoint.h"
#import "AJRPlugInManager.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"

static NSMutableDictionary    *_operators = nil;

AJROperatorPrecedence AJROperatorPrecedenceFromString(NSString *string)
{
    if ([string isEqualToString:@"low"]) {
        return AJROperatorPrecedenceLow;
    } else if ([string isEqualToString:@"medium"]) {
        return AJROperatorPrecedenceMedium;
    } else if ([string isEqualToString:@"high"]) {
        return AJROperatorPrecedenceHigh;
    } else if ([string isEqualToString:@"higher"]) {
        return AJROperatorPrecedenceHigher;
    } else if ([string isEqualToString:@"unary"]) {
        return AJROperatorPrecedenceUnary;
    }
    return AJROperatorPrecedenceLow;
}

NSString *AJRStringFromOperatorPrecedence(AJROperatorPrecedence precedence)
{
    switch (precedence) {
        case AJROperatorPrecedenceLow:    return @"low";
        case AJROperatorPrecedenceMedium: return @"medium";
        case AJROperatorPrecedenceHigh:   return @"high";
        case AJROperatorPrecedenceHigher: return @"higher";
        case AJROperatorPrecedenceUnary:  return @"unary";
    }
    AJRAssertUnreachable(@"Invalid AJROperatorPrecedence: %d", (int)precedence);
}

@implementation AJROperator
{
    NSNumber *_precedence;
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _operators = [[NSMutableDictionary alloc] init];
    });
}

+ (void)registerOperator:(Class)operatorClass properties:(NSDictionary *)properties
{
    AJROperator *operator = [[operatorClass alloc] init];
    
    for (NSDictionary<NSString *,NSString *> *token in [properties objectForKey:@"operators"]) {
        [_operators setObject:operator forKey:[token objectForKey:@"name"]];
        [AJRExpressionParser addOperatorToken:[token objectForKey:@"name"]];
    }
}

+ (void)registerOperator:(Class)operatorClass
{
    NSMutableArray *operators = [NSMutableArray array];
    for (NSString *operator in [operatorClass tokens]) {
        [operators addObject:@{@"name":operator}];
    }
    [self registerOperator:operatorClass properties:@{@"operators":operators}];
}

+ (AJROperator *)operatorForToken:(NSString *)token
{
    return [_operators objectForKey:token];
}

+ (NSArray<NSString *> *)tokens
{
    return [[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajroperator"] valueForProperty:@"operators" onExtensionForClass:[self class]] valueForKey:@"name"];
}

+ (NSString *)preferredToken
{
    NSString *preferredToken = [[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajroperator"] valueForProperty:@"preferredToken" onExtensionForClass:[self class]];
    return preferredToken ?: [[self tokens] firstObject];
}

- (AJROperatorPrecedence)precedence
{
    if (_precedence == nil) {
        _precedence = @(AJROperatorPrecedenceFromString([[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajroperator"] valueForProperty:@"precedence" onExtensionForClass:[self class]]));
    }
    return (AJROperatorPrecedence)[_precedence integerValue];
}

#pragma mark Actions

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return AJRAbstract(nil);
}

#pragma mark - NSObject

- (NSString *)description
{
    return AJRFormat(@"<%C: %p: %@ (%@)>", self, self, [[self class] preferredToken], AJRStringFromOperatorPrecedence([self precedence]));
}

#pragma mark - AJRPropertyListCoding

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error
{
    NSError *localError = nil;
    
    self = [AJROperator operatorForToken:value];
    if (self == nil) {
        localError = [NSError errorWithDomain:AJRExpressionErrorDomain format:@"No known operator: '%@'", value];
    }
    
    return AJRAssertOrPropagateError(self, error, localError);
}

- (id)propertyListValue
{
    return [[self class] preferredToken];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init])) {
        self = [AJROperator operatorForToken:[coder decodeObjectForKey:@"operator"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[[self class] preferredToken] forKey:@"operator"];
}

@end
