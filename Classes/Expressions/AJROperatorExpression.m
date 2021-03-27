
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
