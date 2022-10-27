/*
AJRStore.swift
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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

public enum AJRStoreError : Error {

    case alreadyDefined(String)

}

@objc
public protocol AJRStoreVariableDelegate : NSObjectProtocol {

    @objc optional func createVariable(named name: String, type: AJRVariableType, with value: Any?, in store: AJRStore) -> AJRVariable?

    @objc optional func store(_ store: AJRStore, willAddVariable variable: AJRVariable) -> Bool
    @objc optional func store(_ store: AJRStore, didAddVariable variable: AJRVariable) -> Void
    @objc optional func store(_ store: AJRStore, willRemoveVariable variable: AJRVariable) -> Bool
    @objc optional func store(_ store: AJRStore, didRemoveVariable variable: AJRVariable) -> Void

}

@objcMembers
open class AJRStore : NSObject, AJREquatable, AJRXMLCoding, Sequence, NSCopying {

    // MARK: - Properties

    public var symbols : [String:AJREvaluation] {
        willSet {
            willChangeValue(forKey: "symbols")
        }
        didSet {
            didChangeValue(forKey: "symbols")
        }
    }
    public weak var variableDelegate : AJRStoreVariableDelegate?

    // MARK: - Creation

    open class func store() -> AJRStore {
        return AJRStore(symbols: nil)
    }

    @objc(storeWithSymbols:)
    open class func store(with symbols: [String:AJREvaluation]?) -> AJRStore {
        return AJRStore(symbols: symbols)
    }

    required override public convenience init() {
        self.init(symbols: nil)
    }

    public init(symbols: [String:AJREvaluation]? = nil) {
        self.symbols = symbols ?? [String:AJREvaluation]()
    }

    // MARK: - Accessing Symbols

    open var count : Int {
        return symbols.count
    }

    open func symbol(named name: String) -> AJREvaluation? {
        return symbols[name]
    }

    open func containsSymbol(named name: String) -> Bool {
        return symbols[name] != nil
    }

    public subscript(name: String) -> AJREvaluation? {
        return symbols[name]
    }

    public func orderedName(at index: Int) -> String? {
        let names = symbols.keys.sorted()
        return names[index]
    }

    public func orderedSymbol(at index: Int) -> AJREvaluation? {
        if let name = orderedName(at: index) {
            return symbols[name]
        }
        return nil
    }

    /**
     Create a new variable of the given name and value.

     If this method succeeds, it will return the newly created variable. Otherwise, it will return nil. The `name` of the variable will be treated as a "basename", and may have a number appended to the end. This happens when a variable of a given name already exists in the store.

     The newly created variable will be added to the store.

     - parameter name: The name of the variable.
     - parameter value: The value of the variable.

     - returns The newly created variable, or `nil` if no variable was created.
     */
    public func createVariable(named name: String, type: AJRVariableType, value: Any?) -> AJRVariable? {
        let name = symbols.keys.nextName(basedOn: name)
        let variable : AJRVariable?

        if let variableDelegate {
            if variableDelegate .responds(to: #selector(createVariable(named:type:value:))) {
                variable = variableDelegate.createVariable?(named: name, type: type, with: value, in: self)
            } else {
                variable = AJRVariable(name: name, type: type, value: value)
            }
        } else {
            variable = AJRVariable(name: name, type: type, value: value)
        }

        if let variable {
            addOrReplaceSymbol(named: name, value: variable)
        }

        return variable
    }

    public func addSymbol(named name: String, value: AJREvaluation) throws -> Void {
        if symbols[name] == nil {
            addOrReplaceSymbol(named: name, value: value)
        } else {
            throw AJRStoreError.alreadyDefined("Symbol \"\(name)\" is already defined.")
        }
    }

    public func addVariable(_ variable: AJRVariable) throws -> Void {
        try addSymbol(named: variable.name, value: variable)
    }

    public func addOrReplaceSymbol(named name: String, value: AJREvaluation) -> Void {
        if let value = value as? AJRVariable {
            if !(variableDelegate?.store?(self, willAddVariable: value) ?? true) {
                return
            }
        }

        //willChangeValue(forKey: "symbols")
        willChangeValue(forKey: "symbols", withSetMutation: .union, using: [name])
        symbols[name] = value
        didChangeValue(forKey: "symbols", withSetMutation: .union, using: [name])
        //didChangeValue(forKey: "symbols")

        if let value = value as? AJRVariable {
            variableDelegate?.store?(self, didAddVariable: value)
        }
    }

    public func addOrReplaceVariable(_ variable: AJRVariable) -> Void {
        addOrReplaceSymbol(named: variable.name, value: variable)
    }

    @discardableResult
    public func removeSymbol(named name: String) -> AJREvaluation? {
        let returnValue = symbols[name]
        // Only need to remove it, if it exists.
        if returnValue != nil {
            if let value = returnValue as? AJRVariable {
                if !(variableDelegate?.store?(self, willRemoveVariable: value) ?? true) {
                    // Don't remove the symbol.
                    return nil
                }
            }
            willChangeValue(forKey: "symbols")
            willChangeValue(forKey: "symbols", withSetMutation: .minus, using: [name])
            symbols.removeValue(forKey: name)
            didChangeValue(forKey: "symbols", withSetMutation: .minus, using: [name])
            didChangeValue(forKey: "symbols")
            if let value = returnValue as? AJRVariable {
                variableDelegate?.store?(self, didRemoveVariable: value)
            }
        }
        return returnValue
    }

    @discardableResult
    public func removeVariable(_ variable: AJRVariable) -> AJRVariable? {
        if let variable = symbols[variable.name] as? AJRVariable {
            return removeSymbol(named: variable.name) as? AJRVariable
        }
        return nil
    }

    // MARK: - Sequence

    public func enumerated() -> EnumeratedSequence<[String:AJREvaluation]> {
        return symbols.enumerated()
    }

    public func makeIterator() -> some IteratorProtocol {
        return symbols.makeIterator()
    }

    /**
     Makes enumeration of our contents easy from Obj-C
     */
    @objc
    open func enumerate(_ block: @convention(block) (_ name: String, _ value: AJREvaluation, _ stop: UnsafeMutablePointer<Bool>) -> Void) -> Void {
        for (name, value) in symbols {
            var stop = false
            block(name, value, &stop)
            if stop {
                break
            }
        }
    }

    // MARK: - AJREquatable

    open override func isEqual(to object: Any?) -> Bool {
        if let object = object as? AJRStore {
            return (super.isEqual(to: object)
                    && AJRAnyEquals(symbols, object.symbols))
        }
        return false
    }

    open override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
    }

    // MARK: - AJRXMLCoding

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "symbols") { symbols in
            if let symbols = symbols as? [String:AJREvaluation] {
                self.symbols = symbols
            }
        }
    }

    open func encode(with coder: AJRXMLCoder) {
        coder.encode(symbols, forKey: "symbols")
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()

        for (name, value) in symbols {
            copy.addOrReplaceSymbol(named: name, value: value.copy() as! AJREvaluation)
        }

        return copy
    }

}
