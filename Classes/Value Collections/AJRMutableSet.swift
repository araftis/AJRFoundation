/*
 AJRMutableSet.swift
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

public class AJRMutableSet<Element> : Sequence, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable, Equatable, Collection, Hashable, ExpressibleByArrayLiteral where Element : Hashable {
    
    public var set: Set<Element>
    
    // MARK: - Creating
    
    public init() {
        set = Set<Element>()
    }
    
    public init(minimumCapacity: Int) {
        set = Set<Element>(minimumCapacity: minimumCapacity)
    }
    
    public init(_ other: Set<Element>) {
        set = Set<Element>(other)
    }
    
    public init<S>(_ other: S) where Element == S.Element, S: Sequence{
        set = Set<Element>(other)
    }
    
    public required convenience init(arrayLiteral elements: AJRMutableSet.Element...) {
        self.init(elements)
    }
    
    // MARK: - Inspecting
    
    public var capacity : Int { return set.capacity }
    public var count : Int { return set.count }
    public var underestimatedCount: Int { return set.underestimatedCount }
    public var isEmpty : Bool { return set.isEmpty }
    public var first : Element? { return set.first }
    public func hash(into hasher: inout Hasher) {
        set.hash(into: &hasher)
    }
    public var startIndex: Set<Element>.Index { return set.startIndex }
    public var endIndex: Set<Element>.Index { return set.endIndex }
    
    // MARK: - Testing for Membership
    
    public func contains(_ object: Element) -> Bool {
        return set.contains(object)
    }

    @discardableResult
    public func insert(_ object: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        return set.insert(object)
    }
    
    public func update(with object: Element) -> Element? {
        return set.update(with: object)
    }
    
    public func reserveCapacity(_ capacity: Int) -> Void {
        set.reserveCapacity(capacity)
    }
    
    // MARK: - Removing
    
    public func filter(_ filter: (Element) throws -> Bool) rethrows -> AJRMutableSet<Element> {
        return AJRMutableSet<Element>(try set.filter(filter))
    }
    
    public func remove(_ object: Element) -> Element? {
        return set.remove(object)
    }
    
    public func removeFirst() -> Element {
        return set.removeFirst()
    }
    
    public func remove(at index: Set<Element>.Index) -> Element {
        return set.remove(at: index)
    }
    
    public func removeAll() -> Void {
        set.removeAll()
    }
    
    public func removeAll(keepingCapacity: Bool) -> Void {
        set.removeAll(keepingCapacity: keepingCapacity)
    }
    
    // MARK: - Combining Sets
    
    public func union<S>(_ other: S) -> AJRMutableSet<Element> where Element == S.Element, S : Sequence {
        return AJRMutableSet<Element>(set.union(other))
    }
    
    public func formUnion<S>(_ other: S) -> Void where Element == S.Element, S: Sequence {
        set.formUnion(other)
    }
    
    public func intersection<S>(_ other: S) -> AJRMutableSet<Element> where Element == S.Element, S : Sequence {
        return AJRMutableSet<Element>(set.intersection(other))
    }
    
    public func formIntersection<S>(_ other: S) -> Void where Element == S.Element, S: Sequence {
        set.formIntersection(other)
    }
    
    public func symmetricDifference<S>(_ other: S) -> AJRMutableSet<Element> where Element == S.Element, S : Sequence {
        return AJRMutableSet<Element>(set.symmetricDifference(other))
    }
    
    public func formSymmetricDifference<S>(_ other: S) -> Void where Element == S.Element, S: Sequence {
        set.formSymmetricDifference(other)
    }
    
    public func subtract<S>(_ other: S) -> Void where Element == S.Element, S: Sequence {
        set.subtract(other)
    }
    
    public func subtracting<S>(_ other: S) -> AJRMutableSet<Element> where Element == S.Element, S: Sequence {
        return AJRMutableSet(set.subtracting(other))
    }
    
    // MARK: - Comparing Sets
    
    public static func == (lhs: AJRMutableSet<Element>, rhs: AJRMutableSet<Element>) -> Bool {
        return lhs.set == rhs.set
    }
    
    public func isSubset(of other: AJRMutableSet<Element>) -> Bool {
        return set.isSubset(of: other.set)
    }
    
    public func isSubset<S>(of sequence: S) -> Bool where Element == S.Element, S: Sequence {
        return set.isSubset(of: sequence)
    }
    
    public func isStrictSubset(of other: AJRMutableSet<Element>) -> Bool {
        return set.isStrictSubset(of: other.set)
    }
    
    public func isStrictSubset<S>(of sequence: S) -> Bool where Element == S.Element, S: Sequence {
        return set.isStrictSubset(of: sequence)
    }
    
    public func isSuperset(of other: AJRMutableSet<Element>) -> Bool {
        return set.isSuperset(of: other.set)
    }
    
    public func isSuperset<S>(of sequence: S) -> Bool where Element == S.Element, S: Sequence {
        return set.isSuperset(of: sequence)
    }
    
    public func isStrictSuperset(of other: AJRMutableSet<Element>) -> Bool {
        return set.isStrictSuperset(of: other.set)
    }
    
    public func isStrictSuperset<S>(of sequence: S) -> Bool where Element == S.Element, S: Sequence {
        return set.isStrictSuperset(of: sequence)
    }
    
    public func isDisjoint(with other: AJRMutableSet<Element>) -> Bool {
        return set.isDisjoint(with: other.set)
    }
    
    public func isDisjoint<S>(with sequence: S) -> Bool where Element == S.Element, S: Sequence {
        return set.isDisjoint(with: sequence)
    }
    
    // MARK: - Finding Elements
    
    public subscript(index: Set<Element>.Index) -> Element {
        return set[index]
    }
    
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try set.contains(where: predicate)
    }
    
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        return try set.first(where: predicate)
    }
    
    public func min(by predicate: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try set.min(by: predicate)
    }
    
    public func max(by predicate: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try set.max(by: predicate)
    }
    
    // MARK: - Transforming a Set
    
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try set.compactMap(transform)
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        return try set.reduce(initialResult, nextPartialResult)
    }
    
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        return try set.reduce(into: initialResult, updateAccumulatingResult)
    }
    
    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        return try set.sorted(by: areInIncreasingOrder)
    }
    
    public var lazy: LazySequence<Set<Element>> {
        return set.lazy
    }
    
    // MARK: - Iterating Over a Set
    
    public func enumerated() -> EnumeratedSequence<Set<Element>> {
        return set.enumerated()
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try set.forEach(body)
    }
    
    public func makeIterator() -> SetIterator<Element> {
        return set.makeIterator()
    }
    
    // MARK: - Describing a Set
    
    public var description : String {
        return set.description
    }
    
    public var debugDescription: String {
        return set.debugDescription
    }
    
    public var customMirror: Mirror {
        return set.customMirror
    }
    
    // MARK: - Mapping
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        return try set.map(transform)
    }
    
    // MARK: - Collection
    
    public func index(after i: Set<Element>.Index) -> Set<Element>.Index {
        return set.index(after: i)
    }
    
}

public extension AJRMutableSet where Element : Comparable {
    
    func sorted() -> [Element] {
        return set.sorted()
    }
    
    func min() -> Element? {
        return set.min()
    }
    
    func max() -> Element? {
        return set.max()
    }
    
}

public extension AJRMutableSet where Element : StringProtocol {
    
    func joined(separator: String) -> String {
        return set.joined(separator: separator)
    }
    
}
