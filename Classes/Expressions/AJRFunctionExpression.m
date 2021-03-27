
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
