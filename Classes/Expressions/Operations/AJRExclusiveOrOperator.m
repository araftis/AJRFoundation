
#import "AJRExclusiveOrOperator.h"

@implementation AJRExclusiveOrOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    BOOL l = [left boolValue], r = [right boolValue];
    return [NSNumber numberWithBool:(l || r) && (!l || !r)];
}

@end
