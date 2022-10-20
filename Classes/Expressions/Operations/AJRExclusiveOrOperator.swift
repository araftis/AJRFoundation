//
//  ExclusiveOrOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRExclusiveOrOperator : AJROperator, AJRBooleanOperator, AJRCollectionOperator {

    public func performBooleanOperator(left: Bool, right: Bool) throws -> Any? {
        let leftBool = left
        let rightBool = right
        return (leftBool && !rightBool) || (!leftBool && rightBool)
    }

    public func performCollectionOperator(left: (any AJRCollection)?, right: (any AJRCollection)?) throws -> Any? {
        if let left = left {
            if let right = right {
                return left.symmetricDifference(right)
            }
            return left
        }
        return right
    }

}
