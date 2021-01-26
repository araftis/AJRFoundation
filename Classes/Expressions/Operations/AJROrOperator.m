
#import "AJROrOperator.h"

@implementation AJROrOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return [NSNumber numberWithBool:[left boolValue] || [right boolValue]];
}

@end
