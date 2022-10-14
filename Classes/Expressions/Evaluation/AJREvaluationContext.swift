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
    open var stores = [AJRStore]()

    // MARK: - Creation

    @objc(evaluationContext)
    open class func evaluationContext() -> AJREvaluationContext {
        return AJREvaluationContext()
    }

    @objc(evaluationContextWithRootObject:)
    open class func evaluationContext(rootObject: Any?) -> AJREvaluationContext {
        return AJREvaluationContext(rootObject: rootObject, stores: nil)
    }

    @objc(evaluationContextWithRootObject:stores:)
    open class func evaluationContext(rootObject: Any?, stores: [AJRStore]?) -> AJREvaluationContext {
        return AJREvaluationContext(rootObject: rootObject, stores: stores)
    }

    public init(rootObject: Any? = nil, stores: [AJRStore]? = nil) {
        self.rootObject = rootObject
        if let stores = stores {
            self.stores.append(contentsOf: stores)
        }
    }

    public convenience init(rootObject: Any? = nil, rootStore: AJRStore) {
        self.init(rootObject: rootObject, stores: [rootStore])
    }

    // MARK: - Manipulating the Store

    @discardableResult
    open func push(store: AJRStore? = nil) -> AJRStore {
        let returnStore = store ?? AJRStore()
        stores.append(returnStore)
        return returnStore
    }

    @discardableResult
    open func pop() -> AJRStore? {
        return stores.removeLast()
    }

    open var arguments : AJRArguments? {
        return stores.last?.arguments
    }

    // MARK: - Argment Utilities

    open var argumentCount : Int {
        return stores.last?.argumentCount ?? 0
    }

    open func getArguments() throws -> AJRArguments {
        if let store = stores.last {
            return store.arguments
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
