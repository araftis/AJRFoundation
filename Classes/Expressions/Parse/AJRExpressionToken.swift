/*
 AJRExpressionToken.swift
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
public class AJRExpressionToken: NSObject {

    @objc(AJRExpressionTokenType)
    public enum TokenType : Int {
        case string
        case number
        case dateComponent
        case literal
        case `operator`
        case openParen
        case closeParen
        case function
        case comma
    }
    

    static var openParenToken = AJRExpressionToken(type: .openParen)
    static var closeParenToken = AJRExpressionToken(type: .closeParen)
    static var commaToken = AJRExpressionToken(type: .comma)

    public var type : TokenType
    public var value : Any?

    @available(swift, obsoleted: 1.0) // Swift doesn't need this method, because it understands the one below.
    public class func token(type: TokenType) -> AJRExpressionToken {
        return token(type: type, value: nil)
    }

    public class func token(type: TokenType, value: Any? = nil) -> AJRExpressionToken {
        var token : AJRExpressionToken
        
        if type == .openParen {
            token = AJRExpressionToken.openParenToken
        } else if type == .closeParen {
            token = AJRExpressionToken.closeParenToken
        } else if type == .comma {
            token = AJRExpressionToken.commaToken
        } else {
            token = AJRExpressionToken(type: type, value: value)
        }
        
        return token
    }
    
    private init(type: TokenType, value: Any? = nil) {
        self.type = type
        self.value = value
    }

    public override var description : String {
        if let value = value {
            return "[Token (\(type)): \(value))]"
        }
        return "[Token (\(type)): nil]"
    }
    
    // MARK: - Conveniences
    
    // If the token is "TokenType.operator" then return's value as an operator
    public var `operator` : AJROperator? {
        if type == .operator {
            return value as? AJROperator
        }
        return nil
    }

}
