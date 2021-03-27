
#import "AJRUnaryOperator.h"

#import "AJRFunctions.h"

@implementation AJRUnaryOperator

- (id)performOperatorWithValue:(id)value error:(NSError **)error
{
    return AJRAbstract(nil);
}

#pragma mark AJROperator

- (AJROperatorPrecedence)precedence
{
    return AJRAbstract(AJROperatorPrecedenceUnary);
}

@end
