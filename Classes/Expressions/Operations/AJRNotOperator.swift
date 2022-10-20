//
//  NotOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRNotOperator : AJRUnaryOperator, AJRBooleanUnaryOperator {
    
    public func performBooleanOperator(value: Bool) throws -> Any? {
        return !value
    }
    
}
