//
//  AndOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRAndOperator : AJROperator, AJRBoolOperator, AJRCollectionOperator {

    public func performBoolOperator(withLeft left: Bool, andRight right: Bool) throws -> Any? {
        return left && right
    }

    public func performCollectionOperator(withLeft left: (any AJRCollection)?, andRight right: (any AJRCollection)?) throws -> Any? {
        if let left = left,
           let right = right {
            return left.intersect(right)
        }
        return []
    }

}
