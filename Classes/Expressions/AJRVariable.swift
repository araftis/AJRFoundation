//
//  AJRVariable.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/18/22.
//

import Foundation

/**
 This is pretty much an `AJRLiteral`, but with a name.

 This is useful for when you want to store named values prior to execution.
 */
@objcMembers
open class AJRVariable : NSObject, AJREquatable, AJRXMLCoding, AJREvaluation {

    // MARK: - Properties

    public static let UnsetPlaceholderName = "<unset>"

    open var name : String
    open var value : AJREvaluation?

    // MARK: - Creation

    required public convenience override init() {
        self.init(name: AJRVariable.UnsetPlaceholderName)
    }

    public init(name: String, value: AJREvaluation? = nil) {
        self.name = name
        self.value = value
    }

    // MARK: - AJREvaluation

    open func evaluate(with context: AJREvaluationContext) throws -> Any {
        // We call this, because it recursively evaluates value until value resolves to a simple value.
        return try AJRExpression.value(value, with: context) ?? NSNull()
    }

    // MARK: - AJREquatable

    open override func isEqual(to object: Any?) -> Bool {
        if let object = object as? AJRVariable {
            return (super.isEqual(to: object)
                    && AJRAnyEquals(name, object.name)
                    && AJRAnyEquals(value, object.value))
        }
        return false
    }

    // MARK: - NSCoding

    required public init?(coder: NSCoder) {
        if let name = coder.decodeObject(forKey: "name") as? String {
            self.name = name
        } else {
            return nil
        }
        self.value = coder.decodeObject(forKey: "value") as? AJREvaluation
    }

    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(value, forKey: "value")
    }

    // MARK: - AJRXMLCoding

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "name") { name in
            if let name = name as? String {
                self.name = name
            }
        }
        coder.decodeObject(forKey: "value") { value in
            if let value = value as? AJREvaluation {
                self.value = value
            }
        }
    }

    open func encode(with coder: AJRXMLCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(value, forKey: "value")
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of:self).init()

        copy.name = name
        copy.value = value?.copy(with: zone) as? AJREvaluation

        return copy
    }

}
