
#import <AJRFoundation/AJRUnaryExpression.h>

@interface AJRConstant : AJRUnaryExpression <NSCoding, NSCopying>

+ (void)registerConstant:(Class)constantClass;

+ (AJRConstant *)constantForToken:(NSString *)token;

+ (NSArray<NSString *> *)tokens;
+ (NSString *)preferredToken;

- (BOOL)isEqualToConstant:(AJRConstant *)other;

@end
