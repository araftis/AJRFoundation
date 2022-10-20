/*
 AJROperator.swift
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

public enum AJROperatorError : Error {
    
    case unimplementedAbstract(String)
    case invalidInput(String)
    case unknownOperator(String)
    
}

@_cdecl("AJRStringFromOperatorPrecedence")
public func AJRStringFromOperatorPrecedence(_ precedence: AJROperator.Precedence) -> String? {
    if AJROperator.Precedence(rawValue: precedence.rawValue) != nil {
        return precedence.description
    }
    return nil
}

@_cdecl("AJROperatorPrecedenceFromString")
public func AJROperatorPrecedenceFromString(_ string: String) -> AJROperator.Precedence {
    if let e = AJROperator.Precedence(string: string) {
        return e
    } else {
        return .additive
    }
}

@objcMembers
open class AJROperator: NSObject, AJREquatable, NSCoding, AJRXMLCoding {

    @objc(AJROperatorPrecedence)
    public enum Precedence : Int, AJRXMLEncodableEnum {
        
        case conditional
        case logicalOr
        case logicalXor
        case logicalAnd
        case bitOr
        case bitXor
        case bitAnd
        case equality
        case relational
        case shift
        case additive
        case multiplicative
        case unary
        case postfix
        
        public var description: String {
            switch self {
            case .conditional: return "conditional"
            case .logicalOr: return "logicalOr"
            case .logicalXor: return "logicalXor"
            case .logicalAnd: return "logicalAnd"
            case .bitOr: return "bitOr"
            case .bitXor: return "bitXor"
            case .bitAnd: return "bitAnd"
            case .equality: return "equality"
            case .relational: return "relational"
            case .shift: return "shift"
            case .additive: return "additive"
            case .multiplicative: return "multiplicative"
            case .unary: return "unary"
            case .postfix: return "postfix"
            default:
                return "\(rawValue)"
            }
        }
    }

    /**
     The predence of the operator when determining which operations should be computer first. The higher the precedence, the sooner the operator if evaluated. Thus, add and subtract are lower than say multiply, which must happen first.
     */
    open private(set) var precedence : Precedence = .additive

    /**
     Used by operators that are generally not unary, but can act as unary in some circumstances. For example, consider, "5 - -5". In this case, the first '-' is the subtraction operator, while the second '-' is '-' acting as a unary operator.
     */
    open private(set) var canActAsUnary : Bool = false
    
    open private(set) var tokens = [String]()

    internal func append(token: String) {
        tokens.append(token)
    }

    open var preferredToken : String { return tokens[0] }
    
    private static var operatorsByToken = [String:AJROperator]()
    private static var operatorsByClassName = [String:AJROperator]()

    @objc
    open class func registerOperator(_ operatorClass : AJROperator.Type, properties: [String:Any]) -> Void {
        let instance = operatorClass.init()

        // Get it's tokens
        if let tokens = properties["operators"] as? [[String:Any]] {
            var tokenNames = [String]()
            for tokenProperties in tokens {
                if let tokenName = tokenProperties["name"] as? String {
                    tokenNames.append(tokenName)
                }
            }
            instance.tokens = tokenNames
        }

        // And its precedence
        instance.precedence = properties["precedence", .additive]

        // And whether it can act as a unary operator or not
        instance.canActAsUnary = properties["canActAsUnary", false]

        // And now cache by its class name
        operatorsByClassName[NSStringFromClass(operatorClass)] = instance

        // And also cache by its tokens.
        for name in instance.tokens {
            operatorsByToken[name] = instance
            AJRExpressionParser.addOperatorToken(name)
        }
    }
    
    @objc
    open class func operatorForToken(_ token: String) -> AJROperator? {
        return operatorsByToken[token]
    }
    
    @objc
    open class func allOperators() -> [AJROperator] {
        var allOperators = [AJROperator]()
        for op in operatorsByClassName.values {
            allOperators.append(op)
        }
        return allOperators
    }
    
    public required override init() {
    }
    
    // MARK: - Actions
    
    private func valueCanBeDateComponents(_ value: Any?) -> Bool {
        return value == nil || value is DateComponents
    }
    
    open func performOperator(left: Any?, right: Any?, context: AJREvaluationContext) throws -> Any? {
        
        for variableType in AJRVariableType.types {
            var consumed : Bool = false
            let result = try variableType.possiblyPerform(operator: self, left: left, right: right, context: context, consumed: &consumed)
            if consumed {
                return result
            }
        }
        
        if let op = self as? AJRDateOperator {
            if left is AJRTimeZoneDate && valueCanBeDateComponents(right) {
                let leftDate : AJRTimeZoneDate = left as! AJRTimeZoneDate
                if let rightDateComponents = try AJRExpression.valueAsDateComponents(right, with: context) {
                    return try op.performDateOperator(withLeft: leftDate, andRight: rightDateComponents)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(right ?? "nil")) into date components")
                }
            } else if valueCanBeDateComponents(left) && right is AJRTimeZoneDate {
                let rightDate : AJRTimeZoneDate = right as! AJRTimeZoneDate
                if let leftDateComponents : DateComponents = try AJRExpression.valueAsDateComponents(left, with: context) {
                    return try op.performDateOperator(withLeft: leftDateComponents, andRight: rightDate)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(right ?? "nil")) into date components")
                }
            } else if valueCanBeDateComponents(left) && valueCanBeDateComponents(right) {
                if let leftDateComponents : DateComponents = try AJRExpression.valueAsDateComponents(left, with: context),
                    let rightDateComponents : DateComponents = try AJRExpression.valueAsDateComponents(right, with: context) {
                    return try op.performDateOperator(withLeft: leftDateComponents, andRight: rightDateComponents)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(left ?? "nil")) or (\(right ?? "nil")) into date components")
                }
            } else if let leftDate = left as? AJRTimeZoneDate, let rightDate = right as? AJRTimeZoneDate {
                return try op.performDateOperator(withLeft: leftDate, andRight: rightDate)
            }
        }
        if let op = self as? AJRStringOperator {
            if left is String || right is String {
                let leftString = try AJRExpression.valueAsString(left, with: context)
                let rightString = try AJRExpression.valueAsString(right, with: context)
                return try op.performStringOperator(withLeft: leftString, andRight: rightString)
            }
        }
        if let op = self as? AJRDoubleOperator {
            if left is Double || right is Double {
                let leftDouble : Double = try AJRExpression.valueAsFloat(left, with: context)
                let rightDouble : Double = try AJRExpression.valueAsFloat(right, with: context)
                return try op.performDoubleOperator(withLeft: leftDouble, andRight: rightDouble)
            }
        }
//        if let op = self as? AJRIntegerOperator {
//            if left is Int || right is Int {
//                let leftInt : Int = try AJRExpression.valueAsInteger(left, with: context)
//                let rightInt : Int = try AJRExpression.valueAsInteger(right, with: context)
//                return try op.performIntOperator(withLeft: leftInt, andRight: rightInt)
//            }
//        }
        if let op = self as? AJRBoolOperator {
            if left is Bool || right is Bool {
                let leftBool = try AJRExpression.valueAsBool(left, with: context)
                let rightBool = try AJRExpression.valueAsBool(right, with: context)
                return try op.performBoolOperator(withLeft: leftBool, andRight: rightBool)
            }
        }
        if let op = self as? AJRCollectionOperator {
            // We use "or" here, because we'll turn a single object into a collection to match the other parameter
            if let left = try AJRExpression.valueAsCollection(left, with: context),
               let right = try AJRExpression.valueAsCollection(right, with: context) {
                return try op.performCollectionOperator(withLeft: left, andRight: right)
            }
        }
        throw AJROperatorError.unimplementedAbstract("Abstract method \(type(of:self)).\(#function) should be implemented")
    }
    
    open func performOperator(value: Any?, context: AJREvaluationContext) throws -> Any? {
        for variableType in AJRVariableType.types {
            var consumed = false
            let result = try variableType.possiblyPerform(operator: self, value: value, context: context, consumed: &consumed)
            if consumed {
                return result
            }
        }
        if let op = self as? AJRStringUnaryOperator {
            if value is String {
                let valueString = try AJRExpression.valueAsString(value, with: context)
                return try op.performStringOperator(withValue: valueString)
            }
        }
        if let op = self as? AJRFloatingPointUnaryOperator {
            if value is Double {
                let valueDouble : Double = try AJRExpression.valueAsFloat(value, with: context)
                return try op.performDoubleOperator(withValue: valueDouble)
            }
        }
//        if let op = self as? AJRIntegerUnaryOperator {
//            if value is Int {
//                let valueInt : Int = try AJRExpression.valueAsInteger(value, with: context)
//                return try op.performIntOperator(withValue: valueInt)
//            }
//        }
        if let op = self as? AJRBoolUnaryOperator {
            if value is Bool {
                let valueBool = try AJRExpression.valueAsBool(value, with: context)
                return try op.performBoolOperator(withValue: valueBool)
            }
        }
        throw AJROperatorError.unimplementedAbstract("Abstract method \(type(of:self)).\(#function) should be implemented")
    }
    
    // MARK: - Describing
    
    open override var description : String {
        return "<\(type(of:self)): \(self.preferredToken) (\(precedence))>"
    }
    
    // MARK: - Equatable
    
    open override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJROperator {
            return AJREqual(self.preferredToken, typed.preferredToken)
        }
        return false
    }
    
    public static func == (lhs: AJROperator, rhs: AJROperator) -> Bool {
        return lhs.isEqual(to:rhs)
    }

    // MARK: - NSCoding

    public func encode(with coder: NSCoder) {
        coder.encode(precedence.rawValue, forKey: "precedence")
        coder.encode(canActAsUnary, forKey: "canActAsUnary")
        coder.encode(preferredToken, forKey: "preferredToken")
        coder.encode(tokens, forKey: "tokens")
    }

    public required init?(coder: NSCoder) {
        if let precedence = Precedence(rawValue: coder.decodeInteger(forKey: "precedence")) {
            self.precedence = precedence
        } else {
            return nil
        }
        self.canActAsUnary = coder.decodeBool(forKey: "canActAsUnary")
        if let tokens = coder.decodeObject(forKey: "tokens") as? [String] {
            self.tokens = Array<String>(tokens)
        } else {
            return nil
        }
    }

    // MARK: - AJRXMLCoding

    internal class XMLCodingPlaceholder : NSObject, AJRXMLDecoding {

        var preferredToken : String?

        required public override init() {
            super.init()
        }

        func decode(with coder: AJRXMLCoder) {
            coder.decodeObject(forKey: "token") { value in
                if let value = value as? String {
                    self.preferredToken = value
                }
            }
        }

        func finalizeXMLDecoding() throws -> Any {
            if let token = preferredToken {
                if let op = AJROperator.operatorForToken(token) {
                    return op
                } else {
                    throw AJROperatorError.unknownOperator("Unknown operator in archive: \(token)")
                }
            } else {
                throw AJROperatorError.unknownOperator("Invalid operator in archive.")
            }
        }

    }

    public class func instantiate(with coder: AJRXMLCoder) -> Any {
        return XMLCodingPlaceholder()
    }

    public func encode(with coder: AJRXMLCoder) {
        coder.encode(preferredToken, forKey: "token")
    }

}

public protocol AJRIntegerOperator {
    
    func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any?
    
}

public protocol AJRDoubleOperator {
    
    func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any?
    
}

public protocol AJRBoolOperator {
    
    func performBoolOperator(withLeft left: Bool, andRight right: Bool) throws -> Any?
    
}

public protocol AJRStringOperator {
    
    func performStringOperator(withLeft left: String?, andRight right: String?) throws -> Any?
    
}

public protocol AJRCollectionOperator {
    
    func performCollectionOperator(withLeft left: (any AJRCollection)?, andRight right: (any AJRCollection)?) throws -> Any?
    
}

public protocol AJRDateOperator {
    
    func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: AJRTimeZoneDate) throws -> Any?
    func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: DateComponents) throws -> Any?
    func performDateOperator(withLeft left: DateComponents, andRight right: AJRTimeZoneDate) throws -> Any?
    func performDateOperator(withLeft left: DateComponents, andRight right: DateComponents) throws -> Any?

}

public protocol AJRIntegerUnaryOperator {
    
    func performIntOperator(withValue value: Int) throws -> Any?
    
}

public protocol AJRFloatingPointUnaryOperator {
    
    func performDoubleOperator(withValue value: Double) throws -> Any?
    
}

public protocol AJRBoolUnaryOperator {
    
    func performBoolOperator(withValue value: Bool) throws -> Any?
    
}

public protocol AJRStringUnaryOperator {
    
    func performStringOperator(withValue value: String) throws -> Any?
    
}

public func < (left: AJROperator.Precedence, right: AJROperator.Precedence) -> Bool {
    return left.rawValue < right.rawValue
}

public func <= (left: AJROperator.Precedence, right: AJROperator.Precedence) -> Bool {
    return left.rawValue <= right.rawValue
}

public func > (left: AJROperator.Precedence, right: AJROperator.Precedence) -> Bool {
    return left.rawValue > right.rawValue
}

public func >= (left: AJROperator.Precedence, right: AJROperator.Precedence) -> Bool {
    return left.rawValue >= right.rawValue
}
