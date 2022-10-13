//
//  MiscFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRIsNullFunction : AJRFunction {
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let value = try AJRExpression.value(arguments[0], withObject: object)
        
        return value == nil || value is NSNull ? true : false;
    }
    
}

@objcMembers
open class AJRHelpFunction : AJRFunction {
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        var result : Any? = nil
        
        if let expression = arguments[0] as? AJRFunctionExpression {
            result = expression.function.prototype;
        } else {
            throw AJRFunctionError.invalidArgument("Parameter to help() must be a function")
        }
        
        return result
    }
    
}
