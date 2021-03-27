
#import "AJRModulusOperator.h"

@implementation AJRModulusOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return [NSNumber numberWithLong:[left longValue] % [right longValue]];
}

@end
