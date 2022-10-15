//
//  AJRStore.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/13/22.
//

import Foundation

public enum AJRStoreError : Error {

    case alreadyDefined(String)

}

@objcMembers
open class AJRStore : NSObject {

    // MARK: - Properties

    // This is the default store with all the predefined functions and constants added as variables.
    public static var rootStore : AJRStore = {
        let store = AJRStore()

        // First, add all our functions
        for function in AJRFunction.allFunctions {
            do {
                try store.addSymbol(named: function.name, value: function)
            } catch {
                AJRLog.warning("Attempt to add a duplicate root symbol. This is going to cause issues: \(error.localizedDescription)")
            }
        }

        // And our constants
        for (name, constant) in AJRConstant.allConstants {
            do {
                try store.addSymbol(named: name, value: constant)
            } catch {
                AJRLog.warning("Attempt to add a duplicate root symbol. This is going to cause issues: \(error.localizedDescription)")
            }
        }

        return store
    }()

    public var symbols : [String:AJREvaluation]
    public var arguments : AJRArguments

    // MARK: - Creation

    public init(symbols: [String:AJREvaluation]? = nil, arguments: AJRArguments? = nil) {
        self.symbols = symbols ?? [String:AJREvaluation]()
        self.arguments = arguments ?? AJRArguments()
    }

    // MARK: - Accessing Symbols

    open func symbol(named name: String) -> AJREvaluation? {
        return symbols[name]
    }

    open func containsSymbol(named name: String) -> Bool {
        return symbols[name] != nil
    }

    public subscript(name: String) -> AJREvaluation? {
        return symbols[name]
    }

    public func addSymbol(named name: String, value: AJREvaluation) throws -> Void {
        if symbols[name] == nil {
            symbols[name] = value
        } else {
            throw AJRStoreError.alreadyDefined("Symbol \"\(name)\" is already defined.")
        }
    }

    public func addOrReplaceSymbol(named name: String, value: AJREvaluation) throws -> Void {
        symbols[name] = value
    }

    // MARK: - Access Arguments

    public var argumentCount : Int { return arguments.count }

    public func argument(at index: Int) -> AJREvaluation? {
        return arguments[index]
    }

}

