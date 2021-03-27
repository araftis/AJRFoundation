
#import "AJRExponentOperator.h"

@implementation AJRExponentOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return [NSNumber numberWithDouble:pow([left doubleValue], [right doubleValue])];
}

@end
