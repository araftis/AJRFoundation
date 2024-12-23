/*
 AJREquatable.swift
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

extension NSNull : Comparable {
    
    public static func < (lhs: NSNull, rhs: NSNull) -> Bool {
        return false
    }
    
}

public enum AJRNumericError : Error {
    case cannotRepresentValue
}

public protocol AJREquatable {
    
    func isEqual(_ other: Any?) -> Bool
    
}

public extension AJREquatable {

    // So, I had to look this up, but isEqualTo: is used for things like scripting, namely AppleScript, and provides a secondary implementation if, for some reason, you need eqaulity to work differently between normal usage and scripting usage. We're going to make sure they're the same.
    func isEqual(_ other: Any?) -> Bool {
        return self.isEqual(other)
    }

}

public protocol AJRValueForUntypedComparison {
    func signedValueForComparison() throws -> Int64
    func unsignedValueForComparison() throws -> UInt64
    var isFloatingPoint : Bool { get }
}

public protocol AJRValueForUntypedDoubleComparison {
    func doubleValueForComparison() throws -> Double
    var isFloatingPoint : Bool { get }
}

public enum AJRComparisonResult : Int, Comparable {
    
    case orderedAscending
    case orderedSame
    case orderedDescending
    case incomparable
    
    public static func < (lhs: AJRComparisonResult, rhs: AJRComparisonResult) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func from(_ result: ComparisonResult) -> AJRComparisonResult {
        switch result {
        case .orderedAscending:
            return .orderedAscending
        case .orderedDescending:
            return .orderedDescending
        case .orderedSame:
            return .orderedSame
        }
    }
    
    /**
     Flips the result so `orderedAscending` becomes `orderedDescending` and `orderedDescending` becomes `orderedAscending`. This has no effect if the receiver is `orderedSame` or `incomparable`.
     */
    public static prefix func ! (rhs: AJRComparisonResult) -> AJRComparisonResult {
        if rhs == .orderedAscending {
            return .orderedDescending
        } else if rhs == .orderedDescending {
            return .orderedAscending
        }
        return rhs
    }
    
}

public protocol AJRComparable {
    
    func compare(to other: Any) -> AJRComparisonResult
    
}

public func AJRAnyEquals(_ lhsIn: Any?, _ rhsIn: Any?) -> Bool {
    let lhs : Any? = lhsIn is NSNull ? nil : lhsIn
    let rhs : Any? = rhsIn is NSNull ? nil : rhsIn
    
    if lhs == nil && rhs == nil {
        return true
    } else if (lhs == nil && rhs != nil) || (lhs != nil && rhs == nil) {
        return false
    } else if let lhs = lhs as? AJREquatable, let rhs = rhs {
        return lhs.isEqual(rhs)
    } else if let lhs = lhs as? NSObject {
        // Apparently AnyObject's may now be object's other than those subclassed from NSObject. Probably something I missed in a release note. Anyways, check against NSObject now.
        return lhs.isEqual(rhs)
    }
    
    AJRLog.warning("Trying to compare: \(type(of:lhs!)). Consider making this class conform to AJREquatable for better results.")
    
    #if os(Linux)
    // This cast always succedes on Mac OS X, but Linux seem fussier, so we have to do this way. That being said, I don't just want to use the Linux method, because it generates a warning on Mac OS.
    if let lhs = lhs as? AnyObject, let rhs = rhs as? AnyObject {
        return lhs === rhs
    }
    return false
    #else
    return (lhs! as AnyObject) === (rhs! as AnyObject)
    #endif
}

public func AJRAnyEquals<T: Equatable>(_ lhs: T?, _ rhs: T?) -> Bool {
    var result : Bool = false
    // NOTE: Apparently nil is now equalable...
    if (lhs == nil && rhs == nil) {
        result = true
    } else if (lhs == nil && rhs != nil) || (lhs != nil && rhs == nil) {
        result = false
    } else if let lhs = lhs as? AJREquatable ,let rhs = rhs {
        result = lhs.isEqual(rhs)
    } else if let lhs = lhs, let rhs = rhs {
        result = lhs == rhs
    }
    return result
}

/**
 Compares two objects (or structs), if they're comparable. They're considered comparable if `lhs` implements the `AJRComparable` protocol. This is a protocol that passes in an `Any` and the receiver must determine if it feels it can compare itself to that object. If `lhs` doesn't adopt `AJRComparable` then  this method may return `incomparable`. Note that if `lhs` is `nil` and `rhs` is not `nil`, then this returns `orderedAscending`. If `lhs` is not `nil` and `rhs` is `nil`, then this returns `orderedDescending`. Finally, if both `lhs` and `rhs` are `nil`, this return `orderedSame`.
 */
public func AJRAnyCompare(_ lhsIn: Any?, _ rhsIn: Any?) -> AJRComparisonResult {
    let lhs : Any? = lhsIn is NSNull ? nil : lhsIn
    let rhs : Any? = rhsIn is NSNull ? nil : rhsIn

    if lhs == nil && rhs == nil {
        return .orderedSame
    } else if lhs == nil && rhs != nil {
        return .orderedAscending
    } else if lhs != nil && rhs == nil {
        return .orderedDescending
    } else if let lhs = lhs as? AJRComparable, let rhs = rhs {
        return lhs.compare(to: rhs)
    }
    AJRLog.warning("Tried to compare: \(type(of:lhs!)). Consider making this class conform to AJRComparable for better results.")
    return .incomparable
}

/**
 Works much like the more generic version, but requires both passed in objects to implement Comparable. This allows for slightly more reliable comparisons when the compiler has additonal information available about the types being passed in.
 */
public func AJRAnyCompare<T: Comparable>(_ lhsIn: T?, _ rhsIn: T?) -> AJRComparisonResult {
    let lhs : T? = lhsIn is NSNull ? nil : lhsIn
    let rhs : T? = rhsIn is NSNull ? nil : rhsIn

    if lhs == nil && rhs == nil {
        return .orderedSame
    } else if lhs == nil && rhs != nil {
        return .orderedAscending
    } else if lhs != nil && rhs == nil {
        return .orderedDescending
    }
    
    if lhs! == rhs! {
        return .orderedSame
    }
    if lhs! < rhs! {
        return .orderedAscending
    }
    return .orderedDescending
}

public func AJRCompare<T>(_ left: T?, _ right: T?, _ comparator: (_ left: T, _ right: T) -> ComparisonResult) -> ComparisonResult {
    if left == nil && right == nil {
        return .orderedSame
    } else if left == nil && right != nil {
        return .orderedAscending
    } else if left != nil && right == nil {
        return .orderedDescending
    }
    return comparator(left!, right!)
}

internal func signedIntegerIsEqual(_ left: Any?, _ other: Any?) -> Bool {
    var result = false
    if let myself = left as? AJRValueForUntypedComparison, let other = other as? AJRValueForUntypedComparison {
        do {
            let left = try myself.signedValueForComparison()
            let right = try other.signedValueForComparison()
            result = left == right
        } catch {
            // We don't really care what the error was, just that an error occurred.
        }
    }
    return result
}

extension SignedInteger {
    
    public func signedValueForComparison() throws -> Int64 {
        return Int64(self)
    }
    
    public func unsignedValueForComparison() throws -> UInt64 {
        if self < 0 {
            throw AJRNumericError.cannotRepresentValue
        }
        return UInt64(self)
    }

    public func doubleValueForComparison() throws -> Double {
        return Double(self)
    }

    public var isFloatingPoint : Bool { return false }
    
    public func isEqual(_ other: Any?) -> Bool {
        return signedIntegerIsEqual(self, other)
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable

        if let myself = self as? AJRValueForUntypedComparison, let other = other as? AJRValueForUntypedComparison {
            do {
                if (myself.isFloatingPoint || other.isFloatingPoint),
                    let left = try (myself as? AJRValueForUntypedDoubleComparison)?.doubleValueForComparison(),
                    let right = try (other as? AJRValueForUntypedDoubleComparison)?.doubleValueForComparison() {
                    if left == right {
                        result = .orderedSame
                    } else {
                        result = left < right ? .orderedAscending : .orderedDescending
                    }
                } else {
                    let signedLeft = try myself.signedValueForComparison()
                    let signedRight = try? other.signedValueForComparison()
                    // Let's avoid calling unsignedValueForEquals if we successfully converted the right hand value into a signed integer.
                    let unsignedRight = signedRight == nil ? try other.unsignedValueForComparison() : nil
                    if let signedRight = signedRight {
                        if signedLeft == signedRight {
                            result = .orderedSame
                        } else {
                            result = signedLeft < signedRight ? .orderedAscending : .orderedDescending
                        }
                    } else if unsignedRight != nil {
                        // You might think we need to do somethign more advanced here, but in reality, most of the comparisons are handled by the above. We only enter this code when the right hand value cannot be represented by a signed integer. When that happens, since signedLeft is signed, it'll always be less than unsignedRight.
                        result = .orderedAscending
                    }
                }
            } catch {
                // We don't really care what the error was, just that an error occurred.
            }
        }
        
        return result
    }
    
}

internal func unsignedIntegerIsEqual(_ left: Any?, _ other: Any?) -> Bool {
    var result = false
    if let myself = left as? AJRValueForUntypedComparison, let other = other as? AJRValueForUntypedComparison {
        do {
            let left = try myself.unsignedValueForComparison()
            let right = try other.unsignedValueForComparison()
            result = left == right
        } catch {
            // We don't really care what the error was, just that an error occurred.
        }
    }
    return result
}

extension UnsignedInteger {
    
    public func signedValueForComparison() throws -> Int64 {
        if self > Int64.max {
            throw AJRNumericError.cannotRepresentValue
        }
        return Int64(self)
    }
    
    public func unsignedValueForComparison() throws -> UInt64 {
        return UInt64(self)
    }
    
    public func doubleValueForComparison() throws -> Double {
        return Double(self)
    }
    
    public var isFloatingPoint : Bool { return false }
    
    public func isEqual(_ other: Any?) -> Bool {
        return unsignedIntegerIsEqual(self, other)
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable

        if let myself = self as? AJRValueForUntypedComparison, let other = other as? AJRValueForUntypedComparison {
            do {
                if (myself.isFloatingPoint || other.isFloatingPoint),
                    let left = try (myself as? AJRValueForUntypedDoubleComparison)?.doubleValueForComparison(),
                    let right = try (other as? AJRValueForUntypedDoubleComparison)?.doubleValueForComparison() {
                    if left == right {
                        result = .orderedSame
                    } else {
                        result = left < right ? .orderedAscending : .orderedDescending
                    }
                } else {
                    let unsignedLeft = try myself.unsignedValueForComparison()
                    let signedRight = try? other.signedValueForComparison()
                    let unsignedRight = signedRight == nil ? try other.unsignedValueForComparison() : nil
                    if let signedRight = signedRight {
                        if signedRight < 0 {
                            // Because the left can never be negative, so it'll always be greater than right.
                            result = .orderedDescending
                        } else if unsignedLeft == signedRight {
                            result = .orderedSame
                        } else {
                            result = unsignedLeft < signedRight ? .orderedAscending : .orderedDescending
                        }
                    } else if let unsignedRight = unsignedRight {
                        if unsignedLeft == unsignedRight {
                            result = .orderedSame
                        } else {
                            result = unsignedLeft < unsignedRight ? .orderedAscending : .orderedDescending
                        }
                    }
                }
            } catch {
                // We don't really care what the error was, just that an error occurred.
            }
        }
        
        return result
    }
    
}

extension Int : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return signedIntegerIsEqual(self, other)
    }
}

extension UInt : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return unsignedIntegerIsEqual(self, other)
    }
}

extension Int8 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return signedIntegerIsEqual(self, other)
    }
}

extension UInt8 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return unsignedIntegerIsEqual(self, other)
    }
}

extension Int16 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return signedIntegerIsEqual(self, other)
    }
}

extension UInt16 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return unsignedIntegerIsEqual(self, other)
    }
}

extension Int32 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return signedIntegerIsEqual(self, other)
    }
}

extension UInt32 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return unsignedIntegerIsEqual(self, other)
    }
}

extension Int64 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return signedIntegerIsEqual(self, other)
    }
}

extension UInt64 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {
    public func isEqual(_ other: Any?) -> Bool {
        return unsignedIntegerIsEqual(self, other)
    }
}

extension Float : AJRValueForUntypedDoubleComparison, AJRValueForUntypedComparison, AJREquatable, AJRComparable {

    public func signedValueForComparison() throws -> Int64 {
        if floor(self) == self {
            return Int64(self)
        }
        throw AJRNumericError.cannotRepresentValue
    }
    
    public func unsignedValueForComparison() throws -> UInt64 {
        if self >= 0.0 && floor(self) == self {
            return UInt64(self)
        }
        throw AJRNumericError.cannotRepresentValue
    }
    
    public func doubleValueForComparison() throws -> Double {
        return Double(self)
    }
    
    public var isFloatingPoint : Bool { return true }
    
    public func isEqual(_ other: Any?) -> Bool {
        var result = false
        if let other = other as? AJRValueForUntypedDoubleComparison {
            do {
                let left = try self.doubleValueForComparison()
                let right = try other.doubleValueForComparison()
                result = left == right
            } catch {
                // We don't care, we failed to convert other to double, so fail.
            }
        }
        return result
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable
        if let other = other as? AJRValueForUntypedDoubleComparison {
            do {
                let left = try self.doubleValueForComparison()
                let right = try other.doubleValueForComparison()
                if left == right {
                    result = .orderedSame
                } else {
                    result = left < right ? .orderedAscending : .orderedDescending
                }
            } catch {
            }
        }
        return result
    }
    
}

extension NSNumber : AJRValueForUntypedDoubleComparison, AJRValueForUntypedComparison, AJREquatable, AJRComparable {

    public func signedValueForComparison() throws -> Int64 {
        if self.isUnsignedInteger {
            let value = uint64Value
            // Only return a value if we won't overflow
            if value <= Int64.max {
                return Int64(value)
            }
        } else if self.isInteger {
            return int64Value
        } else if self.isFloatingPoint {
            let doubleValue = self.doubleValue
            if floor(doubleValue) == doubleValue {
                return Int64(doubleValue)
            }
        }
        throw AJRNumericError.cannotRepresentValue
    }

    public func unsignedValueForComparison() throws -> UInt64 {
        if isUnsignedInteger {
            return uint64Value
        } else if isInteger && !isNegative {
            return uint64Value
        } else if isFloatingPoint {
            if !isNegative {
                let doubleValue = self.doubleValue
                if floor(doubleValue) == doubleValue {
                    // We're an integer value, so...
                    return uint64Value
                }
            }
        }
        throw AJRNumericError.cannotRepresentValue
    }

    public func doubleValueForComparison() throws -> Double {
        return doubleValue
    }

    public var isFloatingPoint : Bool { return true }

// I'm pretty sure we don't want this, but just in case...
//    public func isEqual(_ other: Any?) -> Bool {
//        var result = false
//        if let other = other as? AJRValueForUntypedDoubleComparison {
//            do {
//                let left = try self.doubleValueForComparison()
//                let right = try other.doubleValueForComparison()
//                result = left == right
//            } catch {
//                // We don't care, we failed to convert other to double, so fail.
//            }
//        }
//        return result
//    }

    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable
        if let other = other as? AJRValueForUntypedDoubleComparison {
            do {
                let left = try self.doubleValueForComparison()
                let right = try other.doubleValueForComparison()
                if left == right {
                    result = .orderedSame
                } else {
                    result = left < right ? .orderedAscending : .orderedDescending
                }
            } catch {
            }
        }
        return result
    }

}

extension Double : AJRValueForUntypedDoubleComparison, AJRValueForUntypedComparison, AJREquatable, AJRComparable {
    
    public func signedValueForComparison() throws -> Int64 {
        if floor(self) == self {
            return Int64(self)
        }
        throw AJRNumericError.cannotRepresentValue
    }
    
    public func unsignedValueForComparison() throws -> UInt64 {
        if floor(self) == self {
            return UInt64(self)
        }
        throw AJRNumericError.cannotRepresentValue
    }
    
    public func doubleValueForComparison() throws -> Double {
        return Double(self)
    }
    
    public var isInteger : Bool {
        return floor(self) == self
    }
    
    public var isFloatingPoint : Bool { return true }
    
    public func isEqual(_ other: Any?) -> Bool {
        var result = false
        if let other = other as? AJRValueForUntypedDoubleComparison {
            do {
                let left = try self.doubleValueForComparison()
                let right = try other.doubleValueForComparison()
                result = left == right
            } catch {
                // We don't care, we failed to convert other to double, so fail.
            }
        }
        return result
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable
        if let other = other as? AJRValueForUntypedDoubleComparison {
            do {
                let left = try self.doubleValueForComparison()
                let right = try other.doubleValueForComparison()
                if left == right {
                    result = .orderedSame
                } else {
                    result = left < right ? .orderedAscending : .orderedDescending
                }
            } catch {
            }
        }
        return result
    }
    
}

extension StringProtocol {

    public func isEqual(_ other: Any?) -> Bool {
        var result = false
        if let other = other as? (any StringProtocol) {
            result = self == other
        }
        return result
    }

}

extension Substring : AJREquatable {

    public func isEqual(_ other: Any?) -> Bool {
        var result = false
        if let other = other as? (any StringProtocol) {
            result = self == other
        }
        return result
    }

}

extension String : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {

    public func signedValueForComparison() throws -> Int64 {
        var result : Int64? = nil
        if let number = (self as NSString).numberValue {
            if number.isNegative || number.uint64Value <= Int64.max {
                result = number.int64Value
            }
        }
        if let result = result {
            return result
        }
        throw AJRNumericError.cannotRepresentValue
    }
    
    public func isEqual(_ other: Any?) -> Bool {
        var result = false
        if let other = other as? (any StringProtocol) {
            result = self == other
        }
        return result
    }

    public func unsignedValueForComparison() throws -> UInt64 {
        var result : UInt64? = nil
        if let number = (self as NSString).numberValue {
            if number.isPositive {
                result = number.uint64Value
            }
        }
        if let result = result {
            return result
        }
        throw AJRNumericError.cannotRepresentValue
    }

    public func doubleValueForComparison() throws -> Double {
        if let number = (self as NSString).numberValue {
            return number.doubleValue
        }
        throw AJRNumericError.cannotRepresentValue
    }
    

    public var isFloatingPoint: Bool {
        // NOTE: Just because this method says yes, it doesn't mean we have a floating point. This is say more that we don't have an integer.
        return self.contains(".") || self.contains("e")
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable
        if let other = other as? String {
            if self == other {
                result = .orderedSame
            } else {
                result = self < other ? .orderedAscending : .orderedDescending
            }
        } else if let other = other as? AJRValueForUntypedComparison {
            do {
                if (self.isFloatingPoint || other.isFloatingPoint),
                    let right = try (other as? AJRValueForUntypedDoubleComparison)?.doubleValueForComparison() {
                    let left = try self.doubleValueForComparison()
                    if left == right {
                        result = .orderedSame
                    } else {
                        result = left < right ? .orderedAscending : .orderedDescending
                    }
                } else {
                    let signedLeft = try? self.signedValueForComparison()
                    let unsignedLeft = signedLeft == nil ? try self.unsignedValueForComparison() : nil
                    let signedRight = try? other.signedValueForComparison()
                    let unsignedRight = signedRight == nil ? try other.unsignedValueForComparison() : nil
                    if let signedLeft = signedLeft, let signedRight = signedRight {
                        if signedLeft == signedRight {
                            result = .orderedSame
                        } else {
                            result = signedLeft < signedRight ? .orderedAscending : .orderedDescending
                        }
                    } else if signedLeft != nil, unsignedRight != nil {
                        // NOTE: In this case, we created a signed integer on the left, but an unsigned integer on the right, and we only create an unsigned integer on the right if we failed to create a signed integer on the right. As such, right will always be > left.
                        result = .orderedAscending
                    } else if unsignedLeft != nil, signedRight != nil {
                        // NOTE: This is the flip of the above, and in this case, left, which is unsigned, will always be greater than Int64.max.
                        result = .orderedDescending
                    } else if let unsignedLeft = unsignedLeft, let unsignedRight = unsignedRight {
                        if unsignedLeft == unsignedRight {
                            result = .orderedSame
                        } else {
                            result = unsignedLeft < unsignedRight ? .orderedAscending : .orderedDescending
                        }
                    }
                }
            } catch {
                // We don't really care what the error was, just that an error occurred.
            }
        }
        return result
    }
    
}

extension Bool : AJREquatable, AJRComparable {
    
    public func isEqual(_ other: Any?) -> Bool {
        if let other = other as? Bool {
            // The brain dead case.
            return self == other
        }
        // See if we can compare against a numeric value being != 0
        if let other = other as? AJRValueForUntypedComparison {
            // NOTE: We don't try and convert to a unsigned integer value, because if the below fails, then it's because we'd overflow to a unsigned integer value, and if we do that, then we're definitely not equal to 0.
            if let other = try? other.signedValueForComparison() {
                return self == (other != 0)
            }
        }
        return false
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var otherValue : Bool? = nil
        
        if let other = other as? Bool {
            otherValue = other
        } else if let other = other as? AJRValueForUntypedComparison {
            // NOTE: We don't try and convert to a unsigned integer value, because if the below fails, then it's because we'd overflow to a unsigned integer value, and if we do that, then we're definitely not equal to 0.
            if let other = try? other.signedValueForComparison() {
                otherValue = other != 0
            }
        }
        
        var result = AJRComparisonResult.incomparable
        if let otherValue = otherValue {
            if self == otherValue {
                result = .orderedSame
            } else if self && !otherValue {
                result = .orderedAscending
            } else {
                result = .orderedDescending
            }
        }
        
        return result
    }
    
}

extension Date : AJREquatable, AJRComparable {
    
    public func isEqual(_ other: Any?) -> Bool {
        if let other = other as? Date {
            return self == other
        }
        return false
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var result = AJRComparisonResult.incomparable
        if let other = other as? Date {
            if self == other {
                result = .orderedSame
            } else {
                result = self < other ? .orderedAscending : .orderedDescending
            }
        }
        return result
    }
    
}

extension Data : AJREquatable, AJRComparable {
    
    public func isEqual(_ other: Any?) -> Bool {
        if let other = other as? Data {
            return self == other
        }
        return false
    }
    
    public func compare(to other: Any) -> AJRComparisonResult {
        var finalResult = AJRComparisonResult.incomparable
        
        if let other = other as? Data {
            self.withUnsafeBytes { (lhs) -> Void in
                other.withUnsafeBytes { (rhs) -> Void in
                    if self.count == other.count {
                        let result = memcmp(lhs.baseAddress!, rhs.baseAddress!, self.count)
                        if result == 0 {
                            finalResult = .orderedSame
                        } else if result < 0 {
                            finalResult = .orderedAscending
                        } else if result > 0 {
                            finalResult = .orderedDescending
                        }
                    } else {
                        let byteCount : Int = Swift.min(self.count, other.count)
                        let result = memcmp(lhs.baseAddress!, rhs.baseAddress!, byteCount)
                        if result == 0 {
                            finalResult = lhs.count < rhs.count ? .orderedAscending : .orderedDescending
                        } else if result < 0 {
                            finalResult = .orderedAscending
                        } else {
                            finalResult = .orderedDescending
                        }
                    }
                }
            }
        }
        
        return finalResult
    }
    
}
