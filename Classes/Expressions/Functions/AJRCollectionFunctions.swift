/*
AJRCollectionFunctions.swift
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
//  CollectionFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRArrayFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        var array = Array<Any>()
        
        for argument in try context.getArguments() {
            if let value = try AJRExpression.evaluate(value: argument, with: context) {
                array.append(value)
            } else {
                array.append(NSNull.init())
            }
        }
        
        return array
    }
    
}

@objcMembers
open class AJRSetFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        var set = Set<AnyHashable>()
        
        for argument in try context.getArguments() {
            if let value = try AJRExpression.evaluate(value:argument, with: context) as? AnyHashable {
                set.insert(value)
            } else {
                _ = set.insert(NSNull.init()) // May fail, at which point we'll just skip?
            }
        }
        
        return set
    }
    
}

@objcMembers
open class AJRDictionaryFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        var dictionary = Dictionary<AnyHashable, Any>()

        if try context.getArguments().count % 2 != 0 {
            throw AJRFunctionError.invalidArgumentCount("You must pass an equal number of key/value pairs to dictionary().")
        }
        
        for x in stride(from: 0, to: try context.getArguments().count, by: 2) {
            if let key = try AJRExpression.evaluate(value: try context.getArgument(at: x), with: context) as? AnyHashable {
                let value = try AJRExpression.evaluate(value: try context.getArgument(at: x + 1), with: context)
                if value == nil {
                    dictionary[key] = NSNull.init()
                } else {
                    dictionary[key] = value
                }
            } else {
                throw AJRFunctionError.invalidArgument("The key arguments to dictionary() must be Hashable")
            }
        }
        
        return dictionary
    }
    
}

@objcMembers
open class AJRCountFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount:1)
        
        if let collection = try context.collection(at: 0) {
            return collection.count
        }
        throw AJRFunctionError.invalidArgument("Argument to count() isn't a collection.")
    }
    
}

@objcMembers
open class AJRContainsFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount:2)

        if let collection = try context.collection(at:0) {
            let value = try AJRExpression.evaluate(value: context.getArgument(at: 1), with: context)
            return collection.contains(equatable: value ?? NSNull())
        }
        throw AJRFunctionError.invalidArgument("First argument to contains() must be a collection.")
    }
    
}

@objcMembers
open class AJRIterateFunction : AJRFunction {
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount: 2)
        
        var newCollection : Any?
        var appender : (Any) -> Void
        
        if let collection = try context.collection(at: 0) {
            if let functionExpression = try context.getArgument(at: 1) as? AJRFunctionExpression {
                switch collection.semantic {
                case .unknown: fallthrough // Just treat the unknown case as ordered.
                case .valueOrdered: fallthrough
                case .keyValueOrdered:
                    var intermediate = Array<Any>()
                    appender = { (value : Any) in
                        intermediate.append(value)
                        newCollection = intermediate
                    }
                case .valueUnordered: fallthrough
                case .keyValueUnordered:
                    var intermediate = Set<AnyHashable>()
                    appender = { (value : Any) in
                        _ = intermediate.insert(value as! AnyHashable)
                        newCollection = intermediate
                    }
                }

                for argument in collection {
                    let localArguments : [AJREvaluation]
                    if let argument = argument as? (key:AnyHashable, value:Any) {
                        localArguments = [AJRLiteralValue(value: argument.value)]
                    } else {
                        localArguments = [AJRLiteralValue(value: argument)]
                    }
                    let localArgumentExpression = AJRFunctionExpression(function: functionExpression.function, arguments: localArguments)
                    appender(try localArgumentExpression.evaluate(with: context))
                }
            } else {
                throw AJRFunctionError.invalidArgument("Invalid argument to function \"\(try context.getFunctionName())\": \(try context.getArgument(at: 1)). Expected a function.")
            }
        }
        
        return newCollection ?? NSNull()
    }
    
}

@objcMembers
open class AJRFirstFunction : AJRFunction {

    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount:1)

        if let collection = try context.collection(at:0),
           collection.semantic == .valueOrdered {
            return collection.first ?? NSNull()
        }
        throw AJRFunctionError.invalidArgument("First argument to first() must be collection of ordered objects.")
    }

}

@objcMembers
open class AJRRestFunction : AJRFunction {

    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        try context.check(argumentCount:1)

        if let collection = try context.collection(at:0),
           let collection = collection as? Array<Any> {
            return Array<Any>(collection.dropFirst())
        }
        throw AJRFunctionError.invalidArgument("First argument to contains() must be an array.")
    }

}
