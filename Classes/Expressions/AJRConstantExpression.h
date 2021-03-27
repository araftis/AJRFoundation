
#import <AJRFoundation/AJRExpression.h>

@interface AJRConstantExpression : AJRExpression 

+ (AJRConstantExpression *)expressionWithValue:(id)value;
- (id)initWithValue:(id)value;

@property (nonatomic,strong) id value;

@end
