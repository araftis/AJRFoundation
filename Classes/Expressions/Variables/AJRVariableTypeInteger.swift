//
//  AJRVariableTypeInteger.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

@objcMembers
open class AJRVariableTypeInteger : AJRVariableType {
    
    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, context: AJREvaluationContext, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRIntegerOperator {
            var leftInt : Int
            var rightInt : Int
            
            do {
                let resolvedLeft = try AJRExpression.value(left, with: context)
                let resolvedRight = try AJRExpression.value(right, with: context)
                let leftDouble : Double = try Conversion.valueAsFloatingPoint(resolvedLeft)
                if !leftDouble.isInteger {
                    return nil // We can stop, we don't have floating point, so defer to the double operators
                }
                let rightDouble : Double = try Conversion.valueAsFloatingPoint(resolvedRight)
                if !rightDouble.isInteger {
                    return nil
                }
                leftInt = try Conversion.valueAsInteger(resolvedLeft)
                rightInt = try Conversion.valueAsInteger(resolvedRight)
            } catch (ValueConversionError.valueIsNotANumber(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
            
            consumed = true
            return try op.performIntOperator(withLeft: leftInt, andRight: rightInt)
        }
        return nil
    }
    
    open override func possiblyPerform(operator: AJROperator, value: Any?, context: AJREvaluationContext, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRIntegerUnaryOperator {
            var valueInt : Int
            
            do {
                let resolvedValue = try AJRExpression.value(value, with: context)
                let valueDouble : Double = try Conversion.valueAsFloatingPoint(resolvedValue)
                if !valueDouble.isInteger {
                    return nil // We can stop, we don't have floating point, so defer to the double operators
                }
                valueInt = try Conversion.valueAsInteger(resolvedValue)
            } catch (ValueConversionError.valueIsNotANumber(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
            
            return try op.performIntOperator(withValue: valueInt)
        }
        return nil
    }
    
}
