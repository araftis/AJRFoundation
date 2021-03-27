
#import "AJRLogicFunctions.h"

#import "AJRExpression.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSNumber+Extensions.h"

@implementation AJRIfFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:2];
    id returnValue = nil;
    
    if (localError == nil) {
        BOOL expressionResult = [self booleanAtIndex:0 withObject:object error:&localError];
        if (localError == nil && expressionResult) {
            returnValue = [AJRExpression evaluateValue:[self.arguments objectAtIndex:1] withObject:object error:&localError];
        }
    }
    
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRIfElseFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:3];
    id returnValue;
    
    if (localError == nil) {
        BOOL expressionResult = [self booleanAtIndex:0 withObject:object error:&localError];
        if (localError == nil) {
            if (expressionResult) {
                returnValue = [AJRExpression evaluateValue:[self.arguments objectAtIndex:1] withObject:object error:error];
            } else {
                returnValue = [AJRExpression evaluateValue:[self.arguments objectAtIndex:2] withObject:object error:error];
            }
        }
    }
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

