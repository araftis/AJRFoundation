
#import "AJRNotOperator.h"

#import    "AJRExpression.h"

@implementation AJRNotOperator

- (id)performOperatorWithValue:(id)value error:(NSError **)error
{
    return [NSNumber numberWithBool:![value boolValue]];
}

@end
