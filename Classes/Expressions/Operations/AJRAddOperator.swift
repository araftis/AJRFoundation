//
//  AndOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRAddOperator : AJROperator, AJRStringOperator, AJRIntOperator, AJRDoubleOperator, AJRDateOperator {

    public func performStringOperator(withLeft left: String?, andRight right: String?) throws -> Any? {
        if left == nil {
            return right
        }
        if right == nil {
            return left
        }
        return left! + right!
    }
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return left + right
    }
    
    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return left + right
    }
    
    public override func performOperator(value: Any?, context: AJREvaluationContext) throws -> Any? {
        return value
    }
    
    public func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: AJRTimeZoneDate) throws -> Any? {
        throw AJROperatorError.invalidInput("Only date components can be added to dates.")
    }
    
    public func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: DateComponents) throws -> Any? {
        return Calendar.current.date(byAdding: right, to: left, wrappingComponents: true)
    }
    
    public func performDateOperator(withLeft left: DateComponents, andRight right: AJRTimeZoneDate) throws -> Any? {
        return Calendar.current.date(byAdding: left, to: right, wrappingComponents: true)
    }
    
    public func performDateOperator(withLeft left: DateComponents, andRight right: DateComponents) throws -> Any? {
        return left.dateComponents(byAdding: right)
    }
    
}
