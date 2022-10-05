//
//  BasicMathFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objc
open class AJRSquareRootFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return sqrt(double)
    }
    
}

@objc
open class AJRCeilingFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return ceil(double)
    }
    
}

@objc
open class AJRFloorFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return floor(double)
    }
    
}

@objc
open class AJRRoundFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return round(double)
    }
    
}

@objc
open class AJRRemainderFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 2)
        let x : Double = try float(at: 0, withObject: object)
        let y : Double = try float(at: 1, withObject: object)
        return remainder(x, y)
    }
    
}

@objc
open class AJRMinFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCountMin: 1)
        
        var value : Double = try float(at:0, withObject:object)
        for x in 1 ..< arguments.count {
            let nextValue : Double = try float(at: x, withObject: object)
            if nextValue < value {
                value = nextValue
            }
        }
        
        return value
    }
    
}

@objc
open class AJRMaxFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCountMin: 1)
        
        var value : Double = try float(at:0, withObject:object)
        for x in 1 ..< arguments.count {
            let nextValue : Double = try float(at: x, withObject: object)
            if nextValue > value {
                value = nextValue
            }
        }
        
        return value
    }
    
}

@objc
open class AJRAbsFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let value: Double = try float(at: 0, withObject: object)
        return abs(value)
    }
    
}

@objc
open class AJRLogFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return log10(double)
    }
    
}

@objc
open class AJRLnFunction : AJRFunction {
    
    open override func evaluate(withObject object: Any?) throws -> Any? {
        try check(argumentCount: 1)
        let double : Double = try float(at: 0, withObject: object)
        return log(double)
    }
    
}
