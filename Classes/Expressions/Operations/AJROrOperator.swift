//
//  OrOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objc
open class AJROrOperator : AJROperator, AJRBoolOperator {

    public func performBoolOperator(withLeft left: Bool, andRight right: Bool) throws -> Any? {
        return left || right
    }
    
}
