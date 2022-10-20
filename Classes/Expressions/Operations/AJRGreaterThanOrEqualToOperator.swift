//
//  GreaterThanOrEqualToOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRGreaterThanOrEqualToOperator : AJROperator, AJRIntegerOperator, AJRFloatingPointOperator, AJRStringOperator {
    
    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return left >= right
    }
    
    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return left >= right
    }
    
    public func performStringOperator(left: String?, right: String?) throws -> Any? {
        if left == nil && right == nil {
            return true
        }
        if left == nil && right != nil {
            return false
        }
        if left != nil && right == nil {
            return true
        }
        return left! >= right!
    }
    
}
