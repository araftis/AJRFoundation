/*
AJRMiscFunctions.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
