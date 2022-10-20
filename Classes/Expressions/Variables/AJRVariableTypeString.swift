//
//  AJRVariableTypeString.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

public protocol AJRStringOperator {
    func performStringOperator(left: String?, right: String?) throws -> Any?
}

public protocol AJRStringUnaryOperator {
    func performStringOperator(value: String) throws -> Any?
}

@objcMembers
open class AJRVariableTypeString : AJRVariableType {

    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRStringOperator {
            let leftString : String = try Conversion.valueAsString(left)
            let rightString : String = try Conversion.valueAsString(right)
            consumed = true
            return try op.performStringOperator(left: leftString, right: rightString)
        }
        return nil
    }

    open override func possiblyPerform(operator: AJROperator, value: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRStringUnaryOperator {
            let valueString : String = try Conversion.valueAsString(value)
            consumed = true
            return try op.performStringOperator(value: valueString)
        }
        return nil
    }

}
