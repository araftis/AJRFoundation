//
//  AndOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRAddOperator : AJROperator, AJRStringOperator, AJRIntegerOperator, AJRFloatingPointOperator, AJRDateOperator {

    public func performStringOperator(left: String?, right: String?) throws -> Any? {
        if left == nil {
            return right
        }
        if right == nil {
            return left
        }
        return left! + right!
    }
    
    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return left + right
    }
    
    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return left + right
    }
    
    public override func performOperator(value: Any?, context: AJREvaluationContext) throws -> Any? {
        return value
    }
    
    public func performDateOperator(left: AJRTimeZoneDate, right: AJRTimeZoneDate) throws -> Any? {
        throw AJROperatorError.invalidInput("Only date components can be added to dates.")
    }
    
    public func performDateOperator(left: AJRTimeZoneDate, right: DateComponents) throws -> Any? {
        return Calendar.current.date(byAdding: right, to: left, wrappingComponents: true)
    }
    
    public func performDateOperator(left: DateComponents, right: AJRTimeZoneDate) throws -> Any? {
        return Calendar.current.date(byAdding: left, to: right, wrappingComponents: true)
    }
    
    public func performDateOperator(left: DateComponents, right: DateComponents) throws -> Any? {
        return left.dateComponents(byAdding: right)
    }
    
}
