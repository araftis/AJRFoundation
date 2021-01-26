//
//  AJRTrigonomitryFunctions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/8/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRTrigonomitryFunctions.h"

#import "AJRExpression.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSNumber+Extensions.h"

@implementation AJRSinFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(sin(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRCosFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(cos(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRTanFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(tan(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRArcsinFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(sin(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRArccosFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    double value = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(acos(value)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRArctanFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCountMin:1 max:2];
    double value1 = localError == nil ? [self doubleAtIndex:0 withObject:object error:&localError] : 0.0;
    double value2 = localError == nil && self.arguments.count == 2 ? [self doubleAtIndex:1 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(self.arguments.count == 2 ? atan2(value1, value2) : atan(value1)) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end
