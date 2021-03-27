
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
    
    func isEqual(to other: Any) -> Bool
    
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
    } else if type(of: lhs) == type(of: rhs) {
        if let lhs = lhs as? AJREquatable, let rhs = rhs {
            return lhs.isEqual(to: rhs)
        }
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
    // NOTE: nil is never equatable, so lhs and rhs will never both be nil. When that happens, the Any parameter version of AJREquals is called.
    if (lhs == nil && rhs != nil) || (lhs != nil && rhs == nil) {
        result = false
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
    
    public func isEqual(to other: Any) -> Bool {
        var result = false
        if let myself = self as? AJRValueForUntypedComparison, let other = other as? AJRValueForUntypedComparison {
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
    
    public func isEqual(to other: Any) -> Bool {
        var result = false
        if let myself = self as? AJRValueForUntypedComparison, let other = other as? AJRValueForUntypedComparison {
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

extension Int : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension UInt : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension Int8 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension UInt8 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension Int16 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension UInt16 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension Int32 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension UInt32 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension Int64 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }
extension UInt64 : AJREquatable, AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison { }

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
    
    public func isEqual(to other: Any) -> Bool {
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
    
    public var isFloatingPoint : Bool { return true }
    
    public func isEqual(to other: Any) -> Bool {
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
    
    public func isEqual(to other: Any) -> Bool {
        var result = false
        if let other = other as? String {
            result = self == other
        }
        return result
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
    
    public func isEqual(to other: Any) -> Bool {
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
    
    public func isEqual(to other: Any) -> Bool {
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
    
    public func isEqual(to other: Any) -> Bool {
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
