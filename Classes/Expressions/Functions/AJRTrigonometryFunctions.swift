//
//  TrigonometryFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objc
open class AJRSinFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return sin(double)
    }
    
}

@objc
open class AJRCosFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return cos(double)
    }
    
}

@objc
open class AJRTanFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return tan(double)
    }
    
}

@objc
open class AJRArcsinFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return asin(double)
    }
    
}

@objc
open class AJRArccosFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return acos(double)
    }
    
}

@objc
open class AJRArctanFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCountMin: 1, max: 2)
        let value1 : Double = try float(at: 0, withObject: object)
        let returnValue : Double

        if arguments.count == 1 {
            returnValue = atan(value1)
        } else {
            let value2 : Double = try float(at: 1, withObject: object)
            returnValue = atan2(value1, value2)
        }

        return returnValue
    }
    
}
