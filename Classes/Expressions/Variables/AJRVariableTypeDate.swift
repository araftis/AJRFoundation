//
//  AJRVariableDateType.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

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

}
