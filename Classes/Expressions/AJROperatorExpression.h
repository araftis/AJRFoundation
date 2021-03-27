
#import <AJRFoundation/AJRExpression.h>

@class AJROperator;

@interface AJROperatorExpression : AJRExpression

- (instancetype)initWithOperator:(AJROperator *)operator;

@property (nonatomic,strong) AJROperator *operator;

@end
