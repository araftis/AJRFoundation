/*
AJRVariableTypeInteger.swift
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
