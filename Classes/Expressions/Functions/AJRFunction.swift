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
open class AJRFunction : NSObject, AJREquatable, NSCoding {
    
    // MARK: - Properties
    
    private static var functions = [String:AJRFunction]()

    public class func registerFunction(_ function: AJRFunction.Type, properties: [String:Any]) -> Void {
        let function = function.init()

        function.name = properties["name", AJRFunction.failureSentinel]
        function.prototype = properties["prototype", AJRFunction.failureSentinel]

        if function.name != AJRFunction.failureSentinel
            && function.prototype != AJRFunction.failureSentinel {
            if functions[function.name] != nil {
                AJRLog.warning("A function by the name \"\(function.name)\" is already registered.")
                return
            }
            functions[function.name] = function
            AJRExpressionParser.addLiteralToken(function.name)
        }
    }
    
    public class var allFunctions : [AJRFunction] {
        var allFunctions = [AJRFunction]()

        for function in functions.values {
            allFunctions.append(function)
        }

        return allFunctions
    }

    private static var failureSentinel = "__FAILURE__"

    open private(set) var name: String = AJRFunction.failureSentinel
    open private(set) var prototype: String = AJRFunction.failureSentinel

    @objc(functionForName:)
    public class func function(for name: String) -> AJRFunction? {
        if let function = functions[name] {
            return function
        }
        return nil
    }
    
    // MARK: - Creation
    
    public required override init() {
        // Has to be here so we can call from our meta-type
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description: String {
        return "\(name)(...)"
    }
    
    // MARK: - Actions
    
    open func evaluate(with object: Any?, arguments: AJRFunctionArguments) throws -> Any? {
        throw AJRFunctionError.unimplementedAbstract("Abstract method \(type(of:self)).\(#function) should be implemented")
    }
    
    // MARK: - Equality
    
    public func equal(toFunction other: AJRFunction) -> Bool {
        return AJRAnyEquals(name, other.name)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
    }
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRFunction {
            return equal(toFunction: other)
        }
        return false
    }
    
    public static func == (lhs: AJRFunction, rhs: AJRFunction) -> Bool {
        return lhs.isEqual(to: rhs)
    }

    // MARK: - Copying

    open override func copy() -> Any {
        let new = type(of: self).init()
        new.name = name
        new.prototype = prototype
        return new
    }

    // MARK: - Hash

    open override var hash: Int {
        return name.hash
    }
    
    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let name = coder.decodeObject(forKey: "name") as? String {
            self.name = name
        } else {
            return nil
        }
        if let prototype = coder.decodeObject(forKey: "prototype") as? String {
            self.prototype = prototype
        } else {
            return nil
        }
        super.init()
    }

    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(prototype, forKey: "prototype")
    }

}
