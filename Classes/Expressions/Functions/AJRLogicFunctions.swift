//
//  LogicFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRIfFunction : AJRFunction {

    public override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount:2)
        var returnValue : Any? = nil
        
        let expressionResult : Bool = try context.boolean(at: 0)
        if expressionResult {
            returnValue = try AJRExpression.evaluate(value: try context.getArgument(at: 1), with: context)
        }
        
        return returnValue
    }

}

@objcMembers
open class AJRIfElseFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 3)
        var returnValue : Any? = nil
        
        let expressionResult : Bool = try context.boolean(at: 0)
        if expressionResult {
            returnValue = try AJRExpression.evaluate(value: try context.getArgument(at: 1), with: context)
        } else {
            returnValue = try AJRExpression.evaluate(value: try context.getArgument(at: 2), with: context)
        }

        return returnValue
    }
    
}

