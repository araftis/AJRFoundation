//
//  AJRFunctionArguments.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/12/22.
//

import Foundation

@objcMembers
open class AJRArguments : NSObject, NSCoding, Sequence {

    open var arguments : [AJRExpression]
    weak open var functionExpression : AJRFunctionExpression?

    internal var name : String {
        return functionExpression?.function.name ?? "***DEALLOCATED***"
    }

    public init(arguments: [AJRExpression]? = nil) {
        if let arguments = arguments {
            self.arguments = arguments
        } else {
            self.arguments = [AJRExpression]()
        }
        super.init()
    }

    open func append(argument: AJRExpression) {
        arguments.append(argument)
    }

    open var count : Int {
        return arguments.count
    }

    public subscript(index: Int) -> AJRExpression {
        return arguments[index];
    }

    public func enumerated() -> EnumeratedSequence<[AJRExpression]> {
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
        if let arguments = coder.decodeObject(forKey: "arguments") as? [AJRExpression] {
            self.arguments = arguments
        } else {
            return nil
        }
        if let functionExpression = coder.decodeObject(forKey: "functionExpression") as? AJRFunctionExpression{
            self.functionExpression = functionExpression
        } else {
            return nil
        }
        super.init()
    }

}
