//
//  AJRConstantExpression.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/4/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

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
