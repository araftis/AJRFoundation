
#import "AJRAndOperator.h"

@implementation AJRAndOperator 

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return [NSNumber numberWithBool:[left boolValue] && [right boolValue]];
}

@end
