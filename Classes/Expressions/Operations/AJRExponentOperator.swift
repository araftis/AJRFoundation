//
//  ExponentOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRExponentOperator : AJROperator, AJRFloatingPointOperator, AJRIntegerOperator {
    
    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return Int(pow(Double(left), Double(right)))
    }
    
    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return pow(left, right)
    }
    
}
