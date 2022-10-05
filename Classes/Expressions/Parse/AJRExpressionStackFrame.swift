/*
 AJRExpressionStackFrame.swift
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

import Foundation

public class AJRExpressionStackFrame : NSObject {
    
    class AJRStackToken: CustomStringConvertible {
        
        var token : AJRExpressionToken? = nil
        var expression : AJRExpression? = nil
        var `operator` : AJROperator? {
            if isOperator {
                return token?.value as? AJROperator
            }
            return nil
        }
        
        init(token: AJRExpressionToken) {
            self.token = token
        }
        
        init(expression: AJRExpression) {
            self.expression = expression
        }
        
        var isOperator : Bool {
            return token != nil && token!.type == .operator
        }
        
        var isUnaryOperator : Bool {
            return token != nil && token!.type == .operator && token!.value is AJRUnaryOperator
        }
        
        // Is this still used, and if it is, then shouldn't it be replace with the check for a unary operator?
        var isPossibleUnaryOperator : Bool {
            return token != nil && token!.type == .operator && (token!.value as! AJROperator).canActAsUnary
        }
        
        var nonunaryOperatorExpression : AJROperatorExpression? {
            if let expression = expression as? AJROperatorExpression {
                if !expression.protected && !(expression.operator is AJRUnaryOperator) {
                    return expression
                }
            }
            return nil
        }
        
        var simpleExpression : AJRSimpleExpression {
            return expression as! AJRSimpleExpression
        }
        
        public var description: String {
            var string = "<\(type(of:self)): "
            if let token = token {
                string += "token: \(token)"
            } else if let expression = expression {
                string += "expression: \(expression)"
            }
            string += ">"
            return string
        }
        
        public func resolvedValue<T>() -> T {
            if let op = self.operator {
                return op as! T
            }
            return expression as! T
        }
        
    }

    internal var tokenStack = [AJRStackToken]()
    
    // MARK: - Creation

    public override init() {
    }

    // MARK: - Utilities

    public func stackTopIsOperator() -> Bool {
        return tokenStack.last?.isOperator ?? false
    }
    
    func transform(value: AJRExpressionToken) -> AJRStackToken {
        if value.type == .literal {
            // We need to transform.
            return AJRStackToken(expression: AJRKeyExpression(keyPath: value.value as! String))
        }
        if value.type == .operator {
            return AJRStackToken(token: value)
        }
        // Nothing to transform, so just return the value.
        return AJRStackToken(expression: AJRConstantExpression(value: value.value))
    }
    
    func shouldBreakUpExpression(_ value: AJRStackToken, dueTo operator: AJROperator) -> Bool {
        if let expression = value.nonunaryOperatorExpression {
            let preceeding = expression.operator
            return preceeding.precedence < `operator`.precedence
        }
        return false
    }

    // MARK: - Manipulating the stack
    
    private func DEBUG_STACK() -> Void {
    }

    public func add(token value: AJRExpressionToken) throws {
        if value.type == .openParen || value.type == .closeParen {
            throw AJRExpressionParserError.invalidToken("Attempt to push a parenthesis operator onto the expression stack. This isn't allowed")
        }
        
        // Add a token with some simple error checking...
        if tokenStack.count == 0 {
            // Nothing on the stack yet, so anything is good.
            tokenStack.append(transform(value:value))
            DEBUG_STACK()
        } else if let theOperator = value.operator {
            // We have an operator, so what we allow varies depending on the type of the operator.
            if (theOperator is AJRUnaryOperator
                || (stackTopIsOperator() && theOperator.canActAsUnary)) {
                // Unary operators are special, because they can be pushed onto the stack whenever.
                tokenStack.append(AJRStackToken(token: value))
                DEBUG_STACK()
            } else {
                // Non-unary operators can only be pushed on the stack if the preceeding token is not
                // another operator
                if stackTopIsOperator() {
                    // We have something invalid.
                    throw AJRExpressionParserError.invalidToken("Unexpected token in input: \(value)")
                } else {
                    tokenStack.append(AJRStackToken(token: value))
                    DEBUG_STACK()
                }
            }
        } else {
            // We have some kind of literal or constant. Note that we know there's at least one thing on
            // the stack already, so we have to get pushed next to an operator.
            if stackTopIsOperator() {
                // If the value is a literal, we'll go ahead and transform it into a key expression.
                tokenStack.append(transform(value:value))
                DEBUG_STACK()
                // And now that we've added a litteral, let's reduce.
                try reduce()
            } else {
                // We have something invalid.
                throw AJRExpressionParserError.invalidToken("Unexpected token in input: \(value)")
            }
        }
    }
    
    public func add(expression: AJRExpression) throws -> Void {
        // Add a token with some simple error checking...
        if tokenStack.count == 0 {
            // Nothing on the stack yet, so anything is good.
            tokenStack.append(AJRStackToken(expression: expression))
            DEBUG_STACK()
        } else {
            if stackTopIsOperator() {
                tokenStack.append(AJRStackToken(expression: expression))
                DEBUG_STACK()
                // And now that we've added a litteral, let's reduce.
                try reduce()
            } else {
                // We have something invalid.
                throw AJRExpressionParserError.invalidToken("Unexpected token in input: \(expression)")
            }
        }
    }
    
    public func reduce() throws -> Void {
        // So figure out how we're going to reduce.
        
        // First, the last item on the stack should be a literal of some kind
        if stackTopIsOperator() {
            throw AJRExpressionParserError.invalidReductionState("Attempt to reduce operator with invalid stack state: \(tokenStack)")
        }
        // Second, if our stack is 1, then we have nothing to do.
        if tokenStack.count == 1 {
            // We're done.
            return
        }
        // Third, see we have have two items on the stack. In this event, we should have a unary operator
        // and a literal / expression of some sort on the stack.
        if tokenStack.count >= 2 {
            if tokenStack[tokenStack.count - 2].isUnaryOperator {
                // We're good, so create a unary expression
                let expression : AJRUnaryExpression = AJRUnaryExpression(value: tokenStack.last!.resolvedValue(), operator: tokenStack[tokenStack.count - 2].resolvedValue()!)
                
                // Consume the last two objects
                tokenStack.removeLast(2)
                // And replace with our new expression
                tokenStack.append(AJRStackToken(expression: expression))
                DEBUG_STACK()
                // And we're done with expression
                // Attempt another reduction. Would happen in say the case of a + !b. Which means our
                // stack would currently be [a] [+] [!] [b]. We consumed the [!] and [b], so our stack is
                // now [a] [+] [!b]. Thus, we can reduce again to get down to [a+!b] on the stack.
                try reduce()
                // And we're done reducing
                return
            } else if tokenStack[tokenStack.count - 2].isPossibleUnaryOperator
                && !(tokenStack[tokenStack.count - 1].isOperator) {
                // We an opportunistic operator that may be acting as unary
                if tokenStack.count == 2 || (tokenStack.count >= 3 && tokenStack[tokenStack.count - 3].isOperator) {
                    // We do, because we basically have (nothing|operator), operator, number on the the stack.
                    let expression = AJRUnaryExpression(value: tokenStack.last!.resolvedValue(), operator: tokenStack[tokenStack.count - 2].resolvedValue()!)
                    // Consume the last two objects
                    tokenStack.removeLast(2)
                    // And replace with our new expression
                    tokenStack.append(AJRStackToken(expression: expression))
                    DEBUG_STACK()
                    // And we're done with expression
                    try reduce()
                    // And we're done reducing
                    return
                }
            }
            // We didn't have a unary operator, so let's fall through and see if we have a standard
            // operator.
        }
        if tokenStack.count >= 3 {
            var value1 = tokenStack[tokenStack.count - 3]
            var `operator` = tokenStack[tokenStack.count - 2]
            var value2 = tokenStack[tokenStack.count - 1]
            
//            RadarCore.log.debug("value1: \(value1)")
//            RadarCore.log.debug("operator: \(`operator`)")
//            RadarCore.log.debug("value2: \(value2)")

            // Now make sure everything is as we expect. Note, we don't have to worry about operator being
            // a unary operator at this point, because we would have reduced that above if it was.
            if !value1.isOperator && `operator`.isOperator && !value2.isOperator {
                // So in theory, we're good, and we can make an expression.
                var expression : AJRSimpleExpression
                
                if shouldBreakUpExpression(value1, dueTo:`operator`.operator!) {
                    // This indicates that the preceeding expression has a lower order of precedence to
                    // our current operator, so we'll break it up, but it back on the stack, and reduce
                    // the new operator instead.
                    
                    // Retain the values, so that they don't get release.
                    // Remove the top three items from the stack.
                    tokenStack.removeLast(3)
                    // Now push the pieces of value1 onto the stack.
                    tokenStack.append(AJRStackToken(expression: value1.simpleExpression.left as! AJRExpression))
                    tokenStack.append(AJRStackToken(token: AJRExpressionToken.token(type: .operator, value: value1.simpleExpression.operator)))
                    tokenStack.append(AJRStackToken(expression: value1.simpleExpression.right as! AJRExpression))
                    // And push our other two values back onto the stack.
                    tokenStack.append(AJRStackToken(token: `operator`.token!))
                    tokenStack.append(value2)
                    // Release those values, since we're now done with them.
                    // And make them our current values.
                    value1 = tokenStack[tokenStack.count - 3]
                    `operator` = tokenStack[tokenStack.count - 2]
                    value2 = tokenStack[tokenStack.count - 1]
                }
                
                expression = AJRSimpleExpression(left: value1.resolvedValue(), operator: `operator`.operator!, right: value2.resolvedValue())
                // Clear the objects from our stack.
                tokenStack.removeLast(3)
                tokenStack.append(AJRStackToken(expression: expression))
                DEBUG_STACK()
                // And attempt another reduction.
                try reduce()
                // And then we're done reducing.
                return
            }
        }
        throw AJRExpressionParserError.unexpectedTokenSequence("\(tokenStack)")
    }
        
    public func expression() throws -> AJRExpression? {
        try reduce()
        if tokenStack.count == 1 {
            let stackFrame = tokenStack[0]
            if let expression = stackFrame.expression {
                return expression
            }
        }
        throw AJRExpressionParserError.failedToFullyReduce("AJRExpression failed to fully reduce: \(tokenStack)")
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description: String {
        var string = "<\(type(of: self)): stack:\n"
        for frame in tokenStack {
            string += "\(frame),\n"
        }
        string += ">"
        return string
    }
    
}
