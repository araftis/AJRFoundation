//
//  File.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRNotEqualToOperator : AJROperator {
    
    public override func performOperator(left: Any?, right: Any?, context: AJREvaluationContext) throws -> Any? {
        return !AJREqual(try AJRExpression.value(left, with: context),
                         try AJRExpression.value(right, with: context))
    }
    
}
