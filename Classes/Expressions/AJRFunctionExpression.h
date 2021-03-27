
#import <AJRFoundation/AJRExpression.h>

@class AJRFunction;

@interface AJRFunctionExpression : AJRExpression <NSCoding>

+ (id)expressionWithFunction:(AJRFunction *)function;
- (id)initWithFunction:(AJRFunction *)function;

@property (nonatomic,strong) AJRFunction *function;

@end
