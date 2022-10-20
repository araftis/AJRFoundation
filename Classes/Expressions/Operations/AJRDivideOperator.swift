//
//  DivideOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRDivideOperator : AJROperator, AJRIntegerOperator, AJRDoubleOperator {
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        if right == 0 {
            throw AJRFunctionError.invalidArgument("Attempt to divide by 0.")
        }
        return Double(left) / Double(right) // Always promote to Double, because we're a pretty loose type system
    }
    
    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        if right == 0.0 {
            throw AJRFunctionError.invalidArgument("Attempt to divide by 0.0.")
        }
        return left / right
    }
    
}
