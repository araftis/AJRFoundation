//
//  MultiplyOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objc
open class AJRMultiplyOperator : AJROperator, AJRIntOperator, AJRDoubleOperator {
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return left * right
    }
    
    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return left * right
    }
    
}
