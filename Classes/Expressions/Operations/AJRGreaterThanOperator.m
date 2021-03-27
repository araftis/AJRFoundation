
#import "AJRGreaterThanOperator.h"

#import "AJRExpression.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"

@implementation AJRGreaterThanOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return @([(NSNumber *)left compare:right] > NSOrderedSame);
}

@end
