//
//  AJRVariableTypeBoolean.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

public protocol AJRBooleanOperator {
    func performBooleanOperator(left: Bool, right: Bool) throws -> Any?
}

public protocol AJRBooleanUnaryOperator {
    func performBooleanOperator(value: Bool) throws -> Any?
}

@objcMembers
open class AJRVariableTypeBoolean : AJRVariableType {

    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRBooleanOperator {
            do {
                let leftValue = try Conversion.valueAsBool(left)
                let rightValue = try Conversion.valueAsBool(right)
                consumed = true
                return try op.performBooleanOperator(left: leftValue, right: rightValue)
            } catch (ValueConversionError.valueIsNotABool(_)) {
                // Swallow this exception
            }
        }
        return nil
    }

    open override func possiblyPerform(operator: AJROperator, value: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRBooleanUnaryOperator {
            do {
                let valueDouble = try Conversion.valueAsBool(value)
                consumed = true
                return try op.performBooleanOperator(value: valueDouble)
            } catch (ValueConversionError.valueIsNotABool(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }

}
