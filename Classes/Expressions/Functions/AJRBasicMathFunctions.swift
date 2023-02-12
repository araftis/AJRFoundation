/*
 AJRBasicMathFunctions.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  BasicMathFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRSquareRootFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return sqrt(double)
    }
    
}

@objcMembers
open class AJRCeilingFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return ceil(double)
    }
    
}

@objcMembers
open class AJRFloorFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return floor(double)
    }
    
}

@objcMembers
open class AJRRoundFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return round(double)
    }
    
}

@objcMembers
open class AJRRemainderFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 2)
        let x : Double = try context.float(at: 0)
        let y : Double = try context.float(at: 1)
        return remainder(x, y)
    }
    
}

@objcMembers
open class AJRMinFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
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
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
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
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let value: Double = try context.float(at: 0)
        return abs(value)
    }
    
}

@objcMembers
open class AJRLogFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return log10(double)
    }
    
}

@objcMembers
open class AJRLnFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return log(double)
    }
    
}
