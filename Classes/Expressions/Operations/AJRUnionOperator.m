
#import "AJRUnionOperator.h"

#import "AJRCollection.h"
#import "AJRExpression.h"
#import "AJRFunctions.h"

@implementation AJRUnionOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    NSError *localError;
    id <AJRCollection> leftCollection = [AJRExpression valueAsCollection:left withObject:nil error:&localError];
    id <AJRCollection> rightCollection = localError == nil ? [AJRExpression valueAsCollection:right withObject:nil error:&localError] : nil;
    id <AJRCollection> result = localError == nil ? [leftCollection ajr_collectionByUnioningWithCollection:rightCollection] : nil;

    return AJRAssertOrPropagateError(result, error, localError);
}

@end
