//
//  BasicMathFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRSquareRootFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return sqrt(double)
    }
    
}

@objcMembers
open class AJRCeilingFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return ceil(double)
    }
    
}

@objcMembers
open class AJRFloorFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return floor(double)
    }
    
}

@objcMembers
open class AJRRoundFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return round(double)
    }
    
}

@objcMembers
open class AJRRemainderFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 2)
        let x : Double = try context.float(at: 0)
        let y : Double = try context.float(at: 1)
        return remainder(x, y)
    }
    
}

@objcMembers
open class AJRMinFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCountMin: 1)
        
        var value : Double = try context.float(at: 0)
        for x in 1 ..< context.argumentCount {
            let nextValue : Double = try context.float(at: x)
            if nextValue < value {
                value = nextValue
            }
        }
        
        return value
    }
    
}

@objcMembers
open class AJRMaxFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCountMin: 1)
        
        var value : Double = try context.float(at:0)
        for x in 1 ..< context.argumentCount {
            let nextValue : Double = try context.float(at: x)
            if nextValue > value {
                value = nextValue
            }
        }
        
        return value
    }
    
}

@objcMembers
open class AJRAbsFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let value: Double = try context.float(at: 0)
        return abs(value)
    }
    
}

@objcMembers
open class AJRLogFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return log10(double)
    }
    
}

@objcMembers
open class AJRLnFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return log(double)
    }
    
}
