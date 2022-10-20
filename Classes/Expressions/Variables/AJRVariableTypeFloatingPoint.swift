//
//  AJRVariableTypeFloatingPoint.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

public protocol AJRFloatingPointOperator {
    func performFloatingPointOperator(left: Double, right: Double) throws -> Any?
}

public protocol AJRFloatingPointUnaryOperator {
    func performFloatingPointOperator(value: Double) throws -> Any?
}

@objcMembers
open class AJRVariableTypeFloatingPoint : AJRVariableType {

    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRFloatingPointOperator {
            do {
                let leftDouble : Double = try Conversion.valueAsFloatingPoint(left)
                let rightDouble : Double = try Conversion.valueAsFloatingPoint(right)
                consumed = true
                return try op.performFloatingPointOperator(left: leftDouble, right: rightDouble)
            } catch (ValueConversionError.valueIsNotANumber(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }

    open override func possiblyPerform(operator: AJROperator, value: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRFloatingPointUnaryOperator {
            do {
                let valueDouble : Double = try Conversion.valueAsFloatingPoint(value)
                consumed = true
                return try op.performFloatingPointOperator(value: valueDouble)
            } catch (ValueConversionError.valueIsNotANumber(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }

}
