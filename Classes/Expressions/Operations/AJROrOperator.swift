//
//  OrOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJROrOperator : AJROperator, AJRBoolOperator, AJRCollectionOperator {

    public func performBoolOperator(withLeft left: Bool, andRight right: Bool) throws -> Any? {
        return left || right
    }
    
    public func performCollectionOperator(withLeft left: (any AJRCollection)?, andRight right: (any AJRCollection)?) throws -> Any? {
        if let left = left {
            if let right = right {
                return left.union(right)
            }
            return left
        }
        return right
    }

}
