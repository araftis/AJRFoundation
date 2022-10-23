/*
 AJRConversion.swift
 AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

public protocol AJRKeyValueCoding {

    func value(forKeyPath key: String) -> Any?
    func value(forKeyExpression expression: String) throws-> Any?
    func value(forExpression expression: AJREvaluation) throws -> Any?

}

public extension AJRKeyValueCoding {

    func value(forKeyExpression expression: String) throws-> Any? {
        let expression = try AJRExpression.expression(string: expression)
        return try value(forExpression: expression)
    }

    func value(forExpression expression: AJREvaluation) throws -> Any? {
        return try expression.evaluate(with: AJREvaluationContext(rootObject: self))
    }

}

public enum ValueConversionError : Error {

    case conversionNotImplemented(String)
    case valueIsNotABool(String)
    case valueIsNotANumber(String)
    case valueIsNotADate(String)
    case valueIsNotACollection(String)
    /// This is kind of the catch all case.
    case invalidInputValue(String)

}

public struct Conversion {

    public static func valueAsBool(_ valueIn: Any?) throws -> Bool {
        var returnValue = valueIn

        if returnValue == nil || returnValue is NSNull {
            returnValue = false
        } else if returnValue is Bool {
            // We've got nothing to do
        } else if returnValue is (any BinaryInteger) {
            returnValue = Int("\(returnValue!)") != 0
        } else if returnValue is (any BinaryFloatingPoint) {
            returnValue = Double("\(returnValue!)") != 0.0
        } else if let stringValue = returnValue as? String {
            returnValue = Bool(stringValue)
        } else {
            throw ValueConversionError.valueIsNotABool("\"\(returnValue!)\" Could not be expressed as a Bool.")
        }

        if returnValue == nil {
            // May seem redundant, but some of the code above could produce nil, so we need to re-check.
            returnValue = false
        }

        return returnValue as! Bool
    }

    public static func valueAsInteger<T: BinaryInteger>(_ valueIn: Any?) throws -> T {
        var returnValue = valueIn

        if returnValue == nil {
            // I'm not 100% sure this is what I want, but I'm going with it for right now.
            returnValue = T(0)
        } else if returnValue is T {
            // We're already the type that was expected
        } else if returnValue is (any BinaryInteger) {
            // We're a number, but not a number of the correct type
            // Right now, I can only figure out how to make this work via a string. That's quite inefficient, but what ever. Make this better at some point.
            if let number = Int64("\(returnValue!)") {
                returnValue = T(clamping: number)
            }
        } else if returnValue is (any BinaryFloatingPoint) {
            // This is probably worse here than it was above.
            if let number = Double("\(returnValue!)") {
                returnValue = T(number)
            }
        } else if let stringValue = returnValue as? String {
            // Convert a string to a number, if possible.
            if let number = Int64(stringValue) {
                returnValue = T(clamping: number)
            } else if let number = Double(stringValue) {
                returnValue = T(number)
            } else {
                throw ValueConversionError.valueIsNotANumber("Value \"\(valueIn ?? "nil")\" could not be expressed as a number")
            }
        } else {
            throw ValueConversionError.valueIsNotANumber("Value \"\(valueIn ?? "nil")\" could not be expressed as a number")
        }

        return returnValue as! T
    }

    internal static func valueAsFloatingPoint<T: BinaryFloatingPoint>(_ valueIn: Any?) throws -> T {
        var returnValue = valueIn

        if returnValue == nil {
            // I'm not 100% sure this is what I want, but I'm going with it for right now.
            returnValue = T(0.0)
        } else if returnValue is T {
            // We're already the type that was expected
        } else if returnValue is (any BinaryInteger) {
            // We're a number, but not a number of the correct type
            // Right now, I can only figure out how to make this work via a string. That's quite inefficient, but what ever. Make this better at some point.
            if let number = Int64("\(returnValue!)") {
                returnValue = T(number)
            }
        } else if returnValue is (any BinaryFloatingPoint) {
            // This is probably worse here than it was above.
            if let number = Double("\(returnValue!)") {
                returnValue = T(number)
            }
        } else if let stringValue = returnValue as? String {
            // Convert a string to a number, if possible.
            if let number = Int64(stringValue) {
                returnValue = T(number)
            } else if let number = Double(stringValue) {
                returnValue = T(number)
            } else {
                throw ValueConversionError.valueIsNotANumber("Value \"\(valueIn ?? "nil")\" could not be expressed as a number")
            }
        } else {
            throw ValueConversionError.valueIsNotANumber("Value \"\(valueIn ?? "nil")\" could not be expressed as a number")
        }

        return returnValue as! T
    }

    public static func valueAsString(_ value: Any?) throws -> String {
        return value == nil ? "nil" : "\(value!)"
    }

    public static func valueAsDate(_ value: Any?) throws -> Date? {
        var returnValue = value

        if returnValue == nil || returnValue is Date {
            // We're already the type that was expected
        } else if returnValue is (any BinaryInteger) || returnValue is (any BinaryFloatingPoint) {
            if let number = TimeInterval("\(returnValue!)") {
                returnValue = Date(timeIntervalSinceReferenceDate: number)
            }
        } else if let stringValue = returnValue as? String {
            // Convert a string to a number, if possible.
            if let number = TimeInterval(stringValue) {
                returnValue = Date(timeIntervalSinceReferenceDate: number)
            } else {
                returnValue = try Date(utc: stringValue)
            }
        } else if let componentsValue = returnValue as? DateComponents {
            let date : Date? = Calendar.current.date(from: componentsValue)
            returnValue = date
        } else {
            throw ValueConversionError.valueIsNotANumber("Value \"\(value ?? "nil")\" could not be expressed as a time interval")
        }

        return returnValue as? Date
    }

    public static func valueAsTimeZoneDate(_ value: Any?) throws -> AJRTimeZoneDate? {
        var returnValue = value

        if returnValue == nil || returnValue is AJRTimeZoneDate {
            // We're already the type that was expected
        } else if let date = value as? Date {
            returnValue = AJRTimeZoneDate(date: date)
        } else if returnValue is (any BinaryInteger) || returnValue is (any BinaryFloatingPoint) {
            if let number = TimeInterval("\(returnValue!)") {
                returnValue = AJRTimeZoneDate(timeIntervalSinceReferenceDate: number)
            }
        } else if let stringValue = returnValue as? String {
            // Convert a string to a number, if possible.
            if let number = TimeInterval(stringValue) {
                returnValue = AJRTimeZoneDate(timeIntervalSinceReferenceDate: number)
            } else {
                returnValue = try AJRTimeZoneDate(utc: stringValue)
            }
        } else if let componentsValue = returnValue as? DateComponents {
            if let newDate : AJRTimeZoneDate = Calendar.current.date(from: componentsValue) {
                returnValue = newDate
            } else {
                throw ValueConversionError.valueIsNotADate("Cannot create a date from \(componentsValue)")
            }
        } else {
            throw ValueConversionError.valueIsNotANumber("Value \"\(value ?? "nil")\" could not be expressed as a date w/time zone")
        }

        return returnValue as? AJRTimeZoneDate
    }

    public static func valueAsDateComponents(_ value: Any?) throws -> DateComponents? {
        var returnValue = value

        if returnValue == nil || returnValue is DateComponents {
            // We're already the type that was expected
        } else if let dateValue = returnValue as? Date {
            returnValue = Calendar.current.dateComponents(in: TimeZone.current, from: dateValue)
        } else if returnValue is (any BinaryInteger) {
            if let number = Int("\(returnValue!)") {
                returnValue = DateComponents(day: number)
            }
        } else if returnValue is (any BinaryFloatingPoint) {
            if let number = Double("\(returnValue!)") {
                let days = Int(number)
                let hours = Int(number.fraction * 24.0)
                let minutes = Int((number.fraction * 24.0).fraction * 60.0)
                let seconds = Int((number.fraction * 24.0 * 60.0).fraction * 60.0)
                returnValue = DateComponents(day: days, hour: hours, minute: minutes, second: seconds)
            }
        } else {
            throw ValueConversionError.valueIsNotANumber("Value \"\(value ?? "nil")\" could not be expressed as a time interval")
        }

        return returnValue as? DateComponents
    }

    /**
     Returns the input as a collection.

     If `force` is `true`, then we turn a non-collection into a collection of a single object. If `false`, then we'll throw an error.
     */
    public static func valueAsCollection(_ value: Any?, force: Bool) throws -> (any AJRCollection)? {
        var returnValue : (any AJRCollection)? = nil

        // Iterate an expression values until we get a basic value of some sort returned.
        if let value = value as? (any AJRCollection) {
            returnValue = value
        } else if force, let value {
            returnValue = [value]
        } else {
            throw ValueConversionError.valueIsNotACollection("Could not convert \(value ?? "nil") to a collection.")
        }

        return returnValue
    }

}

internal func isCollectionOfStrings<T: Collection>(_ collection: T) -> Bool {
    for value in collection {
        if !(value is String) {
            return false
        }
    }
    return true
}

internal func isCollectionOfNumerics<T: Collection>(_ collection: T, containsDoubles: inout Bool) -> Bool {
    for value in collection {
        // I wish there was a more generic way to do this, but you can't just check against conforming to Numeric
        if value is Int || value is Double || value is Float {
            if value is Double || value is Float {
                containsDoubles = true
            }
        } else {
            return false
        }
    }
    return true
}

internal func doReduction<C: Collection, T: Comparable>(on collection: C, createValue: (C.Element?) -> T?, compareValue: (T, T) -> Bool) -> T? {
    return collection.reduce(nil as T?, { (result, value) -> T? in
        if let result = result {
            if let typed = createValue(value) {
                return compareValue(typed, result) ? typed : result
            }
            return result
        }
        return createValue(value)
    })
}

public struct KeyValueOperators {

    public static func count<C: Collection>(from collection: C) -> Int {
        return collection.count
    }

    public static func maxValue<T: Collection>(from collection: T) -> Any? {
        var containsDoubles = false
        if isCollectionOfStrings(collection) {
            return doReduction(on: collection,
                               createValue: { (value) in return try? Conversion.valueAsString(value) },
                               compareValue: > ) as String?
        } else if isCollectionOfNumerics(collection, containsDoubles: &containsDoubles) {
            if containsDoubles {
                return doReduction(on: collection,
                                   createValue: { (value) in return try? Conversion.valueAsFloatingPoint(value) },
                                   compareValue: >) as Double?
            } else {
                return doReduction(on: collection,
                                   createValue: { (value) in return try? Conversion.valueAsInteger(value) },
                                   compareValue: >) as Int?
            }
        }
        return nil
    }

    public static func minValue<T: Collection>(from collection: T) -> Any? {
        var containsDoubles = false
        if isCollectionOfStrings(collection) {
            return doReduction(on: collection,
                               createValue: { (value) in return try? Conversion.valueAsString(value) },
                               compareValue: < ) as String?
        } else if isCollectionOfNumerics(collection, containsDoubles: &containsDoubles) {
            if containsDoubles {
                return doReduction(on: collection,
                                   createValue: { (value) in return try? Conversion.valueAsFloatingPoint(value) },
                                   compareValue: <) as Double?
            } else {
                return doReduction(on: collection,
                                   createValue: { (value) in return try? Conversion.valueAsInteger(value) },
                                   compareValue: <) as Int?
            }
        }
        return nil
    }

    public static func sum<C: Collection>(from collection: C) -> Any? {
        var containsDoubles = false
        if isCollectionOfNumerics(collection, containsDoubles: &containsDoubles) {
            if containsDoubles {
                return collection.reduce(into: 0.0 as Double) { (result, value) in
                    let doubleValue: Double? = try? Conversion.valueAsFloatingPoint(value)
                    if let value = doubleValue {
                        result += value
                    }
                }
            }
        }
        return nil
    }

    public static func first(from collection: AJRUntypedCollection) -> Any? {
        return collection.untypedFirst()
    }

    public static func last(from collection: AJRUntypedCollection) -> Any? {
        return collection.untypedLast()
    }

}

internal func processSpecialKey<T: Collection>(_ key: String, on collection: T) -> Any? {
    if key == "@count" {
        return KeyValueOperators.count(from: collection)
    } else if key == "@max" {
        return KeyValueOperators.maxValue(from: collection)
    } else if key == "@min" {
        return KeyValueOperators.minValue(from: collection)
    } else if key == "@sum" {
        return KeyValueOperators.sum(from: collection)
    } else if key == "@first" {
        return KeyValueOperators.first(from: collection as! AJRUntypedCollection)
    } else if key == "@last" {
        return KeyValueOperators.last(from: collection as! AJRUntypedCollection)
    } else {
        AJRLog.warning("Unknown aggregate operator: \(key)")
    }
    return nil
}

internal func getValue(forKeyPath path: String, on context: AJREvaluationContext) -> Any? {
    var value: Any? = context.rootObject // We'll assume this to start.
    var modifiedPath = path

    // We're going to have a little bit of duplicate work here in an attempt to determine if we're a key path, and therefore that we should check the store.
    if let range = path.range(of: ".") {
        let key = String(path.prefix(upTo: range.lowerBound))
        // Since we're a key path, let's see if we can find an object named 'key' in the store.
        if let possibleObject = try? AJRExpression.value(context.symbol(named: key), with: context) {
            value = possibleObject
            modifiedPath = String(path.suffix(from: range.upperBound))
        }
    }

    return getValue(forKeyPath: modifiedPath, on: value)
}

internal func getValue(forKeyPath path: String, on value: Any?) -> Any? {
    var newValue: Any? = nil
    let key: String
    let subpath: String?

    if let range = path.range(of: ".") {
        key = String(path.prefix(upTo: range.lowerBound))
        subpath = String(path.suffix(from: range.upperBound))
    } else {
        key = path
        subpath = nil
    }

    if let objects = value as? [Any] {
        if key.hasPrefix("@") {
            newValue = processSpecialKey(key, on: objects)
        } else {
            var newObjects = [Any?]()
            for child in objects {
                if let subpath = subpath {
                    newObjects.append(getValue(forKeyPath: subpath, on: child))
                } else {
                    newObjects.append(getValue(forKeyPath: key, on: child))
                }
            }
            newValue = newObjects
        }
    } else if let objects = value as? [String:Any] {
        newValue = objects[key]
    } else if value == nil || value is NSNull {
        newValue = nil
    } else if let value = value as? AnyObject {
        newValue = value.value(forKey: key)
    } else if let value = value as? AJRKeyValueCoding {
        newValue = value.value(forKeyPath: path)
    } else {
        AJRLog.warning("Can't do value(forKeyPath:\(path) on:\(type(of:value)))")
    }

    if let nonNullNewValue = newValue {
        if let subpath = subpath {
            newValue = getValue(forKeyPath: subpath, on: nonNullNewValue)
        }
    }

    if newValue is NSNull {
        newValue = nil
    }

    return newValue
}
