//
//  NotOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objc
open class AJRNotOperator : AJRUnaryOperator, AJRBoolUnaryOperator {
    
    public func performBoolOperator(withValue value: Bool) throws -> Any? {
        return !value
    }
    
}
