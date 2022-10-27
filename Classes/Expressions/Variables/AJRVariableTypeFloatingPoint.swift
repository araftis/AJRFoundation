/*
AJRVariableTypeFloatingPoint.swift
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

    open override func createDefaultValue() -> Any? {
        return 0.0
    }

    open override func value(from string: String) throws -> Any? {
        let double : Double = try Conversion.valueAsFloatingPoint(string)
        return double
    }

    open override func string(from value: Any) throws -> Any? {
        if value is (any BinaryFloatingPoint) || value is (any BinaryInteger) {
            return try Conversion.valueAsString(value)
        }
        throw ValueConversionError.valueIsNotANumber("Input isn't a valid floating point value: \(value)")
    }

}
