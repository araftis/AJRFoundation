/*
 AJRExpressionStackFrame.h
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import <Foundation/Foundation.h>

@class AJRExpression, AJRExpressionToken;

NS_ASSUME_NONNULL_BEGIN

@interface AJRExpressionStackFrame : NSObject
{    
    NSMutableArray        *_tokenStack;
}

/*!
 Creates a new stack frame and prepares it for use.
 
 @result A newly initialized AJRExpressionStackFrame ready for use.
 */
+ (id)frame;

/*!
 Adds a token to the stack. Adding a token may cause the stack to be reduced. Added tokens in an 
 invalid grammar order will cause an exception to be thrown. For example, "2 + 2" is valid, will 
 pushing the three individual tokens [2] [+] and [2] onto the stack will cause a reduction to the
 expression [2 + 2]. On the other hand, trying to add the tokens [2] [+] [+] [2] onto the stack will
 throw an exception, since two adjacent, non-unary operators makes no sense.
 
 @param token A token to add to the stack frame. Note that you're required to add tokens in a fashion
              that makes logical sense. See above for furthre details.
 */
- (void)addToken:(AJRExpressionToken *)token;

/*!
 Adds an expression to the stack. This is similar to added a token, but adds an entire subexpression.
 This most often happens when processing parentheses in the input stream, as the closing parenthesis
 causes an expression on another stack frame to be generated. This can then be added to the base
 expression.
 
 <P>Like addToken:, adding an expression can also cause a reduction and follows similar rules, where
 expression acts like a non-operator token. Thus, it's valid to add tokens and expression like this:
 [2] [+] [2 * 2], but not valid to add double operators or literals, just like with a call to addToken:. 
 
 @param expression A subexpression to add to the stack frame. This is treated in a manner similar to
                   a literal token.
 */
- (void)addExpression:(AJRExpression *)expression;

/*!
 Called to perform a reduce operation on the stack. This pulls tokens from the stack and reduces 
 them to expressions that can then be evaluated. When tokens are added correctly, a stack frame
 will eventually reduce to a single expression. If not, an exception will be thrown.
 */
- (void)reduce;

/*!
 When you're done adding tokens or expressions to the stack frame, you can call expression to get
 the final expression returned. Note that this method will only return an expression if there's one
 and only one expression left on the stack or nil if there's nothing on the stack. If multiple tokens
 or subexpressions are left on the stack, this method will throw an exception, as it means not enough
 tokens or subexpression were added to the stack frame to reduce the results to a final expression.
 
 You can evaluate the returned expression to compute the final results of an expression.
 
 @result The final expression generated by the stack frame.
 */
- (nullable AJRExpression *)expression;

@end

NS_ASSUME_NONNULL_END
