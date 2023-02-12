/*
 AJRArguments.swift
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

import Foundation

@objcMembers
open class AJRArguments : NSObject, NSCoding, Sequence, AJRXMLCoding {

    open var arguments : [AJREvaluation]
    weak open var functionExpression : AJRFunctionExpression?

    internal var name : String {
        return functionExpression?.function.name ?? "***DEALLOCATED***"
    }

    required public override init() {
        self.arguments = []
        super.init()
    }

    public init(arguments: [AJREvaluation]? = nil) {
        if let arguments = arguments {
            self.arguments = arguments
        } else {
            self.arguments = [AJREvaluation]()
        }
        super.init()
    }

    open func append(argument: AJREvaluation) {
        arguments.append(argument)
    }

    open var count : Int {
        return arguments.count
    }

    public subscript(index: Int) -> AJREvaluation {
        return arguments[index];
    }

    public func enumerated() -> EnumeratedSequence<[AJREvaluation]> {
        return arguments.enumerated()
    }

    public func makeIterator() -> some IteratorProtocol {
        return arguments.makeIterator()
    }

    // MARK: - Utilities

    public func check(argumentCount count: Int) throws -> Void {
        if arguments.count != count {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(name) expects \(count) argument\(count == 1 ? "" : "s")")
        }
    }

    public func check(argumentCountMin min: Int) throws -> Void {
        if arguments.count < min {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(name) expects at least \(min) argument\(min == 1 ? "" : "s")")
        }
    }

    public func check(argumentCountMin min: Int, max: Int) throws -> Void {
        if arguments.count < min || arguments.count > max {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(name) expects between \(min) and \(max) arguments")
        }
    }

    public func check(argumentCountMax max: Int) throws -> Void {
        if arguments.count > max {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(name) expects at most \(max) argument\(max == 1 ? "" : "s")")
        }
    }

    public func string(at index: Int, with context: AJREvaluationContext) throws -> String {
        return try AJRExpression.valueAsString(arguments[index], with: context)
    }

    public func date(at index: Int, with context: AJREvaluationContext) throws -> AJRTimeZoneDate? {
        return try AJRExpression.valueAsDate(arguments[index], with: context)
    }

    public func boolean(at index: Int, with context: AJREvaluationContext) throws -> Bool {
        return try AJRExpression.valueAsBool(arguments[index], with: context)
    }

    public func integer<T: BinaryInteger>(at index: Int, with context: AJREvaluationContext) throws -> T {
        return try AJRExpression.valueAsInteger(arguments[index], with: context)
    }

    public func float<T: BinaryFloatingPoint>(at index: Int, with context: AJREvaluationContext) throws -> T {
        return try AJRExpression.valueAsFloat(arguments[index], with: context)
    }

    public func collection(at index: Int, with context: AJREvaluationContext) throws -> (any AJRCollection)? {
        return try AJRExpression.valueAsCollection(arguments[index], with: context)
    }

    // MARK: - NSCoding

    open func encode(with coder: NSCoder) {
        coder.encode(arguments, forKey: "arguments")
        coder.encode(functionExpression, forKey: "functionExpression")
    }

    required public init?(coder: NSCoder) {
        if let arguments = coder.decodeObject(forKey: "arguments") as? [AJREvaluation] {
            self.arguments = arguments
        } else {
            return nil
        }
        if let functionExpression = coder.decodeObject(forKey: "functionExpression") as? AJRFunctionExpression {
            self.functionExpression = functionExpression
        } else {
            return nil
        }
        super.init()
    }

    // MARK: - AJRXMLCoding

    public func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "arguments") { value in
            if let value = value as? [AJREvaluation] {
                self.arguments = value
            }
        }
        coder.decodeObject(forKey: "functionExpression") { value in
            if let value = value as? AJRFunctionExpression {
                self.functionExpression = value
            }
        }
    }

    public func encode(with coder: AJRXMLCoder) {
        coder.encode(arguments, forKey: "arguments")
        coder.encode(functionExpression, forKey: "functionExpression")
    }

}
