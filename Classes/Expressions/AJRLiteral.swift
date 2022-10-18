//
//  AJRLiteral.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/14/22.
//

import Foundation

@objcMembers
open class AJRLiteral : NSObject, AJREvaluation, NSCoding, AJREquatable, AJRXMLCoding {

    open var name : String!

    @objc(literalWithName:)
    public class func literal(with name: String) -> AJRLiteral {
        return AJRLiteral(name: name)
    }

    required public override init() {
        super.init()
    }

    public init(name: String) {
        self.name = name
    }

    // MARK: - AJREquatable

    open override func isEqual(to object: Any?) -> Bool {
        if let object = object as? AJRLiteral {
            return AJRAnyEquals(name, object.name)
        }
        return false
    }

    open override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
    }

    // MARK: - Hashable

    open override var hash: Int {
        return name.hash
    }

    // MARK: - CustomStringConvertible

    open override var description: String {
        return name
    }

    // MARK: - AJREvaluation

    open func evaluate(with context: AJREvaluationContext) throws -> Any {
        // First, let's check and see if we have a something defined for us in context.
        if let symbol = context.symbol(named: name) {
            return try symbol.evaluate(with: context)
        } else {
            // We don't define this as a symbol, so we treat it as a key path and resolve via context's rootObject.
            return getValue(forKeyPath: name, on: context.rootObject) ?? NSNull()
        }
    }

    // MARK: - NSCoding

    required public init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") ?? "<undefined>"
    }

    open func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
    }

    // MARK: - AJRXMLCoding

    public func decode(with coder: AJRXMLCoder) {
        coder.decodeString(forKey: "name") { self.name = $0 }
    }

    public func encode(with coder: AJRXMLCoder) {
        coder.encode(name, forKey: "name")
    }

}
