/*
 AJRVariableTypeDate.swift
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

public protocol AJRDateOperator {
    func performDateOperator(left: AJRTimeZoneDate, right: AJRTimeZoneDate) throws -> Any?
    func performDateOperator(left: AJRTimeZoneDate, right: DateComponents) throws -> Any?
    func performDateOperator(left: DateComponents, right: AJRTimeZoneDate) throws -> Any?
    func performDateOperator(left: DateComponents, right: DateComponents) throws -> Any?
}

@objcMembers
open class AJRVariableTypeDate : AJRVariableType {

    private func valueCanBeDateComponents(_ value: Any?) -> Bool {
        return value == nil || value is DateComponents
    }

    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        if let op = self as? AJRDateOperator {
            if left is AJRTimeZoneDate && valueCanBeDateComponents(right) {
                let leftDate : AJRTimeZoneDate = left as! AJRTimeZoneDate
                if let rightDateComponents = try Conversion.valueAsDateComponents(right) {
                    consumed = true
                    return try op.performDateOperator(left: leftDate, right: rightDateComponents)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(right ?? "nil")) into date components")
                }
            } else if valueCanBeDateComponents(left) && right is AJRTimeZoneDate {
                let rightDate : AJRTimeZoneDate = right as! AJRTimeZoneDate
                if let leftDateComponents : DateComponents = try Conversion.valueAsDateComponents(left) {
                    consumed = true
                    return try op.performDateOperator(left: leftDateComponents, right: rightDate)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(right ?? "nil")) into date components")
                }
            } else if valueCanBeDateComponents(left) && valueCanBeDateComponents(right) {
                if let leftDateComponents : DateComponents = try Conversion.valueAsDateComponents(left),
                    let rightDateComponents : DateComponents = try Conversion.valueAsDateComponents(right) {
                    consumed = true
                    return try op.performDateOperator(left: leftDateComponents, right: rightDateComponents)
                } else {
                    throw AJROperatorError.invalidInput("Cannot convert value (\(left ?? "nil")) or (\(right ?? "nil")) into date components")
                }
            } else if let leftDate = left as? AJRTimeZoneDate, let rightDate = right as? AJRTimeZoneDate {
                consumed = true
                return try op.performDateOperator(left: leftDate, right: rightDate)
            }
        }

        consumed = false
        return nil
    }

    public override func createDefaultValue() -> Any? {
        return AJRTimeZoneDate(timeIntervalSinceNow: 0, timeZone: TimeZone.current)
    }

    open override func value(from string: String) throws -> Any? {
        return try Conversion.valueAsDate(string)
    }

    open override func string(from value: Any) throws -> Any? {
        let formatter = ISO8601DateFormatter()
        if let value = value as? Date {
            return formatter.string(from: value)
        }
        throw ValueConversionError.valueIsNotADate("Invalid input: \(value)")
    }

}
