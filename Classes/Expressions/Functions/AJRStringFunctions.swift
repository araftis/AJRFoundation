//
//  StringFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/17/18.
//

import Foundation

@objcMembers
open class AJRHasPrefixFunction : AJRFunction {

    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 2)
        let string = try context.string(at: 0)
        let prefix = try context.string(at: 1)
        
        return string.hasPrefix(prefix)
    }

}

@objcMembers
open class AJRHasSuffixFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 2)
        let string = try context.string(at: 0)
        let suffix = try context.string(at: 1)
        
        return string.hasSuffix(suffix)
    }
    
}
