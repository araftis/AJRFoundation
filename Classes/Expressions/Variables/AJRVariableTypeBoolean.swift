/*
 AJRVariableTypeBoolean.swift
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

    public override func createDefaultValue() -> Any? {
        return true
    }

    open override func value(from string: String) throws -> Any? {
        return try Conversion.valueAsBool(string)
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? Bool {
            return value.description
        }
        throw ValueConversionError.valueIsNotABool("Input value to \(#function) is not a boolean.")
    }

}
