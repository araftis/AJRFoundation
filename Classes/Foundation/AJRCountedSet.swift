/*
AJRCountedSet.swift
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

import Cocoa

public struct AJRCountedSet<E: Hashable>: Equatable, Collection {

    public typealias Element = E
    public typealias Index = Int

    public typealias Indices = Range<Int>

    internal var dictionary = [Element:Int]()

    internal var totalCount : Int = 0

    /**
     Creates an empty ordered set.
     */
    public init() {
    }

    /**
     Creates an ordered set with the contents of `array`.
    
     If an element occurs more than once in `element`, only the first one will be included.
     
     - parameter array: The elements to initialize with.
     */
    public init(_ array: [Element]) {
        self.init()
        for element in array {
            insert(element)
        }
    }

    /**
     The number of elements the ordered set stores.
     */
    public var count: Int { return dictionary.count }

    /**
     Returns `true` if the set is empty.
     */
    public var isEmpty: Bool { return dictionary.isEmpty }

    /**
     Returns the contents of the set as an array.
     */
    public var contents: [Element] {
        var contents = [Element]()
        for (key, _) in dictionary {
            contents.append(key)
        }
        return contents
    }

    /**
     Returns `true` if the counted set contains `member`.
     */
    public func contains(_ member: Element) -> Bool {
        return dictionary[member] != nil
    }

    /**
     Adds an element to the ordered set.
    
     If the set already contains the element, then the count incremented, otherwise it's set to 1.
    
     - parameter newElement: The element to add to the counted set.
     
     - returns: True if the item was inserted.
     */
    @discardableResult
    public mutating func insert(_ newElement: Element) -> Bool {
        if let current = dictionary[newElement] {
            dictionary[newElement] = current + 1
            totalCount += 1
            return false
        } else {
            dictionary[newElement] = 1
            totalCount += 1
            return true
        }
    }

    /**
     Adds all of the elements in collection to the set.
     
     - parameter newElements: The elements to add.
     */
    @inlinable public mutating func insert<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence {
        for element in newElements {
            insert(element)
        }
    }

    /**
     Decrements the count of an element in the set, and if the count goes to 0, the element is removed.
     
     - parameter element: The element to remove.
     
     - returns Returns the element if it's removed, or nil otherwise. Note that nil can be returned when the set contains element, because the element's count was greater than 0.
     */
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        if let current = dictionary[element] {
            if current == 1 {
                dictionary.removeValue(forKey: element)
                totalCount -= 1
                return element
            } else {
                dictionary[element] = current - 1
                totalCount -= 1
                return nil
            }
        }
        return nil
    }

    /**
     Removes all elemens in `other` from the receiver.
     */
    public mutating func remove<S>(contentsOf other: S) where Element == S.Element, S : Sequence {
        for element in other {
            self.remove(element)
        }
    }

    /**
     Remove all elements.
     
     This removes all elements, regardless of their count. As such, the set will be empty after this call.
     
     - parameter keepCapacity: If `true`, the set's storage is not decreased.
     */
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        dictionary.removeAll(keepingCapacity: true)
    }
    
    /**
     Finds the intersection of the receiver with the contents of Sequence.
     */
    public mutating func formIntersection<S>(_ other: S) where Element == S.Element, S : Sequence {
        var toRemove = Set<Element>()
        for element in self {
            if !other.contains(element) {
                toRemove.insert(element)
            }
        }
        self.remove(contentsOf: toRemove)
    }
    
    /**
     Returns the count of `element`, or `nil` if the set doesn't contain `element`.
     
     - parameter element: The element to query.
     */
    public func count(for element: Element) -> Int? {
        return dictionary[element]
    }
    
    /**
     Returns the count of all objects in the set. This will be >= set.count.
     */
    public var countForAll: Int {
        return totalCount // We hide this and make it readonly.
    }
}

extension AJRCountedSet: ExpressibleByArrayLiteral {
    /**
     Create an instance initialized with `elements`.
    
     If an element occurs more than once in `element`, only the first one will be included.
     */
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension AJRCountedSet: RandomAccessCollection {
    public var startIndex: Int { return contents.startIndex }
    public var endIndex: Int { return contents.endIndex }
    public subscript(index: Int) -> Element {
      return contents[index]
    }
}

public func == <T>(lhs: AJRCountedSet<T>, rhs: AJRCountedSet<T>) -> Bool {
    return lhs.contents == rhs.contents
}

extension AJRCountedSet: Hashable where Element: Hashable { }
