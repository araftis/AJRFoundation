
#import <AJRFoundation/AJRExpression.h>

@interface AJRKeyExpression : AJRExpression 

+ (AJRKeyExpression *)expressionWithKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;

@property (nonatomic,strong) NSString *key;

@end
