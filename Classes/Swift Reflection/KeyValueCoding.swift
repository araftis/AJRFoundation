//
//  KeyValueCoding.swift
//
//  Created by Iurii Khvorost <iurii.khvorost@gmail.com> on 2022/04/22.
//  Copyright © 2022 Iurii Khvorost. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

fileprivate func withPointer<T>(_ instance: inout T, _ body: (UnsafeMutableRawPointer, Metadata) -> Any?) -> Any? {
    withUnsafePointer(to: &instance) {
        let metadata = swift_metadata(of: T.self)
        if metadata.kind == .struct {
            return body(UnsafeMutableRawPointer(mutating: $0), metadata)
        }
        else if metadata.kind == .class {
            return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                body($0.pointee, metadata)
            }
        }
        else if metadata.kind == .existential {
            return $0.withMemoryRebound(to: ExistentialContainer.self, capacity: 1) {
                let type = $0.pointee.type
                let metadata = swift_metadata(of: type)
                if metadata.kind == .class {
                    return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                        body($0.pointee, metadata)
                    }
                }
                else if metadata.kind == .struct {
                    if metadata.size > MemoryLayout<ExistentialContainerBuffer>.size {
                        return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                            body($0.pointee.advanced(by: ExistentialHeaderSize), metadata)
                        }
                    }
                    else {
                        return body(UnsafeMutableRawPointer(mutating: $0), metadata)
                    }
                }
                return nil
            }
        }
        return nil
    }
}

@discardableResult
fileprivate func withProperty<T>(_ instance: inout T, keyPath: [String], _ body: (Metadata, UnsafeMutableRawPointer) -> Any?) -> Any? {
    withPointer(&instance) { pointer, metadata in
        var keys = keyPath
        guard let key = keys.popLast(), let property = (metadata.properties.first { $0.name == key }) else {
            return nil
        }

        let pointer = pointer.advanced(by: property.offset)

        if keys.isEmpty {
            return body(property.metadata, pointer)
        } else if var value = property.metadata.get(from: pointer) {
            defer {
                let metadata = swift_metadata(of: type(of: value))
                if metadata.kind == .struct {
                    property.metadata.set(value: value, pointer: pointer)
                }
            }
            return withProperty(&value, keyPath: keys, body)
        }
        return nil
    }
}

// MARK: -

/// Returns the metadata of the type.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Metadata of the type.
public func swift_metadata(of type: Any.Type) -> Metadata {
    MetadataCache.shared.metadata(of: type)
}

/// Returns the metadata of the instance.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Metadata of the type.
public func swift_metadata(of instance: Any) -> Metadata {
    return swift_metadata(of: type(of: instance))
}

/// Returns the value for the instance's property identified by a given name or a key path.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - key: The name of one of the instance's properties or a key path of the form
///            relationship.property (with one or more relationships):
///            for example “department.name” or “department.manager.lastName.”
/// - Returns: The value for the property identified by a name or a key path.
public func swift_value<T>(of instance: inout T, key: String) -> Any? {
    let keyPath: [String] = key.components(separatedBy: ".").reversed()
    return withProperty(&instance, keyPath: keyPath) { metadata, pointer in
        metadata.get(from: pointer)
    }
}

/**
 Sets a property of an instance specified by a given name or a key path to a given value.

 - Parameter instance: Instance of any type.
 - Parameter value: The value for the property identified by a name or a key path.
 - Parameter key: The name of one of the instance's properties or a key path of the form relationship.property (with one or more relationships): for example “department.name” or “department.manager.lastName.”
 */
public func swift_setValue<T>(_ value: Any?, to: inout T, key: String) {
    let keyPath: [String] = key.components(separatedBy: ".").reversed()
    withProperty(&to, keyPath: keyPath) { metadata, pointer in
        metadata.set(value: value as Any, pointer: pointer)
    }
}

// MARK: - KeyValueCoding

/// Protocol to access to the properties of an instance indirectly by a name or a key path.
public protocol KeyValueCoding {}

extension KeyValueCoding {

    /// Returns the metadata of the instance type.
    public var metadata: Metadata {
        swift_metadata(of: self)
    }

    /**
     Returns a value for a property identified by a given name or a key path.

     - Parameter key: The name of one of the instance's properties or a key path of the form relationship.property (with one or more relationships): for example “department.name” or “department.manager.lastName.”

     - Returns: The value for the property identified by a name or a key path.
     */
    public mutating func value(key: String) -> Any? {
        swift_value(of: &self, key: key)
    }

    /**
     Sets a property specified by a given name or a key path to a given value.

     - Parameter value: The value for the property identified by a name or a key path.
     - Parameter key: The name of one of the instance's properties or a key path of the form relationship.property (with one or more relationships): for example “department.name” or “department.manager.lastName.”
     */
    public mutating func setValue(_ value: Any?, key: String) {
        swift_setValue(value, to: &self, key: key)
    }

    /**
     Gets and sets a value for a property identified by a given name or a key path.
     */
    public subscript(key: String) -> Any? {
        mutating get {
            value(key: key)
        }
        set {
            setValue(newValue, key: key)
        }
    }

}
