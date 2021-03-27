
#import <AJRFoundation/AJRFoundationOS.h>
#import <AJRFoundation/AJRPropertyListCoding.h>

typedef NS_ENUM(uint8_t, AJROperatorPrecedence) {
    AJROperatorPrecedenceLow    = 0,
    AJROperatorPrecedenceMedium = 10,
    AJROperatorPrecedenceHigh   = 20,
    AJROperatorPrecedenceHigher = 30,
    AJROperatorPrecedenceUnary  = 40
};

extern AJROperatorPrecedence AJROperatorPrecedenceFromString(NSString *string);
extern NSString *AJRStringFromOperatorPrecedence(AJROperatorPrecedence precedence);

@interface AJROperator : NSObject <NSCoding, AJRPropertyListCoding>

+ (void)registerOperator:(Class)operatorClass properties:(NSDictionary *)properties;
+ (void)registerOperator:(Class)operatorClass;

+ (AJROperator *)operatorForToken:(NSString *)token;

+ (NSArray<NSString *> *)tokens;
+ (NSString *)preferredToken;

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error;

- (AJROperatorPrecedence)precedence;

@end
