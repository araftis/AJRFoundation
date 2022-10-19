//
//  AJREvaluationContext.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/13/22.
//

import Foundation

public enum AJREvaluationError : Error {

    case stackUnderflow(String)

}

@objcMembers
open class AJREvaluationContext : NSObject {

    // MARK: - Properties

    open var rootObject : Any? = nil
    open var stackFrames = [AJRStackFrame]()

    // MARK: - Creation

    @objc(evaluationContext)
    open class func evaluationContext() -> AJREvaluationContext {
        return AJREvaluationContext(rootObject: nil)
    }

    @objc(evaluationContextWithRootObject:)
    open class func evaluationContext(rootObject: Any?) -> AJREvaluationContext {
        return AJREvaluationContext(rootObject: rootObject, stackFrames: nil)
    }

    @objc(evaluationContextWithRootObject:stackFrames:)
    open class func evaluationContext(rootObject: Any?, stackFrames: [AJRStackFrame]?) -> AJREvaluationContext {
        return AJREvaluationContext(rootObject: rootObject, stackFrames: stackFrames)
    }

    public init(rootObject: Any? = nil, stackFrames: [AJRStackFrame]? = nil) {
        self.rootObject = rootObject
        if let stackFrames = stackFrames {
            self.stackFrames.append(contentsOf: stackFrames)
        } else {
            self.stackFrames.append(AJRStackFrame.rootStackFrame)
        }
    }

    public convenience init(rootObject: Any? = nil, rootStackFrame: AJRStackFrame) {
        self.init(rootObject: rootObject, stackFrames: [rootStackFrame])
    }

    // MARK: - Managing the Store

    @discardableResult
    open func push(stackFrame: AJRStackFrame? = nil) -> AJRStackFrame {
        let returnFrame = stackFrame ?? AJRStackFrame()
        stackFrames.append(returnFrame)
        return returnFrame
    }

    @discardableResult
    open func pop() -> AJRStackFrame? {
        return stackFrames.removeLast()
    }

    open var arguments : AJRArguments? {
        return stackFrames.last?.arguments
    }

    open func symbol(named name: String) -> AJREvaluation? {
        // Walk up the symbol stack, looking to resolve the name.
        for store in stackFrames.reversed() {
            if let symbol = store.symbol(named: name) {
                return symbol
            }
        }
        return nil
    }

    // MARK: - Argment Utilities

    open var argumentCount : Int {
        return stackFrames.last?.argumentCount ?? 0
    }

    open func getArguments() throws -> AJRArguments {
        if let stackFrame = stackFrames.last {
            return stackFrame.arguments
        }
        throw AJREvaluationError.stackUnderflow("Stack is empty, so we can't access local arguments.")
    }

    open func getArgument(at index: Int) throws -> AJREvaluation {
        return try getArguments()[index]
    }

    open func getFunctionName() throws -> String {
        return try getArguments().name
    }

    public func check(argumentCount count: Int) throws -> Void {
        if try getArguments().count != count {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(try getFunctionName()) expects \(count) argument\(count == 1 ? "" : "s")")
        }
    }

    public func check(argumentCountMin min: Int) throws -> Void {
        if try getArguments().count < min {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(try getFunctionName()) expects at least \(min) argument\(min == 1 ? "" : "s")")
        }
    }

    public func check(argumentCountMin min: Int, max: Int) throws -> Void {
        let count = try getArguments().count
        if count < min || count > max {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(try getFunctionName()) expects between \(min) and \(max) arguments")
        }
    }

    public func check(argumentCountMax max: Int) throws -> Void {
        if try getArguments().count > max {
            throw AJRFunctionError.invalidArgumentCount("AJRFunction \(try getFunctionName()) expects at most \(max) argument\(max == 1 ? "" : "s")")
        }
    }

    public func string(at index: Int) throws -> String {
        return try AJRExpression.valueAsString(try getArguments()[index], with: self)
    }

    public func date(at index: Int) throws -> AJRTimeZoneDate? {
        return try AJRExpression.valueAsDate(try getArguments()[index], with: self)
    }

    public func boolean(at index: Int) throws -> Bool {
        return try AJRExpression.valueAsBool(try getArguments()[index], with: self)
    }

    public func integer<T: BinaryInteger>(at index: Int) throws -> T {
        return try AJRExpression.valueAsInteger(try getArguments()[index], with: self)
    }

    public func float<T: BinaryFloatingPoint>(at index: Int) throws -> T {
        return try AJRExpression.valueAsFloat(try getArguments()[index], with: self)
    }

    public func collection(at index: Int) throws -> (any AJRCollection)? {
        return try AJRExpression.valueAsCollection(try getArguments()[index], with: self)
    }

}
