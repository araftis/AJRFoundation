/*
 AJRMutableArray.swift
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

public class AJRMutableArray<E> : Sequence, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    public typealias Index = Int
    public typealias Element = E
    public typealias Indices = Range<Int>

    fileprivate var array: [E]
    
    // MARK: - Creating an Array
    
    public init() {
        array = [Element]()
    }
    
    public init<S>(_ sequence: S) where Element == S.Element, S: Sequence {
        array = Array(sequence)
    }
    
    public init(repeating: Element, count: Int) {
        array = Array<Element>(repeating: repeating, count: count)
    }
    
    public required convenience init(arrayLiteral elements: AJRMutableArray.Element...) {
        self.init(elements)
    }
    
    public var count : Int { return array.count }
    public var capacity : Int { return array.capacity }
    public var isEmpty : Bool { return array.isEmpty }
    public var startIndex: Int { return array.startIndex }
    public var endIndex: Int { return array.endIndex }
    public var underestimatedCount: Int { return array.underestimatedCount }
    
    // MARK: - Accessing Elements
    
    public subscript(index: Int) -> Element {
        get {
            return array[index]
        }
        
        set(value) {
            array[index] = value
        }
    }
    
    public var first : Element? { return array.first }
    public var last : Element? { return array.last }
    
    public subscript(range: Range<Int>) -> ArraySlice<Element> {
        return array[range]
    }
    
//    public subscript(range: Range<Int>) -> Slice<Array<Element>> {
//        return array[range]
//    }
//
    // MARK: Adding Elements
    
    public func append(_ object: Element) -> Void {
        array.append(object)
    }
    
    public func insert(_ object: Element, at index: Int) {
        array.insert(object, at: index)
    }

    public func insert<C>(contentsOf collection: C, at index: Int) where Element == C.Element, C: Collection {
        array.insert(contentsOf: collection, at: index)
    }
    
    public func replaceSubrange<C>(_ range: Range<Int>, with collection: C) where Element == C.Element, C: Collection {
        array.replaceSubrange(range, with: collection)
    }
    
    public func replaceSubrange<C, R>(_ range: R, with collection: C) where Element == C.Element, C: Collection, R: RangeExpression, Array<Element>.Index == R.Bound {
        array.replaceSubrange(range, with: collection)
    }
    
    public func reserveCapacity(_ capacity: Int) {
        array.reserveCapacity(capacity)
    }
    
    // MARK: - Combining Arrays
    
    public func append<S>(contentsOf sequence: S) where S: Sequence, Element == S.Element {
        array.append(contentsOf: sequence)
    }
    
    // MARK: - Removing Elements
    
    public func remove(at index: Int) -> Element {
        return array.remove(at: index)
    }
    
    public func removeFirst() -> Element? {
        return array.removeFirst()
    }
    
    public func removeFirst() {
        array.removeFirst()
    }
    
    public func removeLast() -> Element? {
        return array.removeLast()
    }
    public func removeLast(_ count: Int) -> Void {
        array.removeLast(count)
    }
    
    public func removeSubrange(_ range: Range<Int>) {
        array.removeSubrange(range)
    }
    
    public func removeSubrange<R>(_ range: R) where R: RangeExpression, Array<Element>.Index == R.Bound {
        array.removeSubrange(range)
    }
    
    public func removeAll() {
        array.removeAll()
    }
    
    public func removeAll(keepingCapacity capacity: Bool) {
        array.removeAll(keepingCapacity: capacity)
    }
    
    public func removeAll(where predicate: (Element) -> Bool) -> Void {
        // We have to do this the hard way, because we can't yet be sure the underlying method will be in the swift std library
        for (index, object) in array.reversed().enumerated() {
            if predicate(object) {
                array.remove(at: index)
            }
        }
    }
    
    public func popLast() -> Element? {
        return array.popLast()
    }
    
    // MARK: - Finding Elements
    
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try array.contains(where: predicate)
    }
    
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for object in self {
            if !(try predicate(object)) {
                return false
            }
        }
        return true
    }
    
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        return try array.first(where: predicate)
    }
    
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        for (index, value) in self.enumerated() {
            if try predicate(value) {
                return index
            }
        }
        return nil
    }
    
    public func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        for (_, value) in self.enumerated().reversed() {
            if try predicate(value) {
                return value
            }
        }
        return nil
    }
    
    public func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        for (index, value) in self.enumerated().reversed() {
            if try predicate(value) {
                return index
            }
        }
        return nil
    }
    
    public func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try array.min(by: areInIncreasingOrder)
    }
    
    public func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try array.max(by: areInIncreasingOrder)
    }
    
    // MARK: - Selecting Elements
    
    public func filter(_ predicate: (Element) throws -> Bool) rethrows -> [Element] {
        return try array.filter(predicate)
    }
    
    public func prefix(_ count: Int) -> ArraySlice<Element> {
        return array.prefix(count)
    }
    
    public func prefix(through count: Int) -> ArraySlice<Element> {
        return array.prefix(through: count)
    }
    
    public func prefix(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
        return try array.prefix(while: predicate)
    }
    
    public func suffix(_ maxLength: Int) -> ArraySlice<Element> {
        return array.suffix(maxLength)
    }
    
    public func suffix(from index: Int) -> ArraySlice<Element> {
        return array.suffix(from: index)
    }
    
    // MARK: - Excluding Elements
    
    public func dropFirst() -> ArraySlice<Element> {
        return array.dropFirst()
    }
    
    public func dropFirst(_ n: Int) -> ArraySlice<Element> {
        return array.dropFirst(n)
    }
    
    public func dropLast() -> ArraySlice<Element> {
        return array.dropLast()
    }
    
    public func dropLast(_ n: Int) -> ArraySlice<Element> {
        return array.dropLast(n)
    }
    
    public func drop(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
        return try array.drop(while: predicate)
    }
    
    // MARK: - Transforming an Array
    
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try array.compactMap(transform)
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        return try array.reduce(initialResult, nextPartialResult)
    }
    
    public func map<T>(_ mapper: (Element) throws -> T) rethrows -> [T] {
        return try array.map(mapper)
    }
    
//    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
//        return try array.reduce(into: Result, updateAccumulatingResult)
//    }
    
    // MARK: - Iterating Over an Array's Elements
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try array.forEach(body)
    }
    
    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return array.makeIterator()
    }
    
    // MARK: - Reordering and Array's Elements
    
    public func sort(by compare: (Element, Element) -> Bool) {
        array.sort(by: compare)
    }
    
    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> AJRMutableArray<Element> {
        return try AJRMutableArray(array.sorted(by: areInIncreasingOrder))
    }
    
    public func swap(_ firstIndex: Int, _ secondIndex: Int) {
        array.swapAt(firstIndex, secondIndex)
    }
    
    public func partition(by predicate: (Element) throws -> Bool) rethrows -> Int {
        return try array.partition(by: predicate)
    }
    
    // MARK: - Splitting and Joining Elements
    
    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [ArraySlice<Element>] {
        return try array.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
    }
    
    // MARK: - Manipulating Indices
    
    public func index(after i: Int) -> Int {
        return array.index(after: i)
    }
    
    public func formIndex(after i: inout Int) {
        array.formIndex(after: &i)
    }
    
    public func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    
    public func formIndex(before i: inout Int) {
        array.formIndex(before: &i)
    }
    
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return array.index(i, offsetBy: n)
    }
    
    public func formIndex(_ i: inout Int, offsetBy n: Int) {
        return array.formIndex(&i, offsetBy: n)
    }
    
    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return array.index(i, offsetBy: n, limitedBy: limit)
    }
    
    public func formIndex(_ i: inout Int, offsetBy n: Int, limitedBy limit: Int) -> Bool {
        return array.formIndex(&i, offsetBy: n, limitedBy: limit)
    }
    
    public func distance(from start: Int, to end: Int) -> Int {
        return array.distance(from: start, to: end)
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String { return array.description }
    public var debugDescription: String { return array.debugDescription }
    public var customMirror: Mirror { return array.customMirror }
    
}

extension AJRMutableArray where Element: Equatable {

    public func contains(_ object: Element) -> Bool {
        return array.contains(object)
    }
    
    public func firstIndex(of object: Element) -> Int? {
        for (index, value) in self.enumerated() {
            if object == value {
                return index
            }
        }
        return nil
    }
    
    public func lastIndex(of object: Element) -> Int? {
        for (index, value) in self.enumerated().reversed() {
            if object == value {
                return index
            }
        }
        return nil
    }

    public static func == (lhs: AJRMutableArray<Element>, rhs: AJRMutableArray<Element>) -> Bool {
        return lhs.array == rhs.array
    }
    
    public static func != (lhs: AJRMutableArray<Element>, rhs: AJRMutableArray<Element>) -> Bool {
        return lhs.array != rhs.array
    }
    
    public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        return array.elementsEqual(other)
    }
    
    public func elementsEqual<OtherSequence>(_ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence {
        return try array.elementsEqual(other, by: areEquivalent)
    }
    
    public func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix) -> Bool where PossiblePrefix : Sequence, Element == PossiblePrefix.Element {
        return array.starts(with: possiblePrefix)
    }
    
    public func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix, by areEquivalent: (Element, Element) throws -> Bool) rethrows -> Bool where PossiblePrefix : Sequence, Element == PossiblePrefix.Element {
        return try array.starts(with: possiblePrefix, by: areEquivalent)
    }
    
}

extension AJRMutableArray where Element: Comparable {

    public func min() -> Element? {
        return array.min()
    }
    
    public func max() -> Element? {
        return array.max()
    }
    
    public func sort() {
        array.sort()
    }
    
    public func sorted() -> AJRMutableArray<Element> {
        return AJRMutableArray(array.sorted())
    }
    
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        return array.lexicographicallyPrecedes(other)
    }
    
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        return try array.lexicographicallyPrecedes(other, by: areInIncreasingOrder)
    }
    
}

extension AJRMutableArray where Element: Collection {

    public func joined() -> FlattenCollection<Array<Element>> {
        return array.joined()
    }
    
//    public func joined() -> FlattenSequence<Array<Element>> {
//        return array.joined()
//    }
    
}
