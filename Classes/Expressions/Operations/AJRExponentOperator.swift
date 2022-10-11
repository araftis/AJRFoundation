//
//  ExponentOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRExponentOperator : AJROperator, AJRDoubleOperator, AJRIntOperator {
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return Int(pow(Double(left), Double(right)))
    }
    
    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return pow(left, right)
    }
    
}
