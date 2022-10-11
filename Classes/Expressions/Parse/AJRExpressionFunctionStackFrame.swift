/*
 AJRExpressionFunctionStackFrame.swift
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

@objcMembers
public class AJRExpressionFunctionStackFrame : AJRExpressionStackFrame {
    
    // MARK: - Properties
    
    public var function : AJRFunction
    
    // MARK: - Creation
    
    public init(function: AJRFunction) {
        self.function = function
        super.init()
    }
    
    // MARK: - Actions
    
    public func reduceArgument() throws -> Void {
        // This only works if the stack count is 1.
        if tokenStack.count == 1 {
            // Get the actual expression of the argument from our super.
            let expression = try super.expression()
            // Add it as an argument to the function.
            function.append(argument: expression)

            // And regardless of what we did, clear the expression in preparation for the next argument.
            tokenStack.removeAll()
        } else if tokenStack.count > 1 {
            throw AJRExpressionParserError.failedToFullyReduce("AJRExpression failed to fully reduce: \(tokenStack)")
        }
        // Do nothing in this case. We'll just ignore blank arguments.
    }
    
    // MARK: - AJRExpressionStackFrame
    
    public override func expression() throws -> AJRExpression {
        try reduceArgument()
        return AJRFunctionExpression(function: function)
    }

}
