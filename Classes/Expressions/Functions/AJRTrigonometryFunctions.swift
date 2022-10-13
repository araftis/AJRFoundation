//
//  TrigonometryFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRSinFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return sin(double)
    }
    
}

@objcMembers
open class AJRCosFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return cos(double)
    }
    
}

@objcMembers
open class AJRTanFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return tan(double)
    }
    
}

@objcMembers
open class AJRArcsinFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return asin(double)
    }
    
}

@objcMembers
open class AJRArccosFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount: 1)
        let double : Double = try arguments.float(at: 0, withObject: object)
        return acos(double)
    }
    
}

@objcMembers
open class AJRArctanFunction : AJRFunction {
    
    open override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCountMin: 1, max: 2)
        let value1 : Double = try arguments.float(at: 0, withObject: object)
        let returnValue : Double

        if arguments.count == 1 {
            returnValue = atan(value1)
        } else {
            let value2 : Double = try arguments.float(at: 1, withObject: object)
            returnValue = atan2(value1, value2)
        }

        return returnValue
    }
    
}
