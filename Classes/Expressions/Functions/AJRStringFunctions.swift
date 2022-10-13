//
//  StringFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/17/18.
//

import Foundation

@objcMembers
open class AJRHasPrefixFunction : AJRFunction {

    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 2)
        let string = try arguments.string(at: 0, withObject: object)
        let prefix = try arguments.string(at: 1, withObject: object)
        
        return string.hasPrefix(prefix)
    }

}

@objcMembers
open class AJRHasSuffixFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 2)
        let string = try arguments.string(at: 0, withObject: object)
        let suffix = try arguments.string(at: 1, withObject: object)
        
        return string.hasSuffix(suffix)
    }
    
}
