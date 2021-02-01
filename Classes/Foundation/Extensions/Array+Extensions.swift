//
//  Array+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 1/30/19.
//

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
