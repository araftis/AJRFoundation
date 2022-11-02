/*
 Array+Extensions.swift
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

public extension Array where Element : Equatable {

    /**
     If the array is filled with objects conforming to Equatable, this method return the object matching `element`.

     - parameter element The element to remove.
     */
    mutating func remove(element: Element) -> Void {
        for index in 0 ..< count {
            if self[index] == element {
                remove(at:index)
                break;
            }
        }
    }

    /**
     Removes all the elements contained in `indexes`. If your objects are also Hashable, there's a more efficient version of this method.

     - parameter indexes: The indexes of objects to remove.
     */

    mutating func remove(at indexes: IndexSet) -> Void {
        for index : Int in indexes.reversed() {
            remove(at: index)
        }
    }
    
}

public extension Array {

    /**
     If the array is sorted, this method returns the index of `object` using `comparator`, or nil if the object can't be found. If the array is not sorted, the return value is undefined.

     - parameter object The object to find.
     - parameter comparator A block used to compare element in the array.

     - returns The index of `object` or nil.
     */
    func findIndex(of object: Element, using comparator: (_ left: Element, _ right: Element) -> ComparisonResult) -> Int? {
        return AJRBinarySearch(object: object, in: self, comparator: comparator)
    }

    /**
     If the array is sorted, this method returns the index position where `newObject` should be inserted.

     If the array isn't sorted, the return index will be undefined.

     - parameter newObject The object you'd like to insert.
     - parameter comparator A block to compare objects in the Array.

     - returns The insertion index.
     */
    func findInsertionPoint(for newObject: Element, using comparator: (_ left: Element, _ right: Element) -> ComparisonResult) -> Int {
        var index : Int = 0
        AJRBinarySearch(object: newObject, in: self, insertionIndex: &index, comparator: comparator)
        return index
    }

    /**
     Inserts object into the array.

     If the array is not sorted, the insertion location will be undefined.

     - parameter object The object to insert.
     - parameter comparator A block to compare the objects in the array.
     */
    @discardableResult
    mutating func insert(sorted object: Element, using comparator: (_ left: Element, _ right: Element) -> ComparisonResult) -> Int {
        let index = findInsertionPoint(for: object, using: comparator)
        insert(object, at: index)
        return index
    }
    
    /**
     Returns an array containing all object for `indexes`.
     
     - parameter indexes: An index set with all the indexes for the objects you want returned.
     
     - returns: A subarray with the objects referenced by  `indexes`.
     */
    subscript(_ indexes: IndexSet) -> [Element] {
        var found = Array<Element>()
        for index in indexes {
            found.append(self[index])
        }
        return found
    }
    
}

public extension Array where Element : AnyObject {

    /**
     For an array of NSObjects, this method returns the index of an object that is located at the same memory address.

     - parameter other The Object to fine.

     - returns The index of the object, or nil if it wasn't found.
     */
    func index(ofObjectIdenticalTo other: Element) -> Int? {
        for (index, child) in self.enumerated() {
            if child === other {
                return index
            }
        }
        return nil
    }
    
    /**
     For each object in `other`, it finds the index of the corresponding object in the receiver. If no object is found, nothing is inserted into the return value. As such, this method cannot be reliably used to determine if objects are all in the receiver, as you'll know how many objects were not found, but not which ones they were. Still, this can be useful if you're not worried about know exactly which objects were missing.
     
     - parameter other: The array object who's indexes you want to know.
     
     - returns: An IndexSet containing the indexes of the input `other`.
     */
    func indexes(ofObjectsIdenticalTo other: [Element]) -> IndexSet {
        var indexes = IndexSet()
        for object in other {
            if let index = index(ofObjectIdenticalTo: object) {
                indexes.insert(index)
            }
        }
        return indexes
    }

    mutating func remove(identicalTo object: Element) -> Void {
        if let index = index(ofObjectIdenticalTo: object) {
            remove(at: index)
        }
    }

    mutating func remove(identicalIn objects: [Element]) -> Void {
        for object in objects {
            if let index = index(ofObjectIdenticalTo: object) {
                remove(at: index)
            }
        }
    }
    
}

public extension Array where Element : Hashable {

    /**
     Returns an array that contains no duplicate obejcts. Order is preserved.

     - returns The contents of the array, uniqued.
     */
    var uniqueObjects : [Element] {
        var orderedSet = Set<Element>()
        for object in self {
            orderedSet.insert(object)
        }
        var unique = [Element]()
        for object in orderedSet {
            unique.append(object)
        }
        return unique
    }

    var unorderedUniqueObjects : Set<Element> {
        var set = Set<Element>()
        for object in self {
            set.insert(object)
        }
        return set
    }

    /**
     Removes all the elements contained in `indexes`.

     - parameter indexes: The indexes of objects to remove.
     */
    mutating func remove(at indexes: IndexSet) -> Void {
        var others = Set<Element>()
        for index in indexes {
            others.insert(self[index])
        }
        removeAll(in: others)
    }

    /**
     Removes all the elements in `others` from the receiver. This must first build a set of the objects to be removed, so it can be more efficient to call the set version, if you have a set of the object's available.

     - parameter others: The objects to remove.
     */
    mutating func removeAll(in others: [Element]) -> Void {
        removeAll(in: unorderedUniqueObjects)
    }

    /**
     Removes all the elements in `others` from the receiver.

     - parameter others: The objects to remove.
     */
    mutating func removeAll(in others: Set<Element>) -> Void {
        removeAll { element in
            return others.contains(element)
        }
    }

}

/**
 On a sorted array, performs a binary search for object, returning the index of the object or nil if it wasn't found. If the list is not sorted, this return value is undefined.

 This function can be used to find objects already in the array, or where objects should be inserted into the array. The array must occur in the order that would be determined by sorting the array according to `comparator `.

 - parameter object The object to find.
 - parameter array The array to search.
 - parameter lowerIndex The lower index or nil. Nil indicates the first index in the array.
 - parameter upperIndex The upper index of nil. Nil indicates the last index in the array.
 - parameter insertionIndex If not nil, the insertion index is returned if the object is not in the array.
 - parameter comparator A compare to compare values in the array.

 - returns The index of the object or nil.
 */
@discardableResult
public func AJRBinarySearch<T>(object key: T,
                               in array: [T],
                               lowerIndex idxBottomIn: Int? = nil,
                               upperIndex idxTopIn: Int? = nil,
                               insertionIndex insertIndex: UnsafeMutablePointer<Int>? = nil,
                               comparator: (_ left: T, _ right: T) -> ComparisonResult) -> Int? {
    let idxBottom = idxBottomIn == nil ? 0 : idxBottomIn!
    let idxTop = idxTopIn == nil ? array.count : idxTopIn!
    var idxMiddle: Int
    var result: ComparisonResult
    
    if array.count == 0 {
        insertIndex?.pointee = 0
        return nil
    }
    
    if idxBottom == idxTop {
        result = comparator(key, array[idxBottom])
        if result == .orderedSame {
            insertIndex?.pointee = idxBottom
            return idxBottom
        }
        insertIndex?.pointee = idxBottom
        return nil
    }
    
    idxMiddle = (idxBottom + idxTop) / 2
    if idxMiddle == idxBottom {
        result = comparator(key, array[idxMiddle])
        if result == .orderedSame {
            insertIndex?.pointee = idxMiddle
            return idxMiddle
        } else if result < .orderedSame {
            insertIndex?.pointee = idxMiddle
        } else if result > .orderedSame {
            insertIndex?.pointee = idxMiddle + 1
        }
        return nil
    }
    
    result = comparator(key, array[idxMiddle])
    if result < .orderedSame {
        return AJRBinarySearch(object: key, in: array, lowerIndex: idxBottom, upperIndex: idxMiddle, insertionIndex: insertIndex, comparator: comparator)
    } else if result == .orderedSame {
        insertIndex?.pointee = idxMiddle
        return idxMiddle
    }
     /* else if result > .orderedSame */
    // NOTE: If I use the comparison above, the compiler can't determine that we'll never reach any following code, which throws off my code coverage.
    return AJRBinarySearch(object: key, in: array, lowerIndex: idxMiddle, upperIndex: idxTop, insertionIndex: insertIndex, comparator: comparator)
}

/**
 Mostly calls AJRBinarySearch with a comparator that makes use of the fact that the contents of the array implement the  `Comparable` protpcol.

 - parameter object The object to find.
 - parameter array The array to search.
 - parameter lowerIndex The lower index or nil. Nil indicates the first index in the array.
 - parameter upperIndex The upper index of nil. Nil indicates the last index in the array.
 - parameter insertionIndex If not nil, the insertion index is returned if the object is not in the array.

 - returns The index of the object or nil.
 */
@discardableResult
public func AJRBinarySearch<T: Comparable>(object key: T,
                                           in array: [T],
                                           lowerIndex: Int? = nil,
                                           upperIndex: Int? = nil,
                                           insertionIndex: UnsafeMutablePointer<Int>? = nil) -> Int? {
    return AJRBinarySearch(object: key,
                           in: array,
                           lowerIndex: lowerIndex,
                           upperIndex: upperIndex,
                           insertionIndex: insertionIndex,
                           comparator: AJRCompare)
}

public extension Array where Element : Comparable {

    /**
     Returns the first index of `object` in an array who's content that implements `Comparable`

     - parameter object The object to find.

     - returns The index of `object` or nil if the object cannot be found.
     */
    func findIndex(of object: Element) -> Int? {
        return AJRBinarySearch(object: object, in: self)
    }

    /**
     Returns where `newObject` should be inserted into the array. The array must be sorted.

     - parameter newObject The object you plan to insert.

     - returns The index of where the object should be inserted. This value is undefined if the array is not sorted.
     */
    func findInsertionPoint(for newObject: Element) -> Int {
        var index : Int = 0
        AJRBinarySearch(object: newObject, in: self, insertionIndex: &index)
        return index
    }

    /**
     Inserted `object` into the receiver, returning the index position where the object was inserted.

     If the receiver is not sorted, the insertion location is undefined.

     - parameter object The object to insert.

     - returns The index where the object was inserted.
     */
    @discardableResult
    mutating func insert(sorted object: Element) -> Int {
        let index = findInsertionPoint(for: object)
        insert(object, at: index)
        return index
    }

}

public extension Array where Element: BinaryInteger {

    /**
     Returns the greatest common denominator of all integers in the array.
     */
    var gcd : Element {
        if self.count == 0 {
            return 0
        }
        if self.count == 1 {
            return self[0]
        }
        var gcd = self[0].gcd(self[1])
        if self.count == 2 {
            return gcd
        }

        for index in stride(from: 2, to: self.count, by: 1) {
            gcd = gcd.gcd(self[index])
        }

        return gcd
    }

    /**
     An array of distances between all elements contained in the array.

     So, say you have an array: [1, 5 15, 30], this would return [4, 14, 29, 10, 25, 5].
     */
    var allDistances : [Element] {
        var found = [Element]()

        for x in stride(from: 0, to: count, by: 1) {
            for y in stride(from: 0, to: count, by: 1) {
                if x != y {
                    found.append((self[x] - self[y]).abs)
                }
            }
        }
        return found.uniqueObjects
    }

}

public extension Array where Element : NSObject {
    
    func nextTitle(forKey key: String, basename: String) -> String {
        // This wouldn't always be particularly efficient, but it's code that's not generally called a lot, and when it is called, it won't really be called on huge lists.
        var names = Set<String>()
        
        for object in self {
            if let title = object.value(forKey: key) as? String {
                names.insert(title)
            }
        }
        
        var index = 1
        repeat {
            let test = "\(basename) \(index)"
            if !names.contains(test) {
                return test;
            }
            index += 1
        } while true
    }
    
}

public extension Array where Element == AJRInvalidation {
    
    func invalidateObjects() -> Void {
        for object in self {
            object.invalidate()
        }
    }
    
}


// Original code from: https://medium.com/@apstygo/implementing-weak-arrays-with-property-wrappers-in-swift-680e2b3c9fca

public final class WeakObject<T: AnyObject> {
    private(set) weak var value: T?
    public init(_ v: T) {
        value = v
    }
}

@propertyWrapper
public struct Weak<Element> where Element: AnyObject {

    internal var storage = [WeakObject<Element>]()

    public var wrappedValue : [Element] {
        get {
            storage.compactMap { $0.value }
        }
        set {
            storage = newValue.map { WeakObject($0) }
        }
    }

    public init() {
    }

}


