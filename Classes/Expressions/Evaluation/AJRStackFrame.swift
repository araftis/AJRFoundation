//
//  AJRStackFrame.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/18/22.
//

import Foundation

@objcMembers
open class AJRStackFrame : NSObject, AJREquatable, AJRXMLCoding {

    // MARK: - Properties

    // This is the default store with all the predefined functions and constants added as variables.
    public static var rootStackFrame : AJRStackFrame = {
        let frame = AJRStackFrame()

        // First, add all our functions
        for function in AJRFunction.allFunctions {
            do {
                try frame.addSymbol(named: function.name, value: function)
            } catch {
                AJRLog.warning("Attempt to add a duplicate root symbol. This is going to cause issues: \(error.localizedDescription)")
            }
        }

        // And our constants
        for (name, constant) in AJRConstant.allConstants {
            do {
                try frame.addSymbol(named: name, value: constant)
            } catch {
                AJRLog.warning("Attempt to add a duplicate root symbol. This is going to cause issues: \(error.localizedDescription)")
            }
        }

        return frame
    }()

    open var store: AJRStore?
    open var arguments: AJRArguments

    // MARK: - Creation

    required public override convenience init() {
        self.init(store: nil, arguments: nil)
    }

    public convenience init(store: AJRStore?) {
        self.init(store: store, arguments: nil)
    }

    public convenience init(arguments: AJRArguments?) {
        self.init(store: nil, arguments: arguments)
    }

    public init(store: AJRStore?, arguments: AJRArguments?) {
        self.store = store
        self.arguments = arguments ?? AJRArguments()
    }

    // MARK: - Accessing Symbols

    open func symbol(named name: String) -> AJREvaluation? {
        return store?.symbol(named: name)
    }

    open func containsSymbol(named name: String) -> Bool {
        return store?.containsSymbol(named: name) ?? false
    }

    public subscript(name: String) -> AJREvaluation? {
        return store?.symbols[name]
    }

    internal func getStore() -> AJRStore {
        if store == nil {
            store = AJRStore()
        }
        return store!
    }

    public func addSymbol(named name: String, value: AJREvaluation) throws -> Void {
        try getStore().addSymbol(named: name, value: value)
    }

    public func addOrReplaceSymbol(named name: String, value: AJREvaluation) -> Void {
        getStore().addOrReplaceSymbol(named: name, value: value)
    }

    // MARK: - Access Arguments

    public var argumentCount : Int { return arguments.count }

    public func argument(at index: Int) -> AJREvaluation? {
        return arguments[index]
    }

    // MARK: - AJREquatable

    open override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRStackFrame {
            return (super.isEqual(to: other)
                    && AJRAnyEquals(store, other.store)
                    && AJRAnyEquals(arguments, other.arguments))
        }
        return false
    }

    open override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
    }

    // MARK: - AJRXMLCoding

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "store") { self.store = $0 as? AJRStore }
        coder.decodeObject(forKey: "arguments") { self.arguments = ($0 as? AJRArguments) ?? AJRArguments() }
    }

    open func encode(with coder: AJRXMLCoder) {
        coder.encode(store, forKey: "store")
        coder.encode(arguments, forKey: "arguments")
    }

}
