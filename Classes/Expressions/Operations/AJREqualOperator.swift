//
//  EqualOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJREqualOperator : AJROperator {
    
    public override func performOperator(left: Any?, right: Any?, context: AJREvaluationContext) throws -> Any? {
        return AJRAnyEquals(left, right)
    }
    
}
