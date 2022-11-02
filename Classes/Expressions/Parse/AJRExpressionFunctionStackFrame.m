/*
 AJRExpressionFunctionStackFrame.m
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

#import "AJRExpressionFunctionStackFrame.h"

#import "AJRExpression.h"
#import "AJRExpressionToken.h"
#import "AJRFormat.h"
#import "AJRFunction.h"
#import "AJRFunctionExpression.h"

@interface AJRExpressionFunctionStackFrame ()
@property (nonatomic,strong) AJRFunction *function;
@end

@implementation AJRExpressionFunctionStackFrame

#pragma mark Creation

+ (instancetype)frameWithFunction:(AJRFunction *)function
{
    return [[self alloc] initWithFunction:function];
}

- (instancetype)initWithFunction:(AJRFunction *)function
{
    if ((self = [super init])) {
        _function = function;
    }
    return self;
}

#pragma mark Actions

- (void)reduceArgument
{
    // This only works if the stack count is 1.
    if ([_tokenStack count] == 1) {
        // Get the actual expression of the argument from our super.
        AJRExpression    *expression = [super expression];
        
        if (expression) {
            // If we got something, add it as an argument to the function.
            [_function addArgument:expression];
        }
        // And regardless of what we did, clear the expression in preparation for the next argument.
        [_tokenStack removeAllObjects];
    } else if ([_tokenStack count] > 1) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Expression failed to fully reduce: %@", _tokenStack) userInfo:nil];
    }
    // Do nothing in this case. We'll just ignore blank arguments.
}

#pragma mark AJRExpressionStackFrame

- (AJRExpression *)expression
{
    // First off, let's make sure we reduce the last argument
    [self reduceArgument];
    
    return [AJRFunctionExpression expressionWithFunction:_function];
}
@end
