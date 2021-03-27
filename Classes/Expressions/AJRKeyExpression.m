
#import "AJRKeyExpression.h"

#import "AJRExpression.h"
#import "AJRFunctions.h"
#import "NSError+Extensions.h"

@implementation AJRKeyExpression

#pragma mark - Creation

+ (AJRKeyExpression *)expressionWithKey:(NSString *)key
{
    return [[self alloc] initWithKey:key];
}

- (id)initWithKey:(NSString *)key
{
    if ((self = [super init])) {
        self.key = key;
    }
    return self;
}

#pragma mark - Actions

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    id value;
    
    @try {
        value = [object valueForKeyPath:_key];
    } @catch (NSException *exception) {
        value = nil;
        localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:[exception description]];
    }
    return AJRAssertOrPropagateError(value, error, localError);
}

#pragma mark - NSObject

- (NSString *)description
{
    return _key;
}

- (BOOL)isEqualToExpression:(AJRKeyExpression *)other
{
    return ([super isEqualToExpression:other]
            && AJREqual(_key, other->_key));
}

#pragma mark - Property Lists

- (id)initWithPropertyListValue:(id)value error:(NSError **)error
{
    NSError *localError;
    if ((self = [super initWithPropertyListValue:value error:&localError])) {
        _key = [value objectForKey:@"key"];
    }
    return AJRAssertOrPropagateError(self, error, localError);
}

- (NSDictionary    *)propertyListValue
{
    NSMutableDictionary *dictionary = [[super propertyListValue] mutableCopy];
    [dictionary setObject:_key forKey:@"key"];
    return dictionary;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        self.key = [coder decodeObjectForKey:@"key"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_key forKey:@"key"];
}

@end
