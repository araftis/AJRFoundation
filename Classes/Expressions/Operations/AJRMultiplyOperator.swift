//
//  MultiplyOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRMultiplyOperator : AJROperator, AJRIntegerOperator, AJRFloatingPointOperator {
    
    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return left * right
    }
    
    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return left * right
    }
    
}
