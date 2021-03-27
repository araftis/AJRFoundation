
#import "AJRMiscFunctions.h"

#import "AJRExpression.h"
#import "AJRFunctionExpression.h"
#import "AJRFunctions.h"
#import "NSError+Extensions.h"

@implementation AJRNullFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    return nil;
}

@end

@implementation AJRIsNullFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    id value = nil;
    
    if (localError == nil) {
        value = [AJRExpression value:[self.arguments firstObject] withObject:object error:&localError];
        if (localError == nil) {
            value = value == nil || value == [NSNull null] ? @YES : @NO;
        }
    }
    
    return AJRAssertOrPropagateError(value, error, localError);
}

@end

@implementation AJRHelpFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    id result = nil;
    
    if (localError == nil) {
        AJRFunctionExpression *expression = AJRObjectIfKindOfClass([self.arguments objectAtIndex:0], AJRFunctionExpression);
        if (expression) {
            result = expression.function.prototype;
        } else {
            localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Parameter to help() must be a function"];
        }
    }
    
    return AJRAssertOrPropagateError(result, error, localError);
}

@end
