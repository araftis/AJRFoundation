
#import <AJRFoundation/AJROperator.h>

@interface AJRUnaryOperator : AJROperator

- (id)performOperatorWithValue:(id)value error:(NSError **)error;

@end
