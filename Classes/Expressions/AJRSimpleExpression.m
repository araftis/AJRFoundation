
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
