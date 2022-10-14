//
//  TrigonometryFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRSinFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return sin(double)
    }
    
}

@objcMembers
open class AJRCosFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return cos(double)
    }
    
}

@objcMembers
open class AJRTanFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return tan(double)
    }
    
}

@objcMembers
open class AJRArcsinFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return asin(double)
    }
    
}

@objcMembers
open class AJRArccosFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return acos(double)
    }
    
}

@objcMembers
open class AJRArctanFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCountMin: 1, max: 2)
        let value1 : Double = try context.float(at: 0)
        let returnValue : Double

        if context.argumentCount == 1 {
            returnValue = atan(value1)
        } else {
            let value2 : Double = try context.float(at: 1)
            returnValue = atan2(value1, value2)
        }

        return returnValue
    }
    
}
