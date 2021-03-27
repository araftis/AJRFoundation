
#import "AJRNotEqualsOperator.h"

@implementation AJRNotEqualsOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if (left == right) return [NSNumber numberWithBool:NO];
    return [NSNumber numberWithBool:![left isEqual:right]];
}

@end
