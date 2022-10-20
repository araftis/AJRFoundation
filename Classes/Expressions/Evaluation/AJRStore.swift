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

@objcMembers
open class AJRStore : NSObject, AJREquatable, AJRXMLCoding, Sequence, NSCopying {

    // MARK: - Properties

    public var symbols : [String:AJREvaluation]

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

    public func addSymbol(named name: String, value: AJREvaluation) throws -> Void {
        if symbols[name] == nil {
            symbols[name] = value
        } else {
            throw AJRStoreError.alreadyDefined("Symbol \"\(name)\" is already defined.")
        }
    }

    public func addOrReplaceSymbol(named name: String, value: AJREvaluation) -> Void {
        symbols[name] = value
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

