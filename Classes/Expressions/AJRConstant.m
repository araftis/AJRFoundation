
#import "AJRConstant.h"

#import "AJRExpressionParser.h"
#import "AJRFunctions.h"
#import "AJRPlugInExtensionPoint.h"
#import "AJRPlugInManager.h"

static NSMutableDictionary    *_constants = nil;

@implementation AJRConstant

+ (void)initialize {
    if (_constants == nil) {
        _constants = [[NSMutableDictionary alloc] init];
    }
}

+ (void)registerConstant:(Class)constantClass properties:(NSDictionary *)properties {
    AJRConstant *constant = [[constantClass alloc] init];
    
    for (NSDictionary<NSString *, NSString *> *token in [properties objectForKey:@"tokens"]) {
        [_constants setObject:constant forKey:[token objectForKey:@"name"]];
        [AJRExpressionParser addLiteralToken:[token objectForKey:@"name"]];
    }
}

+ (void)registerConstant:(Class)constantClass {
    NSMutableArray *tokens = [NSMutableArray array];
    for (NSString *token in [constantClass tokens]) {
        [tokens addObject:@{@"name":token}];
    }
    [self registerConstant:constantClass properties:@{@"tokens":tokens}];
}

+ (AJRConstant *)constantForToken:(NSString *)token {
    return [_constants objectForKey:token];
}

+ (NSArray<NSString *> *)tokens {
    return [[[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrconstant"] valueForProperty:@"tokens" onExtensionForClass:[self class]] valueForKey:@"name"];
}
     
+ (NSString *)preferredToken {
    NSString *preferredToken = [[[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrconstant"] valueForProperty:@"preferredToken" onExtensionForClass:[self class]];
    return preferredToken ?: [[self tokens] firstObject];
}

- (id)value {
    return AJRAbstract(nil);
}

#pragma mark AJRUnaryExpression

- (id)evaluateWithObject:(id)object error:(NSError **)error {
    return [self value];
}

#pragma mark NSObject

- (NSString *)description {
    return [[self class] preferredToken];
}

- (NSUInteger)hash {
    return [[[self class] preferredToken] hash];
}

- (BOOL)isEqualToConstant:(AJRConstant *)other {
    return [[[self class] preferredToken] isEqualToString:[[other class] preferredToken]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AJRConstant class]] && [self isEqualToConstant:other];
}

#pragma mark AJRPropertyListCoding

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    return [AJRConstant constantForToken:[value objectForKey:@"name"]];
}

- (id)propertyListValue {
    return @{@"type":@"AJRConstant", @"name":[[self class] preferredToken]};
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        // Force a singleton type behavior.
        self = [AJRConstant constantForToken:[coder decodeObjectForKey:@"constant"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[[self class] preferredToken] forKey:@"constant"];
}

@end
