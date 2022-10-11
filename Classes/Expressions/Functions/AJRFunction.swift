/*
 AJRFunction.swift
 AJRFoundation

 Copyright © 2021, AJ Raftis and AJRFoundation authors
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

import Foundation

public enum AJRFunctionError : Error {

    case invalidArgumentCount(String)
    case invalidArgument(String)
    case unitTesting(String)
    case unimplementedAbstract(String)
    case duplicateFunction(String)
    
}

@objcMembers
open class AJRFunction : NSObject, AJREquatable {
    
    // MARK: - Properties
    
    open var arguments = [AJRExpression]()
    
    private static var functions = [String:AJRFunction.Type]()

    public class func registerFunction(_ function: AJRFunction.Type, properties: [String:Any]) -> Void {
        if let name = properties["name"] as? String {
            if functions[name] != nil {
                AJRLog.warning("A function by the name \"\(name)\" is already registered.")
                return
            }
            if name != AJRFunction.failureSentinel {
                functions[name] = function
            }
            if name != AJRFunction.failureSentinel {
                AJRExpressionParser.addLiteralToken(name)
            }
        }
    }
    
    public class var allFunctions : [AJRFunction.Type] {
        var allFunctions = [AJRFunction.Type]()

        for key in functions.keys {
            allFunctions.append(functions[key]!)
        }

        return allFunctions
    }
    
    private static var failureSentinel = "__FAILURE__"
    open class var name: String {
        AJRLog.warning("Subclasses AJRFunction should override name: \(self)")
        return AJRFunction.failureSentinel
    }
    public var name: String { return type(of:self).name }
    open class var prototype: String {
        AJRLog.warning("Abstract property \(#function) not implemented by \(self)")
        return AJRFunction.failureSentinel
    }
    
    public class func functionClass(forName name: String) -> AJRFunction.Type? {
        return functions[name]
    }
    
    // MARK: - Creation
    
    public required override init() {
        // Has to be here so we can call from our meta-type
    }
    
    // MARK: - Arguments
    
    public func append(argument: AJRExpression) -> Void {
        arguments.append(argument)
    }

    // MARK: - CustomStringConvertible
    
    public override var description: String {
        return ""
    }
    
    // MARK: - Actions
    
    open func evaluate(with object: Any?) throws -> Any? {
        throw AJRFunctionError.unimplementedAbstract("Abstract method \(type(of:self)).\(#function) should be implemented")
    }
    
    // MARK: - Utilities
    
    public func check(argumentCount count: Int) throws -> Void {
        if arguments.count != count {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(type(of:self).name) expects \(count) argument\(count == 1 ? "" : "s")")
        }
    }
    
    public func check(argumentCountMin min: Int) throws -> Void {
        if arguments.count < min {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(type(of:self).name) expects at least \(min) argument\(min == 1 ? "" : "s")")
        }
    }
    
    public func check(argumentCountMin min: Int, max: Int) throws -> Void {
        if arguments.count < min || arguments.count > max {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(type(of:self).name) expects between \(min) and \(max) arguments")
        }
    }
    
    public func check(argumentCountMax max: Int) throws -> Void {
        if arguments.count > max {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(type(of:self).name) expects at most \(max) argument\(max == 1 ? "" : "s")")
        }
    }
    
    public func string(at index: Int, withObject object: Any?) throws -> String {
        return try AJRExpression.valueAsString(arguments[index], withObject: object)
    }
    
    public func date(at index: Int, withObject object: Any?) throws -> AJRTimeZoneDate? {
        return try AJRExpression.valueAsDate(arguments[index], withObject: object)
    }
    
    public func boolean(at index: Int, withObject object: Any?) throws -> Bool {
        return try AJRExpression.valueAsBool(arguments[index], withObject: object)
    }
    
    public func integer<T: BinaryInteger>(at index: Int, withObject object: Any?) throws -> T {
        return try AJRExpression.valueAsInteger(arguments[index], withObject: object)
    }

    public func float<T: BinaryFloatingPoint>(at index: Int, withObject object: Any?) throws -> T {
        return try AJRExpression.valueAsFloat(arguments[index], withObject: object)
    }
    
    public func collection(at index: Int, withObject object: Any?) throws -> AJRUntypedCollection? {
        return try AJRExpression.valueAsCollection(arguments[index], withObject: object)
    }
    
    // MARL: - Equality
    
    public func equal(toFunction other: AJRFunction) -> Bool {
        return AJREqual(arguments, other.arguments)
    }
    
    public override func isEqual(to other: Any?) -> Bool {
        if type(of:self) == type(of:other) {
            return equal(toFunction: other as! AJRFunction)
        }
        return false
    }
    
    public static func == (lhs: AJRFunction, rhs: AJRFunction) -> Bool {
        return lhs.isEqual(to:rhs)
    }
    
}
