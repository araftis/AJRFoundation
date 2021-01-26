
#import <AJRFoundation/AJROperatorExpression.h>

@class AJROperator;

@interface AJRSimpleExpression : AJROperatorExpression <NSCoding>

+ (AJRExpression *)expressionWithLeft:(id)left operator:(AJROperator *)anOperator right:(id)right;

- (id)initWithLeft:(id)left operator:(AJROperator *)anOperator right:(id)right;

@property (nonatomic,strong) id left;
@property (nonatomic,strong) id right;

@end
