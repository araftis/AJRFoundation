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
