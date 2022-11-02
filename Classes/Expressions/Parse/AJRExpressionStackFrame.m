/*
 AJRExpressionStackFrame.m
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

#import "AJRExpressionStackFrame.h"

#import "AJRConstantExpression.h"
#import "AJRExpression.h"
#import "AJRExpressionToken.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRKeyExpression.h"
#import "AJROperator.h"
#import "AJROperatorExpression.h"
#import "AJRSimpleExpression.h"
#import "AJRAddOperator.h"
#import "AJRSubtractOperator.h"
#import "AJRUnaryExpression.h"
#import "AJRUnaryOperator.h"

@implementation AJRExpressionStackFrame

#define STACK_DEBUG NO

#if STACK_DEBUG
#    define DEBUG_STACK() [self dumpStack]
#else
#    define DEBUG_STACK()
#endif


#pragma mark Creation

+ (id)frame {
    return [[self alloc] init];
}

- (id)init {
    if ((self = [super init])) {
        _tokenStack = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Destruction


#pragma mark Utilities

#if STACK_DEBUG
- (void)dumpStack {
    AJRPrintf(@"%C: stack: %@\n", self, _tokenStack);
}
#endif

- (BOOL)tokenIsOperator:(AJRExpressionToken *)token {
    return (token != nil 
            && [token isKindOfClass:[AJRExpressionToken class]] 
            && [token type] == AJRExpressionTokenTypeOperator);
}

- (BOOL)stackTopIsOperator {
    return [self tokenIsOperator:[_tokenStack lastObject]];
}

- (BOOL)tokenIsUnaryOperator:(AJRExpressionToken *)token {
    return (token != nil 
            && [token isKindOfClass:[AJRExpressionToken class]] 
            && [token type] == AJRExpressionTokenTypeOperator
            && [[token value] isKindOfClass:[AJRUnaryOperator class]]);
}

- (BOOL)tokenIsSubtractionOrAdditionOperator:(AJRExpressionToken *)token {
    return (token != nil 
            && [token isKindOfClass:[AJRExpressionToken class]] 
            && [token type] == AJRExpressionTokenTypeOperator
            && ([[token value] isKindOfClass:[AJRSubtractOperator class]]
                || [[token value] isKindOfClass:[AJRAddOperator class]]));
}

- (id)transformValue:(id)value {
    if ([value isKindOfClass:[AJRExpressionToken class]] && [(AJRExpressionToken *)value type] == AJRExpressionTokenTypeLiteral) {
        // We need to transform.
        return [AJRKeyExpression expressionWithKey:[(AJRExpressionToken *)value value]];
    }
    // Nothing to transform, so just return the value.
    return value;
}

- (id)valueOrExpressionForObject:(id)object {
    if ([object isKindOfClass:[AJRExpressionToken class]]) {
        return [(AJRExpressionToken *)object value];
    }
    return object;
}

- (BOOL)shouldBreakUpExpression:(id)value dueTo:(AJROperator *)operator {
    if ([value isKindOfClass:[AJROperatorExpression class]] && ![value protected] &&![value isKindOfClass:[AJRUnaryExpression class]]) {
        AJROperator    *preceeding = [(AJROperatorExpression *)value operator];
        
        return [preceeding precedence] < [operator precedence];
    }
    return NO;
}

#pragma mark Manipulating the stack

- (void)addToken:(AJRExpressionToken *)value {
    if ([value type] == AJRExpressionTokenTypeOpenParen || [value type] == AJRExpressionTokenTypeCloseParen) {
        // These aren't allowed
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Attempt to push a parenthesis operator onto the expression stack. This isn't allowed" userInfo:nil];
    }
    
    // Add a token with some simple error checking...
    if ([_tokenStack count] == 0) {
        // Nothing on the stack yet, so anything is good.
        [_tokenStack addObject:[self transformValue:value]];
        DEBUG_STACK();
    } else if ([value type] == AJRExpressionTokenTypeOperator) {
        // We have an operator, so what we allow varies depending on the type of the operator.
        if ([[value value] isKindOfClass:[AJRUnaryOperator class]]
            || ([self stackTopIsOperator] && [[value value] isKindOfClass:[AJRSubtractOperator class]])
            || ([self stackTopIsOperator] && [[value value] isKindOfClass:[AJRAddOperator class]])) {
            // Unary operators are special, because they can be pushed onto the stack whenever.
            [_tokenStack addObject:value];
            DEBUG_STACK();
        } else {
            // Non-unary operators can only be pushed on the stack if the preceeding token is not
            // another operator
            if ([self stackTopIsOperator]) {
                // We have something invalid.
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Unexpected token in input: %@", value) userInfo:nil];
            } else {
                [_tokenStack addObject:value];
                DEBUG_STACK();
            }
        }
    } else {
        // We have some kind of literal or constant. Note that we know there's at least one thing on
        // the stack already, so we have to get pushed next to an operator.
        if ([self stackTopIsOperator]) {
            // If the value is a literal, we'll go ahead and transform it into a key expression.
            [_tokenStack addObject:[self transformValue:value]];
            DEBUG_STACK();
            // And now that we've added a litteral, let's reduce.
            [self reduce];
        } else {
            // We have something invalid.
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Unexpected token in input: %@", value) userInfo:nil];
        }
    }
}

- (void)addExpression:(AJRExpression *)expression {
    // Add a token with some simple error checking...
    if ([_tokenStack count] == 0) {
        // Nothing on the stack yet, so anything is good.
        [_tokenStack addObject:expression];
        DEBUG_STACK();
    } else {
        if ([self stackTopIsOperator]) {
            [_tokenStack addObject:expression];
            DEBUG_STACK();
            // And now that we've added a litteral, let's reduce.
            [self reduce];
        } else {
            // We have something invalid.
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Unexpected token in input: %@", expression) userInfo:nil];
        }
    }
}

- (void)reduce {
    // So figure out how we're going to reduce.
    
    // First, the last item on the stack should be a literal of some kind
    if ([self stackTopIsOperator]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:AJRFormat(@"Attempt to reduce operator with invalid stack state: %@", _tokenStack) userInfo:nil];
    }
    // Second, if our stack is 1, then we have nothing to do.
    if ([_tokenStack count] == 1) {
        // We're done.
        return;
    }
    // Third, see we have have two items on the stack. In this event, we should have a unary operator
    // and a literal / expression of some sort on the stack.
    if ([_tokenStack count] >= 2) {
        if ([self tokenIsUnaryOperator:[_tokenStack objectAtIndex:[_tokenStack count] - 2]]) {
            AJRUnaryExpression    *expression;

            // We're good, so create a unary expression
            expression = [[AJRUnaryExpression alloc] initWithValue:[self valueOrExpressionForObject:[_tokenStack lastObject]]
                                                         operator:(AJROperator *)[[_tokenStack objectAtIndex:[_tokenStack count] - 2] value]];
            // Consume the last two objects
            [_tokenStack removeLastObject];
            [_tokenStack removeLastObject];
            // And replace with our new expression
            [_tokenStack addObject:expression];
            DEBUG_STACK();
            // And we're done with expression
            // Attempt another reduction. Would happen in say the case of a + !b. Which means our
            // stack would currently be [a] [+] [!] [b]. We consumed the [!] and [b], so our stack is
            // now [a] [+] [!b]. Thus, we can reduce again to get down to [a+!b] on the stack.
            [self reduce];
            // And we're done reducing
            return;
        } else if ([self tokenIsSubtractionOrAdditionOperator:[_tokenStack objectAtIndex:[_tokenStack count] - 2]] 
                   && ![self tokenIsOperator:[_tokenStack objectAtIndex:[_tokenStack count] - 1]]) {
            // We could have a negation
            if ([_tokenStack count] == 2 || ([_tokenStack count] >= 3 && [self tokenIsOperator:[_tokenStack objectAtIndex:[_tokenStack count] - 3]])) {
                // We do, because we basically have (nothing|operator), operator, number on the the stack.
                AJRUnaryExpression    *expression;

                expression = [AJRUnaryExpression expressionWithValue:[self valueOrExpressionForObject:[_tokenStack lastObject]]
                                                           operator:(AJROperator *)[[_tokenStack objectAtIndex:[_tokenStack count] - 2] value]];
                // Consume the last two objects
                [_tokenStack removeLastObject];
                [_tokenStack removeLastObject];
                // And replace with our new expression
                [_tokenStack addObject:expression];
                DEBUG_STACK();
                // And we're done with expression
                [self reduce];
                // And we're done reducing
                return;
            }
        }
        // We didn't have a unary operator, so let's fall through and see if we have a standard 
        // operator.
    }
    if ([_tokenStack count] >= 3) {
        id        value1, operator, value2;
        
        value1 = [_tokenStack objectAtIndex:[_tokenStack count] - 3];
        operator = [_tokenStack objectAtIndex:[_tokenStack count] - 2];
        value2 = [_tokenStack objectAtIndex:[_tokenStack count] - 1];
        
        // Now make sure everything is as we expect. Note, we don't have to worry about operator being
        // a unary operator at this point, because we would have reduced that above if it was.
        if (![self tokenIsOperator:value1] && [self tokenIsOperator:operator] && ![self tokenIsOperator:value2]) {
            // So in theory, we're good, and we can make an expression.
            AJRSimpleExpression    *expression;
            
            if ([self shouldBreakUpExpression:value1 dueTo:[(AJRExpressionToken *)operator value]]) {
                // This indicates that the preceeding expression has a lower order of precedence to
                // our current operator, so we'll break it up, but it back on the stack, and reduce
                // the new operator instead.
                
                // Retain the values, so that they don't get release.
                // Remove the top three items from the stack.
                [_tokenStack removeLastObject];
                [_tokenStack removeLastObject];
                [_tokenStack removeLastObject];
                // Now push the pieces of value1 onto the stack.
                [_tokenStack addObject:[(AJRSimpleExpression *)value1 left]];
                [_tokenStack addObject:[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator value:[(AJRSimpleExpression *)value1 operator]]];
                [_tokenStack addObject:[(AJRSimpleExpression *)value1 right]];
                // And push our other two values back onto the stack.
                [_tokenStack addObject:operator];
                [_tokenStack addObject:value2];
                // Release those values, since we're now done with them.
                // And make them our current values.
                value1 = [_tokenStack objectAtIndex:[_tokenStack count] - 3];
                operator = [_tokenStack objectAtIndex:[_tokenStack count] - 2];
                value2 = [_tokenStack objectAtIndex:[_tokenStack count] - 1];
            }
            
            expression = [[AJRSimpleExpression alloc] initWithLeft:[self valueOrExpressionForObject:value1]
                                                         operator:[(AJRExpressionToken *)operator value]
                                                            right:[self valueOrExpressionForObject:value2]];
            // Clear the objects from our stack.
            [_tokenStack removeLastObject];
            [_tokenStack removeLastObject];
            [_tokenStack removeLastObject];
            [_tokenStack addObject:expression];
            DEBUG_STACK();
            // And attempt another reduction.
            [self reduce];
            // And then we're done reducing.
            return;
        }
    }
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Unexpected token sequence in input: %@", _tokenStack) userInfo:nil];
}

- (AJRExpression *)expression {
    [self reduce]; 
    if ([_tokenStack count] == 1) {
        id expression = [_tokenStack objectAtIndex:0];
        if ([expression isKindOfClass:[AJRExpression class]]) {
            return expression;
        }
        if ([expression isKindOfClass:[AJRExpressionToken class]]) {
            if ([(AJRExpressionToken *)expression type] == AJRExpressionTokenTypeString || [(AJRExpressionToken *)expression type] == AJRExpressionTokenTypeNumber) {
                return [AJRConstantExpression expressionWithValue:[(AJRExpressionToken *)expression value]];
            }
        }
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Expression failed to fully reduce: %@", _tokenStack) userInfo:nil];
    }
    return nil;
}

@end
