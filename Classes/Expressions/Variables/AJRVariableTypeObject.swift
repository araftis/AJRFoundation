//
//  AJRVariableTypeObject.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/22/22.
//

import Cocoa

public protocol AJRVariableObjectCreation : NSObject {

    init()

}

@objcMembers
open class AJRVariableTypeObject: AJRVariableType {

    // MARK: - Conversion

    open override func value(from string: String) throws -> Any? {
        if let cls = NSClassFromString(string) as? AJRVariableObjectCreation.Type {
            return cls.init()
        }
        throw ValueConversionError.invalidInputValue("Class \"\(string)\" cannot be found.")
    }

    open override func string(from value: Any) throws -> Any? {
        if let value = value as? AnyClass {
            return NSStringFromClass(type(of: value))
        }
        throw ValueConversionError.invalidInputValue("Input value does not appear to be a class.")
    }

}
