//
//  AndOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRAndOperator : AJROperator, AJRBooleanOperator, AJRCollectionOperator {

    public func performBooleanOperator(left: Bool, right: Bool) throws -> Any? {
        return left && right
    }

    public func performCollectionOperator(left: (any AJRCollection)?, right: (any AJRCollection)?) throws -> Any? {
        if let left = left,
           let right = right {
            return left.intersect(right)
        }
        return []
    }

}
