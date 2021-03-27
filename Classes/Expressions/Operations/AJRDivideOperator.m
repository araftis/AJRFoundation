
#import "AJRDivideOperator.h"

#import "AJRExpression.h"
#import "AJRFunctions.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"

@implementation AJRDivideOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    NSError *localError = nil;
    id result = nil;
    if ([right doubleValue] == 0.0) {
        localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Attempt to divide by 0"];
    } else {
        result = @([left doubleValue] / [right doubleValue]);
    }
    return AJRAssertOrPropagateError(result, error, localError);
}

@end
