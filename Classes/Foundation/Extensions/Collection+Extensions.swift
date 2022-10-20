/*
Collection+Extensions.swift
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

public enum AJRCollectionSemantic : Int {
    case unknown
    case valueUnordered
    case valueOrdered
    case keyValueUnordered
    case keyValueOrdered
}

public extension Collection {

    /**
     Joins the values of a collection into a string.
     
     Joins the components of the collection using `separator` between the objects. If `twoValueSeparator` and `finalSeparator` are supplied this are used between the values when there's only two, or between the last two values. For example, if you call:
     
     ````
     [1].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
     ````
     
     you'd get:
     
     ````
     "1"
     ````
     
     If you call:

     ````
     [1, 2].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
     ````
     
     you'd get:
     
     ````
     "1 and 2"
     ````
     
     And if you call:
     
     ````
     [1, 2, 3].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
     ````
     
     you'd get:
     
     ````
     "1, 2, and 3"
     ````
     
     Either one or both of `twoValueSeparator` and `finalSeparator` may be omitted parameters, in which case their values are `nil`.
     
     - parameter separator: The primary string to use between values.
     - parameter twoValueSeparator: The string to use between values when there are exactly two values in the collection. May be nil, in which case `separator` is used.
     - parameter finalSeparator: The tring to use between the final two values of the collection when the collection has three or more values. If `twoValueSeparator` is nil, but `finalSeparator` is not, then the `finalSeparator` will be used between the values in a two value collection.
     
     - returns: The constructed string. See above for examples.
     */
    func componentsJoinedByString(separator:String, twoValueSeparator:String? = nil, finalSeparator:String? = nil) -> String {
        var string = ""
        
        for (index, object) in self.enumerated() {
            if string.isEmpty {
                string += String(describing:object)
            } else {
                if count == 2, let twoValueSeparator = twoValueSeparator {
                    string += twoValueSeparator
                } else if index == count - 1, let finalSeparator = finalSeparator {
                    string += finalSeparator
                } else {
                    string += separator
                }
                string += String(describing:object)
            }
        }
        
        return string
    }
    
    var jsonString : String? {
        var data : Data? = nil
        try? NSObject.catchException {
            data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
        }
        if let data = data, let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }

}

public protocol AJRCollection : Collection {

    // MARK: - Basic Generic Access

    func contains(equatable other: Any) -> Bool
    func contains(key other: any Hashable) -> Bool
    func value(forKey key: any Hashable) -> Any?
    mutating func setValue(_ value: Any, forKey key: any Hashable) -> Void
    mutating func appendAny(_ value: Any) -> Void

    // MARK: - Basic Enumerations

    func enumerateValues(_ enumerator : (Any, inout Bool) -> Void) -> Void
    func enumerateKeys(_ enumerator : ((any Hashable)?, inout Bool) -> Void) -> Void
    func enumerateKeyValues(_ enumerator : ((any Hashable)?, Any, inout Bool) -> Void) -> Void

    // MARK: - Set Operations

    func union(_ other: any AJRCollection) -> any AJRCollection
    func intersect(_ other: any AJRCollection) -> any AJRCollection
    func subtract(_ other: any AJRCollection) -> any AJRCollection
    func symmetricDifference(_ other: any AJRCollection) -> any AJRCollection

    // MARK: - Semantics

    var semantic : AJRCollectionSemantic { get }
}

extension AJRCollection {

    internal var usesKeySemantic : Bool {
        let semantic = self.semantic
        return semantic == .keyValueUnordered || semantic == .keyValueOrdered
    }

    internal var usesUnorderedSemantic : Bool {
        let semantic = self.semantic
        return semantic == .keyValueUnordered || semantic == .valueUnordered
    }

    internal var usesOrderedSemantic : Bool {
        let semantic = self.semantic
        return semantic == .keyValueOrdered || semantic == .valueOrdered
    }

    /**
     Checks to see if `other` in contained in the set, using a very loose definition of equality.

     When checking for containment, there's an excellent chance that you can find a more proficient way to do this, but this method will work across a wide range of objects contained in a collection.

     - parameter other The object check for containment.

     - returns `true` if `other` exists in the receiver.
     */
    public func contains(equatable other: Any) -> Bool {
        for object in self {
            if let object = object as? (key:AnyHashable, value:Any) {
                if AJRAnyEquals(object.value, other) {
                    return true
                }
            } else {
                if AJRAnyEquals(object, other) {
                    return true
                }
            }
        }
        return false
    }

    public func contains(key other: any Hashable) -> Bool {
        if usesKeySemantic {
            for object in self {
                if let object = object as? (key:AnyHashable, value:Any) {
                    if AJRAnyEquals(object.key, other) {
                        return true
                    }
                }
            }
        }
        return false
    }

    public func value(forKey key: any Hashable) -> Any? {
        if usesKeySemantic {
            for object in self {
                if let object = object as? (key:AnyHashable, value:Any) {
                    if AJRAnyEquals(object.key, key) {
                        return object.value
                    }
                }
            }
        }
        return nil
    }

    mutating public func setValue(_ value: Any, forKey: any Hashable) -> Void {
        // Default implementation does nothing.
    }

    // MARK: - Enumerations

    public func enumerateValues(_ enumerator : (Any, inout Bool) -> Void) -> Void {
        for element in self {
            var stop = false
            if usesKeySemantic,
               let element = element as? (key:AnyHashable, value:Any) {
                enumerator(element.value, &stop)
            } else {
                enumerator(element, &stop)
            }
            if stop {
                break
            }
        }
    }

    public func enumerateKeys(_ enumerator : ((any Hashable)?, inout Bool) -> Void) -> Void {
        for element in self {
            var stop = false
            if usesKeySemantic,
               let element = element as? (key:AnyHashable, value:Any) {
                enumerator(element.key, &stop)
            } else {
                enumerator(nil, &stop)
            }
            if stop {
                break
            }
        }
    }

    public func enumerateKeyValues(_ enumerator : ((any Hashable)?, Any, inout Bool) -> Void) -> Void {
        for element in self {
            var stop = false
            if usesKeySemantic,
               let element = element as? (key:AnyHashable, value:Any) {
                enumerator(element.key, element.value, &stop)
            } else {
                enumerator(nil, element, &stop)
            }
            if stop {
                break
            }
        }
    }

    // MARK: - Set Operations

    internal func union(into left: @autoclosure () -> any AJRCollection, right: any AJRCollection) -> any AJRCollection {
        var result = left()
        // Now loop over other
        right.enumerateValues { value, stop in
            if let value = value as? Element {
                if !result.contains(equatable: value) {
                    result.appendAny(value)
                }
            }
        }
        return result
    }

    /**
     Performs a fairly inefficient union of two collections.

     This perform a very generic union of two Collections. The union will contain at most one instance of an object in the receiver and `other`. The returned union will be in an Array, but still declared as a `Collection`. There are implementations for specific collection types that will be more performant, and may return other types.

     - parameter other The Collection with which to union the receiver.

     - returns A new collection that represents the union of the receiver and `other`.
     */
    public func union(_ other: any AJRCollection) -> any AJRCollection {
        return union(into: Array<Element>(self), right: other)
    }

    public func intersect(into allocator: @autoclosure () -> any AJRCollection, right: any AJRCollection) -> any AJRCollection {
        var result = allocator()
        // Loop over us, inserting into array.
        for element in self {
            if right.contains(equatable: element) {
                result.appendAny(element)
            }
        }
        return result
    }

    /**
     Performs a fairly inefficient intersection of two collections.

     This perform a very generic intersection of two Collections. The intersection will contain at most one instance of an object that resides in either the receiver or `other`. The returned intersection will be in an Array, but still declared as a `Collection`. There are implementations for specific collection types that will be more performant, and may return other types.

     - parameter other The Collection with which to union the receiver.

     - returns A new collection that represents the union of the receiver and `other`.
     */
    public func intersect(_ other: any AJRCollection) -> any AJRCollection {
        return intersect(into: Array<Element>(), right: other)
    }

    public func subtract(into allocator: @autoclosure () -> any AJRCollection, right: any AJRCollection) -> any AJRCollection {
        var left = allocator()

        // Loop over us, inserting into array.
        for element in self {
            if !right.contains(equatable: element) {
                left.appendAny(element)
            }
        }

        return left
    }

    public func subtract(_ other: any AJRCollection) -> any AJRCollection {
        return subtract(into: Array<Element>(), right: other)
    }

    public func symmetricDifference(into allocator: @autoclosure () -> any AJRCollection, right: any AJRCollection) -> any AJRCollection {
        var left = allocator()

        // Loop over us, inserting into array.
        for element in self {
            if !right.contains(equatable: element) {
                left.appendAny(element)
            }
        }
        for element in right {
            if let element = element as? Element {
                if !self.contains(equatable: element) {
                    left.appendAny(element)
                }
            }
        }

        return left
    }

    public func symmetricDifference(_ other: any AJRCollection) -> any AJRCollection {
        return symmetricDifference(into: Array<Element>(), right: other)
    }

    var semantic : AJRCollectionSemantic {
        return .unknown
    }

}

extension Array : AJRCollection {

    public var semantic : AJRCollectionSemantic {
        return .valueOrdered
    }

    mutating public func appendAny(_ value: Any) -> Void {
        if let value = value as? Element {
            self.append(value)
        }
    }

}

extension NSArray : AJRCollection {

    public var semantic: AJRCollectionSemantic {
        return .valueOrdered
    }

    public func appendAny(_ value: Any) {
        if let mutable = self as? NSMutableArray {
            mutable.add(value)
        }
    }

}

extension Set : AJRCollection {

    public var semantic : AJRCollectionSemantic {
        return .valueUnordered
    }

    mutating public func appendAny(_ value: Any) -> Void {
        if let value = value as? Element {
            self.insert(value)
        }
    }

    public func union(_ other: any AJRCollection) -> any AJRCollection {
        return union(into: Set<Element>(self), right: other)
    }

    public func intersect(_ other: any AJRCollection) -> any AJRCollection {
        return intersect(into: Set<Element>(), right: other)
    }

    public func subtract(_ other: any AJRCollection) -> any AJRCollection {
        return subtract(into: Set<Element>(), right: other)
    }

    public func symmetricDifference(_ other: any AJRCollection) -> any AJRCollection {
        return symmetricDifference(into: Set<Element>(), right: other)
    }

}

extension String : AJRCollection {

    public var semantic : AJRCollectionSemantic {
        return .valueOrdered
    }

    mutating public func appendAny(_ value: Any) -> Void {
        if let value = value as? Element {
            self.append(value)
        }
    }

}

extension Dictionary : AJRCollection {

    public var semantic : AJRCollectionSemantic {
        return .keyValueUnordered
    }

    public func contains(equatable other: Any) -> Bool {
        for value in values {
            if AJRAnyEquals(value, other) {
                return true
            }
        }
        return false
    }

    public func value(forKey key: any Hashable) -> Any? {
        if let key = key as? Key {
            return self[key as Key]
        }
        return nil
    }

    mutating public func setValue(_ value: Any, forKey key: any Hashable) -> Void {
        if let key = key as? Key,
           let value = value as? Value {
            self[key] = value
        }
    }

    mutating public func appendAny(_ value: Any) -> Void {
        // We do nothing because we need a key.
    }

    internal var valuesAsSet : Set<AnyHashable> {
        var set = Set<AnyHashable>()

        for value in self.values {
            if let value = value as? any Hashable {
                _ = set.insert(value)
            }
        }

        return set
    }

    public func union(_ other: any AJRCollection) -> any AJRCollection {
        if other.usesKeySemantic {
            var result = self

            // Now loop over other
            other.enumerateKeyValues { key, value, stop in
                if let key = key,
                   !result.contains(key: key) {
                    result.setValue(value, forKey: key)
                }
            }
            return result
        } else if other.semantic == .valueUnordered {
            return valuesAsSet.union(other)
        }
        return Array<Value>(self.values).union(other)
    }

    public func intersect(_ other: any AJRCollection) -> any AJRCollection {
        if other.usesKeySemantic {
            var result = Dictionary<Key,Value>()

            // Loop over us, inserting into array.
            for element in self {
                if other.usesKeySemantic {
                    if other.contains(key: element.key) {
                        result[element.key] = element.value
                    }
                } else {
                    if other.contains(equatable: element.value) {
                        result[element.key] = element.value
                    }
                }
            }

            return result
        } else if other.semantic == .valueUnordered {
            return valuesAsSet.intersect(other)
        }
        return Array<Value>(self.values).intersect(other)
    }

    public func subtract(_ other: any AJRCollection) -> any AJRCollection {
        if other.usesKeySemantic {
            var result = Dictionary<Key,Value>()

            // Loop over us, inserting into array.
            for element in self {
                if other.usesKeySemantic {
                    if !other.contains(key: element.key) {
                        result[element.key] = element.value
                    }
                } else {
                    if !other.contains(equatable: element.value) {
                        result[element.key] = element.value
                    }
                }
            }

            return result
        } else if other.semantic == .valueUnordered {
            return valuesAsSet.subtract(other)
        }
        return Array<Value>(self.values).subtract(other)
    }

    public func symmetricDifference(_ other: any AJRCollection) -> any AJRCollection {
        // TODO: Need to get this working!
        if other.usesKeySemantic {
            var array = Array<Element>()

            // Loop over us, inserting into array.
            for element in self {
                if !other.contains(equatable: element) {
                    array.append(element)
                }
            }
            for element in other {
                if let element = element as? Element {
                    if !self.contains(equatable: element) {
                        array.append(element)
                    }
                }
            }

            return array
        } else if other.semantic == .valueUnordered {
            return valuesAsSet.symmetricDifference(other)
        }
        return Array<Value>(self.values).symmetricDifference(other)
    }

}

extension OrderedSet : AJRCollection {

    public var semantic : AJRCollectionSemantic {
        return .valueOrdered
    }

    mutating public func appendAny(_ value: Any) -> Void {
        if let value = value as? Element {
            self.append(value)
        }
    }

    public func union(_ other: any AJRCollection) -> any AJRCollection {
        return union(into: Set<Element>(self), right: other)
    }

    public func intersect(_ other: any AJRCollection) -> any AJRCollection {
        return intersect(into: Set<Element>(), right: other)
    }

    public func subtract(_ other: any AJRCollection) -> any AJRCollection {
        return subtract(into: Set<Element>(), right: other)
    }

    public func symmetricDifference(_ other: any AJRCollection) -> any AJRCollection {
        return symmetricDifference(into: Set<Element>(), right: other)
    }

}

extension OrderedDictionary : AJRCollection {

    public var semantic : AJRCollectionSemantic {
        return .keyValueOrdered
    }

    mutating public func setValue(_ value: Any, forKey key: any Hashable) {
        if let key = key as? Key,
           let value = value as? Value {
            self[key] = value
        }
    }

    mutating public func appendAny(_ value: Any) -> Void {
        // We do nothing, because we need a key.
    }

}
