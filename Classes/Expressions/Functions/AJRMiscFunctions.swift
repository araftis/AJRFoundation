//
//  MiscFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objc
open class AJRNullFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        return nil
    }
    
}

@objc
open class AJRIsNullFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let value = try AJRExpression.value(arguments[0], withObject: object)
        
        return value == nil || value is NSNull ? true : false;
    }
    
}

@objc
open class AJRHelpFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        var result : Any? = nil
        
        if let expression = arguments[0] as? AJRFunctionExpression {
            result = type(of:expression.function).prototype;
        } else {
            throw AJRFunctionError.invalidArgument("Parameter to help() must be a function")
        }
        
        return result
    }
    
}
