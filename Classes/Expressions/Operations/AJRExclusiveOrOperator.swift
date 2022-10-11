//
//  ExclusiveOrOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRExclusiveOrOperator : AJROperator, AJRBoolOperator {

    public func performBoolOperator(withLeft left: Bool, andRight right: Bool) throws -> Any? {
        let leftBool = left
        let rightBool = right
        return (leftBool && !rightBool) || (!leftBool && rightBool)
    }
    
}
