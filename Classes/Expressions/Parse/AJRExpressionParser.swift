/*
 AJRExpressionParser.swift
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

public enum AJRExpressionParserError : Error {
    
    case invalidToken(String)
    case unexpectedTokenSequence(String)
    case invalidReductionState(String)
    case failedToFullyReduce(String)
    case unknownFunction(String)
    case invalidState(String)
    case missingModifier(String)
    case invalidModifier(String)
    case insufficientArguments(String)
    case invalidType(String)
    case invalidCharacter(String)
    case unbalancedParentheses(String)
    case invalidInput(String)

}

@objcMembers
public class AJRExpressionParser : NSObject {

    // MARK: - Character Sets
    
    static var whitespaceSet = CharacterSet.whitespacesAndNewlines
    static var argumentNumberStartSet = CharacterSet(charactersIn: "+-0123456789")
    static var numberStartSet = CharacterSet(charactersIn: "0123456789")
    static var numberSet = CharacterSet(charactersIn: "0123456789.")
    static var literalStartSet = CharacterSet.swiftIdentifierStartCharacterSet
    static var literalSet = CharacterSet.swiftIdentifierCharacterSet
    static var operatorStartSet = CharacterSet()
    static var operatorSet = CharacterSet()

    // MARK: - Properties
    
    public var string : String
    public var length : String.Index
    public var position : String.Index
    public var stack : [AJRExpressionStackFrame]
    public var arguments : [Any?]
    public var argumentIndex : Int
    internal var _expression: AJRExpression?
    
    // MARK: - Creation
    
    public init(string: String) throws {
        AJRExpression.initialize() // Make sure all the operators, functions, and constants are registered
        self.string = string
        self.length = self.string.endIndex
        self.position = self.string.startIndex
        self.stack = [AJRExpressionStackFrame]()
        self.arguments = []
        self.argumentIndex = 0
    }

    @objc (initWithFormat:arguments:error:)
    public convenience init(format: String, _ arguments: [Any]) throws {
        try self.init(string: format)
        self.arguments = arguments
    }

    public convenience init(format: String, _ arguments: [Any?]) throws {
        try self.init(string: format)
        self.arguments = arguments
    }
    
    // MARK: - Utilities
    
    internal func nextArgument<T>() throws -> T? {
        if argumentIndex >= arguments.count {
            throw AJRExpressionParserError.insufficientArguments("Not enough arguments were provided by caller.")
        }
        let argument = arguments[argumentIndex];
        argumentIndex += 1
        if argument == nil || (argument as? NSObject) == NSNull.init() {
            return nil
        }
        if let argument = argument as? T {
            return argument
        }
        throw AJRExpressionParserError.invalidType("Argument was not of a valid type: \(type(of:T.self))")
    }
    
    // MARK: - Parse
    
    internal func readWhitespace() throws -> Void {
        while (position < length) && AJRExpressionParser.whitespaceSet.contains(string[position]) {
            position = string.index(after: position)
        }
    }
    
    internal enum ForcedType : Character, CaseIterable {
        case none = "\u{0000}"
        case integer = "i"
        case float = "f"
        case hour = "H"
        case minute = "M"
        case second = "S"
        case month = "m"
        case day = "d"
        case year = "y"
    }
    
    internal func readNumber() throws -> AJRExpressionToken {
        let start = position
        var hasDecimal = false
        
        // Make sure we move over a +/-
        while position < length {
            let character = string[position]
            
            if !AJRExpressionParser.numberSet.contains(character) {
                break
            }
            if character == "." {
                // Make sure to only read on decimal point
                if hasDecimal {
                    break
                }
                hasDecimal = true
            }
            
            position = string.index(after: position)
        }
        
        // See if we have a modifier
        var forcedType = ForcedType.none
        if position < length {
            let character = string[position]
            for type in ForcedType.allCases {
                if character == type.rawValue {
                    forcedType = type
                    break
                }
            }
        }

        // Grab the numeric portion of the string
        let substring = string[start..<position]

        // See if we need to consume the "type" charcter
        if forcedType != .none {
            position = string.index(after: position)
        }

        let value : Any
        let numberType : AJRExpressionToken.TokenType
        // And create our value
        switch forcedType {
        case .none:
            if hasDecimal {
                value = Double(substring)!
            } else {
                value = Int(substring)!
            }
            numberType = .number
        case .integer:
            value = Int(substring)!
            numberType = .number
        case .float:
            value = Int(substring)!
            numberType = .number
        case .hour:
            value = DateComponents(hour: Int(substring))
            numberType = .dateComponent
        case .minute:
            value = DateComponents(minute: Int(substring))
            numberType = .dateComponent
        case .second:
            value = DateComponents(second: Int(substring))
            numberType = .dateComponent
        case .day:
            value = DateComponents(day: Int(substring))
            numberType = .dateComponent
        case .month:
            value = DateComponents(month: Int(substring))
            numberType = .dateComponent
        case .year:
            value = DateComponents(year: Int(substring))
            numberType = .dateComponent
        }

        return AJRExpressionToken.token(type: numberType, value: value)
    }

    internal func readOperator() throws -> AJRExpressionToken {
        let start = position
        
        while position < length && AJRExpressionParser.operatorSet.contains(string[position]) {
            position = string.index(after:position)
        }
        
        // Get the token from the stream
        let stringValue = String(string[start..<position])
        
        // See if it's an operator
        if let `operator` = AJROperator.operatorForToken(stringValue) {
            return AJRExpressionToken.token(type: .operator, value:`operator`)
        }
        
        // Fell through, so treat it as a literal. Note, we'll never be a constant, like we have in the readLiteral code, because constants are registered as literals, which means having a constant will cause us to enter the readLiteral code rather than the readOperator code.
        return AJRExpressionToken.token(type: .literal, value: stringValue)
    }
    
    internal func readLiteral() throws -> AJRExpressionToken {
        let start = position
    
        while position < length && (AJRExpressionParser.literalSet.contains(string[position]) || string[position] == "." || string[position] == "@") {
            position = string.index(after: position)
        }
    
        // Get the token from the stream
        let stringValue = String(string[start..<position])
    
        if position < length && string[position] == "(" {
            // We have a function declaration.
            let function = AJRFunction.function(for: stringValue)
    
            // Consume the opening parenthesis.
            position = string.index(after: position)
    
            if let function = function {
                return AJRExpressionToken.token(type: .function, value: function.copy())
            }
            throw AJRExpressionParserError.unknownFunction("Unknown function: \(stringValue)")
        }
    
        // See if it's an operator
        if let `operator` = AJROperator.operatorForToken(stringValue) {
            return AJRExpressionToken.token(type: .operator, value: `operator`)
        }
        if let constant = AJRConstant.constant(forToken: stringValue) {
            return AJRExpressionToken.token(type: .number, value: constant)
        }
    
        return AJRExpressionToken.token(type: .literal, value: stringValue)
    }

    public func readString(startCharacter: Character) throws -> AJRExpressionToken {
        var buffer = ""
        
        position = string.index(after: position) // skip past the opening quote
        while position < length {
            var character = string[position]
            if character == startCharacter {
                // Skip past the closing character
                position = string.index(after: position)
                break
            } else if character == "\\" {
                position = string.index(after: position)
                if position >= length {
                    break
                }
                character = string[position]
                if character == "n" {
                    character = "\n"
                } else if character == "r" {
                    character = "\r"
                } else if character == "e" {
                    character = "\u{1b}"
                } else if character == "t" {
                    character = "\t"
                } else if character == "s" {
                    character = " "
                } else if character == "'" {
                    character = "'"
                } else if character == "\"" {
                    character = "\""
                } else if character == "\\" {
                    character = "\\"
                } else {
                    character = "?"
                }
            }
            buffer.append(character)
            position = string.index(after: position)
        }
    
        return AJRExpressionToken.token(type: .string, value: buffer)
    }

    public func token(forValue value: Any?) throws -> AJRExpressionToken {
        var token: AJRExpressionToken? = nil
        
        if value == nil {
            token = AJRExpressionToken.token(type: .number, value: nil)
        } else if value is (any BinaryInteger) || value is (any BinaryFloatingPoint) {
            token = AJRExpressionToken.token(type: .number, value: value)
        } else if value is NSNumber {
            // This means we got a value via the Obj-C bridge.
            token = AJRExpressionToken.token(type: .number, value: value)
        } else if let value = value as? CustomStringConvertible {
            // A string, or something we're going to treat as a string.
            let stringValue = value.description
            if let constant = AJRConstant.constant(forToken: stringValue) {
                token = AJRExpressionToken.token(type: .number, value: constant)
            } else {
                token = AJRExpressionToken.token(type: .string, value: stringValue)
            }
        } else {
            throw AJRExpressionParserError.invalidState("Found a value we couldn't handle. This shouldn't happen: \(value!)")
        }
        
        return token!
    }
    
    internal func readArgument(expandingConstants expandConstants: Bool) throws -> AJRExpressionToken? {
        if position >= length {
            throw AJRExpressionParserError.missingModifier("No modifier to %%")
        }
    
        let character = string[position]
        position = string.index(after: position)
        if character == "d" {
            let arg : Int? = try nextArgument()
            return AJRExpressionToken.token(type: .number, value: arg)
        } else if character == "s" {
            let arg : String? = try nextArgument()
            return try token(forValue: arg)
        } else if character == "@" {
            let arg : AnyObject? = try nextArgument()
            return try token(forValue: arg)
        } else if character == "f" {
            let arg : Double? = try nextArgument()
            return AJRExpressionToken.token(type: .number, value: arg)
        } else {
            throw AJRExpressionParserError.invalidModifier("No modifier to %%: \(character)")
        }
    }

    public func nextToken() throws -> AJRExpressionToken? {
        // Ignore any leading whitespace
        try readWhitespace()
        
        if position < length {
            let character = string[position]
            if character == "(" {
                position = string.index(after: position)
                return AJRExpressionToken.token(type: .openParen)
            } else if character == ")" {
                position = string.index(after: position)
                return AJRExpressionToken.token(type: .closeParen)
            } else if character == "," {
                position = string.index(after: position)
                return AJRExpressionToken.token(type: .comma)
            } else if AJRExpressionParser.numberStartSet.contains(character) {
                return try readNumber()
            } else if character == "\"" || character == "'" {
                return try readString(startCharacter: character)
            } else if character == "%" {
                position = string.index(after: position)
                return try readArgument(expandingConstants: true)
            } else if AJRExpressionParser.literalStartSet.contains(character) {
                // Anything not identified above is a literal, which might turn out to be an operator
                // or a key, or something else.
                return try readLiteral()
            } else if AJRExpressionParser.operatorStartSet.contains(character) {
                return try readOperator()
            } else {
                throw AJRExpressionParserError.invalidCharacter("Unexpected character in input: \(character.unicodeScalars) '\(character)'")
            }
        }
        
        return nil
    }

    @objc(expressionWithError:)
    public func expression() throws -> AJRExpression {
        if _expression == nil {
            stack = [AJRExpressionStackFrame]()
            stack.append(AJRExpressionStackFrame())
    
            while let token = try nextToken() {
                // Used by a lot below...
                let frame = stack.last!
    
                switch token.type {
                    
                case .string: fallthrough
                case .number: fallthrough
                case .literal: fallthrough
                case .dateComponent: fallthrough
                case .operator:
                    if let value = token.value as? AJRExpression {
                        try frame.add(expression: value)
                    } else {
                        try frame.add(token: token)
                    }

                case .openParen:
                    stack.append(AJRExpressionStackFrame())
                    
                case .closeParen:
                    if stack.count <= 1 {
                        throw AJRExpressionParserError.unbalancedParentheses("Unbalanced parentheses in expression")
                    } else {
                        // Make sure this doesn't free itself when we remove it from the _stack.
                        stack.removeLast()
                        // And add the subframe's expression to the preceeding stack frame.
                        let expression : AJRExpression = try frame.expression()
                        expression.protected = true
                        try stack.last!.add(expression: expression)
                    }
                    
                case .function:
                    stack.append(AJRExpressionFunctionStackFrame(function: token.value as! AJRFunction))

                case .comma:
                    // Search the stack frame for a function expression
                    for index in stride(from: stack.count - 1, to: 0, by: -1) {
                        if let frame = stack[index] as? AJRExpressionFunctionStackFrame {
                            try frame.reduceArgument()
                            break;
                        }
                    }
                }
            }
    
            // Modified the below line to check for one than one item on the _stack.
            // If no parenthesis
            // were used then there will only be one item on the _stack.
            if stack.count > 1 {
                // frame = _stack.get(_stack.size() - 1);
                // _stack.remove(_stack.size() - 1);
                // _stack.get(_stack.size() - 1).applyFrame(frame);
                // This should be an error condition, because it means we opened a
                // parenthesis, but
                // didn't close it.
                throw AJRExpressionParserError.invalidInput("Illegal expression string, probably caused by an unclosed parenthesis.")
            }
    
            _expression = try stack.last!.expression()
            stack.removeAll()
        }
    
        // We either threw an error, or expression is now initialized
        return _expression!
    }
    
    // MARK: - Building Expressions

    @objc(expressionForString:error:)
    public class func expression(string: String) throws -> AJRExpression {
        return try AJRExpressionParser(string: string).expression()
    }

    @objc(expressionWithFormat:arguments:error:)
    public class func expression(format: String, _ arguments: [Any]) throws -> AJRExpression {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    public class func expression(format: String, _ arguments: Any?...) throws -> AJRExpression {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    // MARK: - Literals
    
    public class func addLiteralToken(_ token: String) -> Void {
        if token.count > 0 {
            literalSet.insert(charactersIn: token)
            literalStartSet.insert(character: token[token.startIndex])
        }
    }
    
    public class func addOperatorToken(_ token: String) -> Void {
        if token.rangeOfCharacter(from: literalStartSet) != nil {
            addLiteralToken(token)
        } else if token.count > 0 {
            operatorSet.insert(charactersIn: token)
            operatorStartSet.insert(character: token[token.startIndex])
        }
    }
    
}
