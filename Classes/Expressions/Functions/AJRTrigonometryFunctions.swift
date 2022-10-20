/*
AJRTrigonometryFunctions.swift
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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
//  TrigonometryFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRSinFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return sin(double)
    }
    
}

@objcMembers
open class AJRCosFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return cos(double)
    }
    
}

@objcMembers
open class AJRTanFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return tan(double)
    }
    
}

@objcMembers
open class AJRArcsinFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return asin(double)
    }
    
}

@objcMembers
open class AJRArccosFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 1)
        let double : Double = try context.float(at: 0)
        return acos(double)
    }
    
}

@objcMembers
open class AJRArctanFunction : AJRFunction {
    
    open override func evaluate(with context: AJREvaluationContext) throws -> Any {
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
