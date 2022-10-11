//
//  StringFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/17/18.
//

import Foundation

@objcMembers
open class AJRHasPrefixFunction : AJRFunction {

    open override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount: 2)
        let string = try self.string(at: 0, withObject: object)
        let prefix = try self.string(at: 1, withObject: object)
        
        return string.hasPrefix(prefix)
    }

}

@objcMembers
open class AJRHasSuffixFunction : AJRFunction {
    
    open override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount: 2)
        let string = try self.string(at: 0, withObject: object)
        let suffix = try self.string(at: 1, withObject: object)
        
        return string.hasSuffix(suffix)
    }
    
}
