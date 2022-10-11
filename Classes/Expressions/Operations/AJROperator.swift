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
    
}

@_cdecl("AJRStringFromOperatorPrecedence")
public func AJRStringFromOperatorPrecedence(_ precedence: AJROperator.Precedence) -> String? {
    return precedence.description
}

@_cdecl("AJROperatorPrecedenceFromString")
public func AJROperatorPrecedenceFromString(_ string: String) -> AJROperator.Precedence {
    if let e = AJROperator.Precedence(string: string) {
        return e
    } else {
        return .low
    }
}

@objcMembers
open class AJROperator: NSObject, AJREquatable {

    @objc(AJROperatorPrecedence)
    public enum Precedence : Int, AJRXMLEncodableEnum {
        
        case lowest = -20
        case lower = -10
        case low = 0
        case medium = 10
        case high = 20
        case higher = 30
        case unary = 40
        
        public var description: String {
            switch self {
            case .lowest: return "lowest"
            case .lower: return "lower"
            case .low: return "low"
            case .medium: return "medium"
            case .high: return "high"
            case .higher: return "higher"
            case .unary: return "unary"
            }
        }
    }
    
    open var precedence : Precedence {
        if let precedence = AJROperator.operatorsByClassName[NSStringFromClass(Self.self)]?.precedence {
            AJRLog.info("\(Self.self): \(precedence)")
            return precedence
        }
        return .low
    }
    open var canActAsUnary : Bool { return precedence == .unary } // Used by operators that are generally not unary, but can act as unary in some circumstances. For example, consider, "5 - -5". In this case, the first '-' is the subtraction operator, while the second '-' is '-' acting as a unary operator.
    
    open class var tokens : [String] {
        if let result = operatorsByClassName[NSStringFromClass(Self.self)]?.operators {
            return result
        }
        return []
    }
    open class var preferredToken : String { return tokens[0] }
    open var preferredToken : String { return type(of:self).preferredToken }
    
    private struct OperatorInfo {
        var instance : AJROperator
        var operators : [String]
        var precedence : Precedence = .low
    }
    
    private static var operatorsByToken = [String:OperatorInfo]()
    private static var operatorsByClassName = [String:OperatorInfo]()

    @objc
    open class func registerOperator(_ operatorClass : AJROperator.Type, properties: [String:Any]) -> Void {
        if let tokens = properties["operators"] as? [[String:Any]] {
            var tokenNames = [String]()
            for tokenProperties in tokens {
                if let tokenName = tokenProperties["name"] as? String {
                    tokenNames.append(tokenName)
                }
            }
            let precedence : Precedence
            if let raw = properties["precedence"] as? String,
               let possible = Precedence(string: raw) {
                precedence = possible
            } else {
                precedence = .low
            }
            let info = OperatorInfo(instance: operatorClass.init(), operators: tokenNames, precedence: precedence)
            operatorsByClassName[NSStringFromClass(operatorClass)] = info
            for name in tokenNames {
                operatorsByToken[name] = info
                AJRExpressionParser.addOperatorToken(name)
            }
        }
    }
    
    @objc
    open class func operatorForToken(_ token: String) -> AJROperator? {
        return operatorsByToken[token]?.instance
    }
    
    @objc
    open class func allOperators() -> [AJROperator] {
        var allOperators = [AJROperator]()
        for op in operatorsByClassName.values {
            allOperators.append(op.instance)
        }
        return allOperators
    }
    
    public required override init() {
    }
    
    // MARK: - Actions
    
    private func valueCanBeDateComponents(_ value: Any?) -> Bool {
        return value == nil || value is DateComponents
    }
    
    open func performOperator(withLeft left: Any?, andRight right: Any?) throws -> Any? {
        if let op = self as? AJRDateOperator {
            if left is AJRTimeZoneDate && valueCanBeDateComponents(right) {
                let leftDate : AJRTimeZoneDate = left as! AJRTimeZoneDate
                if let rightDateComponents = try AJRExpression.valueAsDateComponents(right) {
                    return try op.performDateOperator(withLeft: leftDate, andRight: rightDateComponents)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(right ?? "nil")) into date components")
                }
            } else if valueCanBeDateComponents(left) && right is AJRTimeZoneDate {
                let rightDate : AJRTimeZoneDate = right as! AJRTimeZoneDate
                if let leftDateComponents : DateComponents = try AJRExpression.valueAsDateComponents(left) {
                    return try op.performDateOperator(withLeft: leftDateComponents, andRight: rightDate)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(right ?? "nil")) into date components")
                }
            } else if valueCanBeDateComponents(left) && valueCanBeDateComponents(right) {
                if let leftDateComponents : DateComponents = try AJRExpression.valueAsDateComponents(left),
                    let rightDateComponents : DateComponents = try AJRExpression.valueAsDateComponents(right) {
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
                let leftString = try AJRExpression.valueAsString(left)
                let rightString = try AJRExpression.valueAsString(right)
                return try op.performStringOperator(withLeft: leftString, andRight: rightString)
            }
        }
        if let op = self as? AJRDoubleOperator {
            if left is Double || right is Double {
                let leftDouble : Double = try AJRExpression.valueAsFloat(left)
                let rightDouble : Double = try AJRExpression.valueAsFloat(right)
                return try op.performDoubleOperator(withLeft: leftDouble, andRight: rightDouble)
            }
        }
        if let op = self as? AJRIntOperator {
            if left is Int || right is Int {
                let leftInt : Int = try AJRExpression.valueAsInteger(left)
                let rightInt : Int = try AJRExpression.valueAsInteger(right)
                return try op.performIntOperator(withLeft: leftInt, andRight: rightInt)
            }
        }
        if let op = self as? AJRBoolOperator {
            if left is Bool || right is Bool {
                let leftBool = try AJRExpression.valueAsBool(left)
                let rightBool = try AJRExpression.valueAsBool(right)
                return try op.performBoolOperator(withLeft: leftBool, andRight: rightBool)
            }
        }
        if let op = self as? AJRCollectionOperator {
            // We use "or" here, because we'll turn a single object into a collection to match the other parameter
            if left is AJRUntypedCollection || right is AJRUntypedCollection {
                let leftCollection = try  AJRExpression.valueAsCollection(left)
                let rightCollection = try AJRExpression.valueAsCollection(right)
                return try op.performCollectionOperator(withLeft: leftCollection!, andRight: rightCollection)
            }
        }
        throw AJROperatorError.unimplementedAbstract("Abstract method \(type(of:self)).\(#function) should be implemented")
    }
    
    open func performOperator(withValue value: Any?) throws -> Any? {
        if let op = self as? AJRStringUnaryOperator {
            if value is String {
                let valueString = try AJRExpression.valueAsString(value)
                return try op.performStringOperator(withValue: valueString)
            }
        }
        if let op = self as? AJRDoubleUnaryOperator {
            if value is Double {
                let valueDouble : Double = try AJRExpression.valueAsFloat(value)
                return try op.performDoubleOperator(withValue: valueDouble)
            }
        }
        if let op = self as? AJRIntUnaryOperator {
            if value is Int {
                let valueInt : Int = try AJRExpression.valueAsInteger(value)
                return try op.performIntOperator(withValue: valueInt)
            }
        }
        if let op = self as? AJRBoolUnaryOperator {
            if value is Bool {
                let valueBool = try AJRExpression.valueAsBool(value)
                return try op.performBoolOperator(withValue: valueBool)
            }
        }
        throw AJROperatorError.unimplementedAbstract("Abstract method \(type(of:self)).\(#function) should be implemented")
    }
    
    // MARK: - Describing
    
    open override var description : String {
        return "<\(type(of:self)): \(type(of:self).preferredToken) (\(precedence))>"
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

    // MARK: - Utilties
    
    public func doOperation(left: Any?, right: Any?, asInteger: ((Int, Int) -> Int?)? = nil, asDouble: ((Double, Double) -> Double?)? = nil, asString: ((String, String) -> String?)? = nil) throws -> Any? {
        if asString != nil && left is String || right is String {
            let leftString = try AJRExpression.valueAsString(left)
            let rightString = try AJRExpression.valueAsString(right)
            return asString!(leftString, rightString)
        }
        // We failed to recognize any of the input types
        return nil
    }
}

public protocol AJRIntOperator {
    
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
    
    func performCollectionOperator(withLeft left: AJRUntypedCollection?, andRight right: AJRUntypedCollection?) throws -> Any?
    
}

public protocol AJRDateOperator {
    
    func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: AJRTimeZoneDate) throws -> Any?
    func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: DateComponents) throws -> Any?
    func performDateOperator(withLeft left: DateComponents, andRight right: AJRTimeZoneDate) throws -> Any?
    func performDateOperator(withLeft left: DateComponents, andRight right: DateComponents) throws -> Any?

}

public protocol AJRIntUnaryOperator {
    
    func performIntOperator(withValue value: Int) throws -> Any?
    
}

public protocol AJRDoubleUnaryOperator {
    
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
