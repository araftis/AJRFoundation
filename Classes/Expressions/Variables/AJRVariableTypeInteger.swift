//
//  AJRVariableTypeInteger.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

public protocol AJRIntegerOperator {
    func performIntegerOperator(left: Int, right: Int) throws -> Any?
}

public protocol AJRIntegerUnaryOperator {
    func performIntegerOperator(value: Int) throws -> Any?
}

@objcMembers
open class AJRVariableTypeInteger : AJRVariableType {
    
    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRIntegerOperator {
            do {
                let leftDouble : Double = try Conversion.valueAsFloatingPoint(left)
                if !leftDouble.isInteger {
                    return nil // We can stop, we don't have floating point, so defer to the double operators
                }
                let rightDouble : Double = try Conversion.valueAsFloatingPoint(right)
                if !rightDouble.isInteger {
                    return nil
                }
                let leftInt : Int = try Conversion.valueAsInteger(left)
                let rightInt : Int = try Conversion.valueAsInteger(right)
                consumed = true
                return try op.performIntegerOperator(left: leftInt, right: rightInt)
            } catch (ValueConversionError.valueIsNotANumber(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }
    
    open override func possiblyPerform(operator: AJROperator, value: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRIntegerUnaryOperator {
            do {
                let valueDouble : Double = try Conversion.valueAsFloatingPoint(value)
                if !valueDouble.isInteger {
                    return nil // We can stop, we don't have floating point, so defer to the double operators
                }
                let valueInt : Int = try Conversion.valueAsInteger(value)
                consumed = true
                return try op.performIntegerOperator(value: valueInt)
            } catch (ValueConversionError.valueIsNotANumber(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }
    
}
