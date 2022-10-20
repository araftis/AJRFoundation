/*
AJRStackFrame.swift
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
