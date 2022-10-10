//
//  CollectionSemantics.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

public enum ExpressionCollectionSemantic : Int {
    case objectUnordered
    case objectOrdered
    case keyValueUnordered
    case keyValueOrdered
}

public protocol AJRUntypedCollection : AJRKeyValueCoding, AJREquatable {
    
    func isEqual(to other: Any?) -> Bool
    var untypedCount : Int { get }
    func untypedContains(_ object: Any) -> Bool
    func untypedContainsKey(_ key: AnyHashable) -> Bool
    var untypedCollectionSemantic : ExpressionCollectionSemantic { get }
    func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows
    func untypedEnumerate(_ block: (Int, Any, inout Bool) throws -> Void) rethrows
    func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows

    func untypedPopulate<Element>(array: inout [Element]) -> Void
    func untypedPopulate<Key, Value>(dictionary: inout [Key:Value]) -> Void
    
    func untypedMutableCopy() -> AJRUntypedCollection
    
    func untypedFirst() -> Any?
    func untypedLast() -> Any?

    func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection
    func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection

    var untypedHashable : AnyHashable? { get }

}

extension AJRUntypedCollection {

    public func untypedContainsKey(_ key: AnyHashable) -> Bool {
        return false
    }

    public func untypedPopulate<Element>(array: inout [Element]) -> Void {
        self.untypedEnumerate { (object, stop) in
            array.append(object as! Element)
        }
    }
    
    public func untypedPopulate<Key, Value>(dictionary: inout [Key:Value]) -> Void {
        self.untypedEnumerate { (key, object) in
            dictionary[key as! Key] = object as? Value
        }
    }
    
    public func untypedFirst() -> Any? {
        var value : Any? = nil
        self.untypedEnumerate { (object, stop) in
            value = object
            stop = true
        }
        return value
    }
    
    public func untypedLast() -> Any? {
        // This should be cleaned up, as it's hugely inefficient
        var value : Any? = nil
        untypedEnumerate { (object, stop) in
            value = object
        }
        return value
    }

    public func untypedEnumerate(_ block: (Int, Any, inout Bool) throws -> Void) rethrows {
        var index = 0
        try untypedEnumerate { (value, stop) in
            try block(index, value, &stop)
            index += 1
        }
    }

    /*!
     Similar to join in that the elements in the array are joined by separator and returned as a single string. This is enhanced over join in that if you provide a finalSeparator, that'll be used to separate the last two elements. Additionally, you can provide twoElementSeparator, which is used when there's only two elements.
     
     For example:
     
     var array = ["A", "B", "C"]
     array.untypedJoined(separator: ", ")                                                           // Outputs: "A, B, C"
     array.untypedJoined(separator: ", ", finalSeparator: ", and ")                                 // Outputs: "A, B, and C"
     
     array.removeLast()
     array.untypedJoined(separator: ", ", finalSeparator: ", and ", twoElementSeparator: " and ")   // Outputs: "A and B"
     */
    func untypedJoined(separator: String, finalSeparator: String? = nil, twoElementSeparator: String? = nil) -> String {
        var string = ""
        let count = untypedCount
        if let twoElementSeparator = twoElementSeparator, count == 2 {
            untypedEnumerate({ (index: Int, value, stop) in
                if index > 0 {
                    string += twoElementSeparator
                }
                string += String(describing: value)
            })
        } else {
            untypedEnumerate({ (index: Int, value, stop) in
                if index > 0 {
                    if index == count - 1 && finalSeparator != nil {
                        string += finalSeparator!
                    } else {
                        string += separator
                    }
                }
                string += String(describing: value)
            })
        }
        return string
    }

    public var untypedHashable : AnyHashable? {
        let any : Any = self
        return any as? AnyHashable
    }

}

extension Array : AJRKeyValueCoding, AJRUntypedCollection {
    public func value(forKeyPath path: String) -> Any? {
        return getValue(forKeyPath: path, on: self)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .objectOrdered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (index: Int, object: Any, stop: inout Bool) in
                if !AJREqual(self[index], object) {
                    equalToOther = false
                    stop = true
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .objectOrdered }

    public func untypedContains(_ object: Any) -> Bool {
        if let object = object as? Element {
            return self.contains(where: { (enumeratedObject) in return AJREqual(object, enumeratedObject) })
        }
        return false
    }
    
    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for index in 0..<self.count {
            var stop = false
            try block(self[index], &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for index in 0..<self.count {
            var stop = false
            try block(index, self[index], &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newArray = AJRMutableArray<Any>()
        
        for object in self {
            if let object = object as? AJRUntypedCollection {
                newArray.append(object.untypedMutableCopy())
            } else {
                newArray.append(object)
            }
        }
        
        return newArray
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        var new = [Any]()

        other.untypedEnumerate { object, stop in
            new.append(object)
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        var new = [Any]()

        self.untypedEnumerate { object, stop in
            if other.untypedContains(object) {
                new.append(object)
            }
        }

        return new
    }

}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NSArray : AJRKeyValueCoding, AJRUntypedCollection {
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .objectOrdered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (index: Int, object: Any, stop: inout Bool) in
                if !AJREqual(self[index], object) {
                    equalToOther = false
                    stop = true
                }
            }
            return equalToOther
        }
        return false
    }

    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .objectOrdered }
    
    public func untypedContains(_ object: Any) -> Bool {
        return self.contains(object)
    }
    
    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for index in 0..<self.count {
            var stop = false
            try block(self[index], &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for index in 0..<self.count {
            var stop = false
            try block(index, self[index], &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newArray = AJRMutableArray<Any>()
        
        for object in self {
            if let object = object as? AJRUntypedCollection {
                newArray.append(object.untypedMutableCopy())
            } else {
                newArray.append(object)
            }
        }
        
        return newArray
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = NSMutableArray()

        other.untypedEnumerate { object, stop in
            new.add(object)
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = NSMutableArray()

        self.untypedEnumerate { object, stop in
            if other.untypedContains(object) {
                new.add(object)
            }
        }

        return new
    }

}
#endif

extension Dictionary : AJRKeyValueCoding, AJRUntypedCollection {

    public func value(forKeyPath path: String) -> Any? {
        return getValue(forKeyPath: path, on: self)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .keyValueUnordered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (key: AnyHashable, object: Any, stop: inout Bool) in
                if let key = key as? Key {
                    if !AJREqual(self[key], object) {
                        equalToOther = false
                        stop = true
                    }
                }
            }
            return equalToOther
        }
        return false
    }

    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .keyValueUnordered }

    public func untypedContains(_ object: Any) -> Bool {
        if let object = object as? Element {
            // This is a bit brute force-ish, but we want to have contains return whether or not the object value is contained, not the key
            for (_, child) in self {
                if !AJREqual(object, child) {
                    return false
                }
            }
            return true
        }
        return false
    }

    public func untypedContainsKey(_ key: AnyHashable) -> Bool {
        var found = false
        untypedEnumerate { objectKey, object, stop in
            if AJREqual(key, objectKey) {
                found = true
                stop = true
            }
        }
        return found
    }

    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for (_, object) in self {
            var stop = false
            try block(object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for (key, object) in self {
            var stop = false
            try block(key, object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newDictionary = AJRMutableDictionary<Key, Any>()
        
        for (key, value) in self {
            if let value = value as? AJRUntypedCollection {
                newDictionary[key] = value.untypedMutableCopy()
            } else {
                newDictionary[key] = value
            }
        }
        
        return newDictionary
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        var new = Dictionary<AnyHashable, Any>()

        other.untypedEnumerate { key, object, stop in
            new[key] = object
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        var new = Dictionary<AnyHashable, Any>()

        self.untypedEnumerate { key, object, stop in
            if other.untypedContainsKey(key) {
                new[key] = object
            }
        }

        return new
    }

}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NSDictionary : AJRKeyValueCoding, AJRUntypedCollection {
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .keyValueUnordered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (key: AnyHashable, object: Any, stop: inout Bool) in
                if !AJREqual(self[key], object) {
                    equalToOther = false
                    stop = true
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .keyValueUnordered }
    
    public func untypedContains(_ object: Any) -> Bool {
        if let object = object as? Element {
            // This is a bit brute force-ish, but we want to have contains return whether or not the object value is contained, not the key
            for (_, child) in self {
                if !AJREqual(object, child) {
                    return false
                }
            }
            return true
        }
        return false
    }

    public func untypedContainsKey(_ key: AnyHashable) -> Bool {
        return self.object(forKey: key) != nil
    }
    
    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for (_, object) in self {
            var stop = false
            try block(object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for (key, object) in self {
            var stop = false
            try block(key as! AnyHashable, object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newDictionary = AJRMutableDictionary<AnyHashable, Any>()
        
        for (key, value) in self {
            if let value = value as? AJRUntypedCollection {
                newDictionary[key as! AnyHashable] = value.untypedMutableCopy()
            } else {
                newDictionary[key as! AnyHashable] = value
            }
        }
        
        return newDictionary
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = NSMutableDictionary()

        other.untypedEnumerate { key, object, stop in
            new[key] = object
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = NSMutableDictionary()

        self.untypedEnumerate { key, object, stop in
            if other.untypedContainsKey(key) {
                new[key] = object
            }
        }

        return new
    }

}
#endif

private func autocast<T>(_ some:Any?) -> T? {
    return some as? T
}

extension Set : AJRKeyValueCoding, AJRUntypedCollection {

    public func value(forKeyPath path: String) -> Any? {
        return getValue(forKeyPath: path, on: self)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .objectUnordered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (object: Any, stop: inout Bool) in
                if let object = object as? Element {
                    if !contains(object) {
                        equalToOther = false
                        stop = true
                    }
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .objectUnordered }

    public func untypedContains(_ object: Any) -> Bool {
        if let object = object as? Element {
            return self.contains(object)
        }
        return false
    }

    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for object in self {
            var stop = false
            try block(object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for (index, object) in self.enumerated() {
            var stop = false
            try block(index, object, &stop)
            if stop {
                break
            }
        }
    }

    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newSet = AJRMutableSet<AnyHashable>()
        
        for object in self {
            if let object = object as? AJRUntypedCollection {
                if let hashable = object.untypedMutableCopy().untypedHashable {
                    newSet.insert(hashable)
                }
            } else {
                newSet.insert(object)
            }
        }
        
        return newSet
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableSet<AnyHashable>()

        for object in self {
            new.insert(object)
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableSet<AnyHashable>()

        for object in self {
            if other.untypedContains(object) {
                new.insert(object)
            }
        }

        return new
    }

}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NSSet : AJRKeyValueCoding, AJRUntypedCollection {
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .objectUnordered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (object: Any, stop: inout Bool) in
                if !contains(object) {
                    equalToOther = false
                    stop = true
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .objectUnordered }
    
    public func untypedContains(_ object: Any) -> Bool {
        return self.contains(object)
    }
    
    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for object in self {
            var stop = false
            try block(object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for (index, object) in self.enumerated() {
            var stop = false
            try block(index, object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newSet = NSMutableSet()
        
        for object in self {
            if let object = object as? AJRUntypedCollection {
                newSet.add(object.untypedMutableCopy())
            } else {
                newSet.add(object as! AnyHashable)
            }
        }
        
        return newSet
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = NSMutableSet()

        for object in self {
            new.add(object)
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = NSMutableSet()

        self.untypedEnumerate { key, object, stop in
            if other.untypedContainsKey(key) {
                new.add(object)
            }
        }

        return new
    }

}
#endif

extension AJRMutableArray : AJRKeyValueCoding, AJRUntypedCollection {
    public func value(forKeyPath path: String) -> Any? {
        return getValue(forKeyPath: path, on: self)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .objectOrdered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (index: Int, object: Any, stop: inout Bool) in
                if !AJREqual(self[index], object) {
                    equalToOther = false
                    stop = true
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .objectOrdered }

    public func untypedContains(_ object: Any) -> Bool {
        if let object = object as? Element {
            return self.contains(where: { (enumeratedObject) in return AJREqual(object, enumeratedObject) } )
        }
        return false
    }

    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for index in 0..<self.count {
            var stop = false
            try block(self[index], &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for index in 0..<self.count {
            var stop = false
            try block(index, self[index], &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newArray = AJRMutableArray<Any>()
        
        for object in self {
            if let object = object as? AJRUntypedCollection {
                newArray.append(object.untypedMutableCopy())
            } else {
                newArray.append(object)
            }
        }
        
        return newArray
    }
    
    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableArray<Any>()

        other.untypedEnumerate { object, stop in
            new.append(object)
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableArray<Any>()

        self.untypedEnumerate { object, stop in
            if other.untypedContains(object) {
                new.append(object)
            }
        }

        return new
    }

}

extension AJRMutableDictionary : AJRKeyValueCoding, AJRUntypedCollection {
    public func value(forKeyPath path: String) -> Any? {
        return getValue(forKeyPath: path, on: self)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .keyValueUnordered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (key: AnyHashable, object: Any, stop: inout Bool) in
                if let key = key as? Key {
                    if !AJREqual(self[key], object) {
                        equalToOther = false
                        stop = true
                    }
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .keyValueUnordered }

    public func untypedContains(_ object: Any) -> Bool {
        // This is a bit brute force-ish, but we want to have contains return whether or not the object value is contained, not the key
        for (_, child) in self {
            if AJREqual(object, child) {
                return true
            }
        }
        return false
    }

    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for (_, object) in self {
            var stop = false
            try block(object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for (key, object) in self {
            var stop = false
            var actualKey : AnyHashable
            // This weirdness is because we sometimes get into a state where we have an AnyHashable that contains another AnyHashable, which will throw off lookups and equalities.
            if (key as AnyHashable).base is AnyHashable {
                actualKey = (key as AnyHashable).base as! AnyHashable
            } else {
                actualKey = key
            }
            try block(actualKey, object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newDictionary = AJRMutableDictionary<Key, Any>()
        
        for (key, value) in self {
            if let value = value as? AJRUntypedCollection {
                newDictionary[key] = value.untypedMutableCopy()
            } else {
                newDictionary[key] = value
            }
        }
        
        return newDictionary
    }

    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableDictionary<AnyHashable, Any>()

        other.untypedEnumerate { key, object, stop in
            new[key] = object
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableDictionary<AnyHashable, Any>()

        self.untypedEnumerate { key, object, stop in
            if other.untypedContainsKey(key) {
                new[key] = object
            }
        }

        return new
    }

}

extension AJRMutableSet : AJRKeyValueCoding, AJRUntypedCollection {

    public func value(forKeyPath path: String) -> Any? {
        return getValue(forKeyPath: path, on: self)
    }
    
    public func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUntypedCollection, other.untypedCollectionSemantic == .objectUnordered {
            if self.count != other.untypedCount {
                return false
            }
            var equalToOther = true
            other.untypedEnumerate { (object: Any, stop: inout Bool) in
                if let object = object as? Element {
                    if !contains(object) {
                        equalToOther = false
                        stop = true
                    }
                }
            }
            return equalToOther
        }
        return false
    }
    
    public var untypedCount : Int { return self.count }
    public var untypedCollectionSemantic : ExpressionCollectionSemantic { return .objectUnordered }

    public func untypedContains(_ object: Any) -> Bool {
        if let object = object as? Element {
            return self.contains(object)
        }
        return false
    }
    
    public func untypedEnumerate(_ block: (Any, inout Bool) throws -> Void) rethrows {
        for object in self {
            var stop = false
            try block(object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedEnumerate(_ block: (AnyHashable, Any, inout Bool) throws -> Void) rethrows {
        for (index, object) in self.enumerated() {
            var stop = false
            try block(index, object, &stop)
            if stop {
                break
            }
        }
    }
    
    public func untypedMutableCopy() -> AJRUntypedCollection {
        let newSet = AJRMutableSet<AnyHashable>()
        
        for object in self {
            if let object = object as? AJRUntypedCollection {
                if let hashable = object.untypedMutableCopy().untypedHashable {
                    newSet.insert(hashable)
                }
            } else {
                newSet.insert(object)
            }
        }
        
        return newSet
    }

    public func untypedUnion(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableSet<AnyHashable>()

        for object in self {
            new.insert(object)
        }

        return new
    }

    public func untypedIntersection(with other: AJRUntypedCollection) -> AJRUntypedCollection {
        let new = AJRMutableSet<AnyHashable>()

        for object in self {
            if other.untypedContains(object) {
                new.insert(object)
            }
        }

        return new
    }

}
