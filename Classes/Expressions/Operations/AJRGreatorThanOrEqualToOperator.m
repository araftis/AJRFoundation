
#import "AJRGreatorThanOrEqualToOperator.h"

@implementation AJRGreatorThanOrEqualToOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return @([(NSNumber *)left compare:right] >= NSOrderedSame);
}

@end
