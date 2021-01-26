//
//  AJRUnaryExpression.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/3/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

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
