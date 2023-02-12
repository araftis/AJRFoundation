/*
 AJRMutableDictionary.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

public class AJRMutableDictionary<Key, Value> : Sequence, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByDictionaryLiteral where Key: Hashable {

    public typealias Element = (key: Key, value: Value)

    enum CodingKeys: String, CodingKey {
        case dictionary
    }

    internal var dictionary: [Key:Value]

    // MARK: - Creation

    public required init() {
        dictionary = [Key:Value]()
    }

    public required init(minimumCapacity: Int) {
        dictionary = Dictionary<Key,Value>(minimumCapacity: minimumCapacity)
    }

    public required init<S>(uniqueKeysWithValues keysAndValues: S) where S: Sequence, S.Element == (Key, Value) {
        dictionary = Dictionary<Key,Value>(uniqueKeysWithValues: keysAndValues)
    }

    public required init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        dictionary = try Dictionary<Key,Value>(keysAndValues, uniquingKeysWith: combine)
    }

    public required init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S : Sequence {
        dictionary = try Dictionary<Key,Value>(grouping: values, by: keyForValue)
    }

    public required init(_ other: [Key:Value]) {
        dictionary = other
    }

    public required init(dictionaryLiteral elements: (Key, Value)...) {
        dictionary = [Key:Value]()
        for element in elements {
            self[element.0] = element.1
        }
    }

    // MARK: - Inspecting a Dictionary

    public var capacity: Int { return dictionary.capacity }
    public var count : Int { return dictionary.count }
    public var isEmpty : Bool { return dictionary.isEmpty }
    public var underestimatedCount: Int { return dictionary.underestimatedCount }

    // MARK: - Accessing Keys and Values

    public subscript(key: Key) -> Value? {
        get {
            return dictionary[key]
        }
        set(newValue) {
            return dictionary[key] = newValue
        }
    }

    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return dictionary[key, default: defaultValue()]
        }
    }

    public var keys: Dictionary<Key, Value>.Keys { return dictionary.keys }
    public var values: Dictionary<Key, Value>.Values { return dictionary.values }
    public var first: (key: Key, value: Value)? { return dictionary.first }

    // MARK: - Adding Keys and Values

    public func updateValue(_ value: Value, forKey key: Key) -> Value? {
        return dictionary.updateValue(value, forKey: key)
    }

    public func merge(_ other: [Key:Value], uniquingKeysWith combine:(Value, Value) throws -> Value) rethrows {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }

    public func merge<S>(_ sequence: S, uniquingKeysWith combine: (Value, Value) -> Value) where S : Sequence, S.Element == (Key, Value) {
        dictionary.merge(sequence, uniquingKeysWith: combine)
    }

    public func merging(_ other: AJRMutableDictionary<Key,Value>, uniquingKeysWith combine: (Value, Value) -> Value) -> AJRMutableDictionary<Key, Value> {
        return AJRMutableDictionary(dictionary.merging(other.dictionary, uniquingKeysWith: combine))
    }

    public func merging(_ other: [Key:Value], uniquingKeysWith combine: (Value, Value) -> Value) -> AJRMutableDictionary<Key, Value> {
        return AJRMutableDictionary(dictionary.merging(other, uniquingKeysWith: combine))
    }

    public func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> AJRMutableDictionary<Key, Value> where S : Sequence, S.Element == (Key, Value) {
        return AJRMutableDictionary(try dictionary.merging(other, uniquingKeysWith: combine))
    }

    public func reserveCapacity(_ capacity: Int) {
        dictionary.reserveCapacity(capacity)
    }

    // MARK: - Removing Keys and Values

    public func filter(_ filter: (Element) -> Bool) -> AJRMutableDictionary<Key, Value> {
        let new = AJRMutableDictionary<Key, Value>()
        for element in dictionary {
            if filter(element) {
                new[element.key] = element.value
            }
        }
        return new
    }

    public func removeValue(forKey key: Key) -> Value? {
        return dictionary.removeValue(forKey: key)
    }

    public func remove(at index: Dictionary<Key,Value>.Index) -> Element {
        return dictionary.remove(at: index)
    }

    public func removeAll() {
        dictionary.removeAll()
    }

    public func removeAll(keepingCapacity flag: Bool) {
        dictionary.removeAll(keepingCapacity: flag)
    }

    // MARK: - Iterating over Keys and Values

    public func forEach(_ body: (Element) -> Void) {
        dictionary.forEach(body)
    }

    public func enumerated() -> EnumeratedSequence<Dictionary<Key, Value>> {
        return dictionary.enumerated()
    }

    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return dictionary.makeIterator()
    }

    // MARK: - Finding Elements

    public func contains(where predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> Bool {
        return try dictionary.contains(where: predicate)
    }

    public func allSatisfy(_ test: (Element) -> Bool) -> Bool {
        for element in self {
            if !test(element) {
                return false
            }
        }
        return true
    }

    public func first(where condition: (Element) -> Bool) -> Element? {
        return dictionary.first(where: condition)
    }

    public func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try dictionary.min(by: areInIncreasingOrder)
    }

    public func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try dictionary.max(by: areInIncreasingOrder)
    }

    // MARK: - Transforming a Dictionary

    public func mapValues<T>(_ mapper: (Value) -> T) -> AJRMutableDictionary<Key, T> {
        let new = AJRMutableDictionary<Key, T>()
        for element in self {
            new[element.key] = mapper(element.value)
        }
        return new
    }

    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        return try dictionary.reduce(initialResult, nextPartialResult)
    }

    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        return try dictionary.reduce(into: initialResult, updateAccumulatingResult)
    }

    public func compactMap<ElementOfResult>(_ transform: ((key: Key, value: Value)) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try dictionary.compactMap(transform)
    }

    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        return try dictionary.sorted(by: areInIncreasingOrder)
    }

    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        return try dictionary.map(transform)
    }

    // MARK: - Describing a Dictionary

    public var description: String { return dictionary.description }
    public var debugDescription : String { return dictionary.description }
    public var customMirror : Mirror { return dictionary.customMirror }

}

extension AJRMutableDictionary : Equatable where Key : Hashable, Value: Equatable {

    // MARK: - Comparing Dictionaries

    public static func == (lhs: AJRMutableDictionary<Key, Value>, rhs: AJRMutableDictionary<Key, Value>) -> Bool {
        return lhs.dictionary == rhs.dictionary
    }

    public static func == (lhs: [Key:Value], rhs: AJRMutableDictionary<Key, Value>) -> Bool {
        return lhs == rhs.dictionary
    }

    public static func == (lhs: AJRMutableDictionary<Key, Value>, rhs: [Key:Value]) -> Bool {
        return lhs.dictionary == rhs
    }

    public static func != (lhs: AJRMutableDictionary<Key, Value>, rhs: AJRMutableDictionary<Key, Value>) -> Bool {
        return !(lhs.dictionary == rhs.dictionary)
    }

    public static func != (lhs: [Key:Value], rhs: AJRMutableDictionary<Key, Value>) -> Bool {
        return lhs != rhs.dictionary
    }

    public static func != (lhs: AJRMutableDictionary<Key, Value>, rhs: [Key:Value]) -> Bool {
        return lhs.dictionary != rhs
    }

}

// MARK: - Encoding and Decoding

extension AJRMutableDictionary : Encodable where Key: Hashable, Key: Encodable, Value: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dictionary, forKey: .dictionary)
    }

}

// This is working, because the init is giving me a weird error that I haven't been able to figure out yet, and since I don't need this method right off, I'm going to ignore it for now.
//extension AJRMutableDictionary : Decodable where Key : Decodable, Key : Hashable, Value : Decodable {
//
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        dictionary = try values.decode([Key:Value].self, forKey: .dictionary)
//    }
//
//}

extension AJRMutableDictionary : Collection where Key : Hashable {

    public var startIndex: Dictionary<Key, Value>.Index { return dictionary.startIndex }

    public var endIndex: Dictionary<Key, Value>.Index { return dictionary.endIndex }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        return dictionary.index(after: i)
    }

    public func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        return dictionary.index(forKey: key)
    }
    
    public subscript(index: Dictionary<Key,Value>.Index) -> Element {
        get {
            return dictionary[index]
        }
    }
    
}
