//
//  CollectionFunctions.swift
//  radar-core
//
//  Created by Alex Raftis on 8/10/18.
//

import Foundation

@objcMembers
open class AJRArrayFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        let array = AJRMutableArray<Any>()
        
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
    
    public override func evaluate(with object: Any?) throws -> Any? {
        let set = AJRMutableSet<AnyHashable>()
        
        for argument in arguments {
            if let value = try AJRExpression.evaluate(value:argument, withObject:object) as? AnyHashable {
                _ = set.insert(value)
            } else {
                _ = set.insert(NSNull.init()) // May fail, at which point we'll just skip?
            }
        }
        
        return set
    }
    
}

@objcMembers
open class AJRDictionaryFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        let dictionary = AJRMutableDictionary<AnyHashable, Any>()

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
    
    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount:1)
        
        if let collection = try collection(at:0, withObject:object) {
            return collection.untypedCount
        }
        throw AJRFunctionError.invalidArgument("Argument to count() isn't a collection.")
    }
    
}

@objcMembers
open class AJRContainsFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount:2)

        if let collection = try self.collection(at:0, withObject:object) {
            let value = try AJRExpression.evaluate(value: arguments[1], withObject:object)
            return collection.untypedContains(value == nil ? NSNull.init() : value!)
        }
        throw AJRFunctionError.invalidArgument("First argument to contains() must be a collection.")
    }
    
}

@objcMembers
open class AJRIterateFunction : AJRFunction {
    
    public override func evaluate(with object: Any?) throws -> Any? {
        try check(argumentCount:2)
        
        var newCollection : Any?
        var appender : (Any) -> Void
        
        if let collection = try collection(at: 0, withObject: object) {
            let functionExpression = arguments[1] as? AJRFunctionExpression
            if functionExpression == nil {
                throw AJRFunctionError.invalidArgument("Invalid argument to function \"\(type(of:self).name)\": \(arguments[1]). Expected a function.")
            }
            
            switch collection.untypedCollectionSemantic {
            case .objectOrdered: fallthrough
            case .keyValueOrdered:
                newCollection = AJRMutableArray<Any>()
                appender = { (value : Any) in
                    (newCollection as! AJRMutableArray<Any>).append(value)
                }
            case .objectUnordered: fallthrough
            case .keyValueUnordered:
                newCollection = AJRMutableSet<AnyHashable>()
                appender = { (value : Any) in
                    _ = (newCollection as! AJRMutableSet<AnyHashable>).insert(value as! AnyHashable)
                }
            }
            
            if let function = functionExpression?.function {
                try collection.untypedEnumerate { (argument, stop) in
                    function.arguments = [AJRConstantExpression(value: argument)]
                    if let result = try function.evaluate(with: object) {
                        appender(result)
                    } else {
                        appender(NSNull.init())
                    }
                }
            }
        }
        
        return newCollection
    }
    
}
