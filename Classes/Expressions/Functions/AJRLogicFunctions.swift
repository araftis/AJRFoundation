//
//  LogicFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRIfFunction : AJRFunction {

    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount:2)
        var returnValue : Any? = nil
        
        let expressionResult : Bool = try boolean(at:0, withObject:object)
        if expressionResult {
            returnValue = try AJRExpression.evaluate(value: arguments[1], withObject: object)
        }
        
        return returnValue
    }

}

@objcMembers
open class AJRIfElseFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount:3)
        var returnValue : Any? = nil
        
        let expressionResult : Bool = try boolean(at:0, withObject:object)
        if expressionResult {
            returnValue = try AJRExpression.evaluate(value: arguments[1], withObject: object)
        } else {
            returnValue = try AJRExpression.evaluate(value: arguments[2], withObject: object)
        }

        return returnValue
    }
    
}

