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

