//
//  BasicMathFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRSquareRootFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return sqrt(double)
    }
    
}

@objcMembers
open class AJRCeilingFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return ceil(double)
    }
    
}

@objcMembers
open class AJRFloorFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return floor(double)
    }
    
}

@objcMembers
open class AJRRoundFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return round(double)
    }
    
}

@objcMembers
open class AJRRemainderFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 2)
        let x : Double = try arguments.float(at: 0, withObject: object)
        let y : Double = try arguments.float(at: 1, withObject: object)
        return remainder(x, y)
    }
    
}

@objcMembers
open class AJRMinFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCountMin: 1)
        
        var value : Double = try arguments.float(at:0, withObject:object)
        for x in 1 ..< arguments.count {
            let nextValue : Double = try arguments.float(at: x, withObject: object)
            if nextValue < value {
                value = nextValue
            }
        }
        
        return value
    }
    
}

@objcMembers
open class AJRMaxFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCountMin: 1)
        
        var value : Double = try arguments.float(at:0, withObject:object)
        for x in 1 ..< arguments.count {
            let nextValue : Double = try arguments.float(at: x, withObject: object)
            if nextValue > value {
                value = nextValue
            }
        }
        
        return value
    }
    
}

@objcMembers
open class AJRAbsFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let value: Double = try arguments.float(at: 0, withObject: object)
        return abs(value)
    }
    
}

@objcMembers
open class AJRLogFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return log10(double)
    }
    
}

@objcMembers
open class AJRLnFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return log(double)
    }
    
}
