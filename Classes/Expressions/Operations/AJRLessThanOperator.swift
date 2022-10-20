//
//  LessThanOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRLessThanOperator : AJROperator, AJRIntegerOperator, AJRDoubleOperator, AJRStringOperator {
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return left < right
    }
    
    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return left < right
    }
    
    public func performStringOperator(withLeft left: String?, andRight right: String?) throws -> Any? {
        if left == nil && right == nil {
            return false
        }
        if left == nil && right != nil {
            return true
        }
        if left != nil && right == nil {
            return false
        }
        return left! < right!
    }
    
}
