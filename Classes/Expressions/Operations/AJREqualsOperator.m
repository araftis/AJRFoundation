
#import "AJREqualsOperator.h"

@implementation AJREqualsOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if (left == right) return [NSNumber numberWithBool:YES];
    return [NSNumber numberWithBool:[left isEqual:right]];
}

@end
