//
//  Array+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 1/30/19.
//

import Foundation

public extension Array where Element : Equatable {
    
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

    func enumerate(_ block: (_ object: Element) -> Void) -> Void {
        for object in self {
            block(object)
        }
    }
    
    func findIndex(of object: Element, using comparator: (_ left: Element, _ right: Element) -> ComparisonResult) -> Int? {
        return AJRBinarySearch(object: object, in: self, comparator: comparator)
    }

    func findInsertionPoint(for newObject: Element, using comparator: (_ left: Element, _ right: Element) -> ComparisonResult) -> Int {
        var index : Int = 0
        AJRBinarySearch(object: newObject, in: self, insertionIndex: &index, comparator: comparator)
        return index
    }
    
    @discardableResult
    mutating func insert(sorted object: Element, using comparator: (_ left: Element, _ right: Element) -> ComparisonResult) -> Int {
        let index = findInsertionPoint(for: object, using: comparator)
        insert(object, at: index)
        return index
    }
    
    func any(passing test: (_ object: Element) -> Bool) -> Element? {
        for object in self {
            if test(object) {
                return object
            }
        }
        return nil
    }
    
}

public extension Array where Element : AnyObject {

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

    func findIndex(of object: Element) -> Int? {
        return AJRBinarySearch(object: object, in: self)
    }
    
    func findInsertionPoint(for newObject: Element) -> Int {
        var index : Int = 0
        AJRBinarySearch(object: newObject, in: self, insertionIndex: &index)
        return index
    }
    
    @discardableResult
    mutating func insert(sorted object: Element) -> Int {
        let index = findInsertionPoint(for: object)
        insert(object, at: index)
        return index
    }

}
