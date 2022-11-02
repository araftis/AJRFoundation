/*
 AJRTrigonomitryFunctions.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
