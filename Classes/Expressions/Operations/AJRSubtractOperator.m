
#import "AJRSubtractOperator.h"

#import "NSNumber+Extensions.h"

@implementation AJRSubtractOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if ([left isInteger] && [right isInteger]) {
        return [NSNumber numberWithLong:[left longValue] - [right longValue]];
    }
    return [NSNumber numberWithDouble:[left doubleValue] - [right doubleValue]];
}

// Note: Subtraction is special, because it sometimes acts as a unary operator to make a value negative.
- (id)performOperatorWithValue:(id)value error:(NSError **)error
{
    if ([value isInteger]) {
        return [NSNumber numberWithLong:-[value longValue]];
    }
    return [NSNumber numberWithDouble:-[value doubleValue]];
}

@end

