
#import "AJRBasicMathFunctions.h"

#import "AJRExpression.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSNumber+Extensions.h"

@implementation AJRSquareRootFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(sqrt(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRCeilingFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(ceil(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRFloorFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(floor(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRRoundFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(round(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRRemainderFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:2];
    double x = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    double y = localError == nil ? [self doubleAtIndex:1 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(remainder(x, y)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRMinFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCountMin:1];
    id result = nil;
    
    if (localError == nil) {
        double value = 0.0;
        
        value = [self doubleAtIndex:0 withObject:object error:error];
        for (NSInteger x = 1, max = self.arguments.count; x < max && localError == nil; x++) {
            double nextValue = [self doubleAtIndex:x withObject:object error:&localError];
            if (nextValue < value) value = nextValue;
        }
        
        if (localError == nil) {
            result = @(value);
        }
    }
    
    return AJRAssertOrPropagateError(result, error, localError);
}

@end

@implementation AJRMaxFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCountMin:1];
    id result = nil;
    
    if (localError == nil) {
        double value = 0.0;
        
        value = [self doubleAtIndex:0 withObject:object error:error];
        for (NSInteger x = 1, max = self.arguments.count; x < max && localError == nil; x++) {
            double nextValue = [self doubleAtIndex:x withObject:object error:error];
            if (nextValue > value) {
                value = nextValue;
            }
        }
        if (localError == nil) {
            result = @(value);
        }
    }
    
    return AJRAssertOrPropagateError(result, error, localError);
}

@end

@implementation AJRAbsFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    id value = localError == nil ? [self numberAtIndex:0 withObject:object error:&localError] : nil;
    id returnValue = nil;
    if (localError == nil) {
        returnValue = [value isInteger] ? @(labs([value longValue])) : @(fabs([value doubleValue]));
    }
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRLogFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(log10(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRLnFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(log(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

