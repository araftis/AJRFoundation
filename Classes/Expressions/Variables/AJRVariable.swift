/*
 AJRVariable.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

@objc
public protocol AJRVariableListener {

    func variable(_ variable: AJRVariable, willChange change: AJRVariable.ChangeType)
    func variable(_ variable: AJRVariable, didChange change: AJRVariable.ChangeType)

}

/**
 This is pretty much an `AJRLiteral`, but with a name.

 This is useful for when you want to store named values prior to execution.
 */
@objcMembers
open class AJRVariable : NSObject, AJREquatable, AJRXMLCoding, AJREvaluation {

    @objc(AJRVariableChangeType)
    public enum ChangeType : Int, AJRXMLEncodableEnum {
        case name
        case variableType
        case value

        public var description: String {
            switch self {
            case .name: return "name"
            case .variableType: return "variableType"
            case .value: return "value"
            }
        }
    }

    // MARK: - Properties

    public static let UnsetPlaceholderName = "var"

    open var name : String {
        willSet {
            notifyListeners(ofWillChange: .name)
        }
        didSet {
            notifyListeners(ofDidChange: .name)
        }
    }
    open var value : Any? {
        willSet {
            notifyListeners(ofWillChange: .value)
        }
        didSet {
            notifyListeners(ofDidChange: .value)
        }
    }
    open var variableType : AJRVariableType {
        willSet {
            notifyListeners(ofWillChange: .variableType)
        }
        didSet {
            notifyListeners(ofDidChange: .variableType)
        }
    }

    @Weak open var listeners : [AJRVariableListener]

    // MARK: - Creation

    // Really, this is only meant to be called as part of unarchiving.
    required public convenience override init() {
        self.init(name: AJRVariable.UnsetPlaceholderName, type: AJRVariableType())
    }

    public init(name: String, type: AJRVariableType, value: Any? = nil) {
        self.name = name
        self.variableType = type
        self.value = value
    }

    // MARK: - AJREvaluation

    open func evaluate(with context: AJREvaluationContext) throws -> Any {
        // We call this, because it recursively evaluates value until value resolves to a simple value.
        return try AJRExpression.value(value, with: context) ?? NSNull()
    }

    // MARK: - AJREquatable

    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AJRVariable {
            return (super.isEqual(object)
                    && AJRAnyEquals(name, object.name)
                    && AJRAnyEquals(value, object.value))
        }
        return false
    }

    // MARK: - Change Listeners

    open func addListener(_ listener: AJRVariableListener) {
        listeners.append(listener)
    }

    open func removeListener(_ listener: AJRVariableListener) {
        // TODO: I'm not sure this will work with the wrapper.
        listeners.remove(identicalTo: listener)
    }

    open func notifyListeners(ofWillChange change: ChangeType) {
        willChangeValue(forKey: change.description)
        for listener in listeners {
            listener.variable(self, willChange: change)
        }
    }

    open func notifyListeners(ofDidChange change: ChangeType) {
        didChangeValue(forKey: change.description)
        for listener in listeners {
            listener.variable(self, didChange: change)
        }
    }

    // MARK: - NSCoding

    required public init?(coder: NSCoder) {
        if let name = coder.decodeObject(forKey: "name") as? String {
            self.name = name
        } else {
            return nil
        }
        if let typeName = coder.decodeObject(forKey: "type") as? String {
            self.variableType = AJRVariableType.variableType(for: typeName)!
        } else {
            self.variableType = AJRVariableType()
        }
        self.value = coder.decodeObject(forKey: "value")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(variableType.name, forKey: "type")
        coder.encode(value, forKey: "value")
    }

    // MARK: - AJRXMLCoding

    open class override var ajr_nameForXMLArchiving: String {
        return "variable"
    }

    open func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "name") { name in
            if let name = name as? String {
                self.name = name
            }
        }
        coder.decodeVariableType(forKey: "type") { value in
            if let value {
                self.variableType = value
            }
        }
        coder.decodeObject(forKey: "value") { value in
            self.value = value
        }
    }

    open func encode(with coder: AJRXMLCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(variableType, forKey: "type")
        coder.encode(value, forKey: "value")
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of:self).init()

        copy.name = name
        copy.variableType = variableType
        if let value = value as? NSCopying {
            copy.value = value.copy(with: zone)
        } else {
            copy.value = value
        }

        return copy
    }

    // MARK: - NSObject

    open override var description: String {
        return "<\(self.descriptionPrefix), name: \(name), type: \(variableType), value: \(value ?? "nil")>";
    }
}
