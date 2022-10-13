//
//  CollectionFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRArrayFunction : AJRFunction {
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        var array = Array<Any>()
        
        for argument in arguments {
            if let value = try AJRExpression.evaluate(value: argument, withObject: object) {
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
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        var set = Set<AnyHashable>()
        
        for argument in arguments {
            if let value = try AJRExpression.evaluate(value:argument, withObject:object) as? AnyHashable {
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
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        var dictionary = Dictionary<AnyHashable, Any>()

        if arguments.count % 2 != 0 {
            throw AJRFunctionError.invalidArgumentCount("You must pass an equal number of key/value pairs to dictionary().")
        }
        
        for x in stride(from: 0, to: arguments.count, by: 2) {
            if let key = try AJRExpression.evaluate(value: arguments[x], withObject: object) as? AnyHashable {
                let value = try AJRExpression.evaluate(value: arguments[x + 1], withObject: object)
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
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount:1)
        
        if let collection = try arguments.collection(at:0, withObject:object) {
            return collection.count
        }
        throw AJRFunctionError.invalidArgument("Argument to count() isn't a collection.")
    }
    
}

@objcMembers
open class AJRContainsFunction : AJRFunction {
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount:2)

        if let collection = try arguments.collection(at:0, withObject:object) {
            let value = try AJRExpression.evaluate(value: arguments[1], withObject:object)
            return collection.contains(equatable: value == nil ? NSNull.init() : value!)
        }
        throw AJRFunctionError.invalidArgument("First argument to contains() must be a collection.")
    }
    
}

@objcMembers
open class AJRIterateFunction : AJRFunction {
    
    public override func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        try arguments.check(argumentCount:2)
        
        var newCollection : Any?
        var appender : (Any) -> Void
        
        if let collection = try arguments.collection(at: 0, withObject: object) {
            if let functionExpression = arguments[1] as? AJRFunctionExpression {
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
                    let localArguments : [AJRExpression]
                    if let argument = argument as? (key:AnyHashable, value:Any) {
                        localArguments = [AJRConstantExpression(value: argument.value)]
                    } else {
                        localArguments = [AJRConstantExpression(value: argument)]
                    }
                    let localArgumentExpression = AJRFunctionExpression(function: functionExpression.function, arguments: localArguments)
                    if let result = try localArgumentExpression.evaluate(with: object) {
                        appender(result)
                    } else {
                        appender(NSNull.init())
                    }
                }
            } else {
                throw AJRFunctionError.invalidArgument("Invalid argument to function \"\(name)\": \(arguments[1]). Expected a function.")
            }
        }
        
        return newCollection
    }
    
}
