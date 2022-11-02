/*
 AJREquatableTests.swift
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

import XCTest

import AJRFoundation

class AJRNonEquatableObject {
    
    public init() {
    }
    
}

class AJRTestComparable : AJRComparable, AJRValueForUntypedComparison {
    
    var value : UInt
    
    init(value: UInt) {
        self.value = value
    }
    
    func compare(to other: Any) -> AJRComparisonResult {
        if let other = other as? AJRTestComparable {
            return AJRAnyCompare(self.value, other.value)
        }
        return .incomparable
    }
    
    func signedValueForComparison() throws -> Int64 {
        if value > Int64.max {
            throw AJRNumericError.cannotRepresentValue
        }
        return Int64(value)
    }
    
    func unsignedValueForComparison() throws -> UInt64 {
        return UInt64(value)
    }
    
    var isFloatingPoint: Bool {
        return false
    }
        
}

class AJRErrorTestComparable : AJRComparable, AJRValueForUntypedComparison, AJRValueForUntypedDoubleComparison {

    func signedValueForComparison() throws -> Int64 {
        throw AJRNumericError.cannotRepresentValue
    }
    
    func unsignedValueForComparison() throws -> UInt64 {
        throw AJRNumericError.cannotRepresentValue
    }
    
    func doubleValueForComparison() throws -> Double {
        throw AJRNumericError.cannotRepresentValue
    }

    var isFloatingPoint: Bool {
        return false
    }
    
    func compare(to other: Any) -> AJRComparisonResult {
        return .orderedSame
    }
    
}

class AJREquatableTests: XCTestCase {

    func testEquatables() {
        XCTAssert(ComparisonResult.orderedAscending < ComparisonResult.orderedSame)
        XCTAssert(ComparisonResult.orderedDescending > ComparisonResult.orderedSame)
        XCTAssert(AJRComparisonResult.orderedAscending < AJRComparisonResult.orderedSame)
        XCTAssert(AJRComparisonResult.orderedDescending > AJRComparisonResult.orderedSame)
        XCTAssert(AJRComparisonResult.from(.orderedAscending) == AJRComparisonResult.orderedAscending)
        XCTAssert(AJRComparisonResult.from(.orderedDescending) == AJRComparisonResult.orderedDescending)
        XCTAssert(AJRComparisonResult.from(.orderedSame) == AJRComparisonResult.orderedSame)
        XCTAssert(!AJRComparisonResult.orderedAscending == AJRComparisonResult.orderedDescending)
        XCTAssert(!AJRComparisonResult.orderedDescending == AJRComparisonResult.orderedAscending)
        XCTAssert(!AJRComparisonResult.orderedSame == AJRComparisonResult.orderedSame)
        
        XCTAssert(AJRAnyEquals(5, 5))
        XCTAssert(AJRAnyEquals(5, 5.0))
        XCTAssert(AJRAnyEquals(5, Float(5.0)))
        XCTAssert(AJRAnyEquals(Float(5.0), 5))
        XCTAssert(!AJRAnyEquals(Float(5.0), AJRErrorTestComparable()))
        XCTAssert(AJRAnyEquals(Double(5.0), 5))
        XCTAssert(!AJRAnyEquals(Double(5.0), AJRErrorTestComparable()))
        XCTAssert(!AJRAnyEquals(5, 5.5))
        XCTAssert(!AJRAnyEquals(5, Float(5.5)))
        XCTAssert(AJRAnyEquals(nil, nil))
        XCTAssert(AJRAnyEquals(nil, nil))
        XCTAssert(!AJRAnyEquals(5, nil))
        XCTAssert(!AJRAnyEquals(nil, 5))

        XCTAssert(AJRAnyEquals(UInt(5), UInt(5)))
        XCTAssert(AJRAnyEquals(UInt(5), 5.0))
        XCTAssert(!AJRAnyEquals(UInt(5), 5.5))
        XCTAssert(!AJRAnyEquals(UInt(5), nil))
        XCTAssert(!AJRAnyEquals(nil, UInt(5)))

        let nonEquatable = AJRNonEquatableObject()
        XCTAssert(!AJRAnyEquals(nonEquatable, nil))
        XCTAssert(!AJRAnyEquals(nil, nonEquatable))
        XCTAssert(!AJRAnyEquals(nonEquatable, NSNull()))
        XCTAssert(!AJRAnyEquals(NSNull(), nonEquatable))
        XCTAssert(AJRAnyEquals(nonEquatable, nonEquatable))
        
        // Strings
        let leftString : Any = "foo";
        let rightString : Any = "bar";
        XCTAssert(AJRAnyEquals(leftString, leftString))
        XCTAssert(!AJRAnyEquals(leftString, rightString))
        
        // Booleans. NOTE: Not doing this via AJRAnyEqual, because some of the optimizations make it difficult to get to all code paths in Bool.isEqual().
        XCTAssert(true.isEqual(to: true))
        XCTAssert(!true.isEqual(to: false))
        XCTAssert(true.isEqual(to: 1))
        XCTAssert(!true.isEqual(to: 0))
        XCTAssert(!true.isEqual(to: Date()))
        let result = true.isEqual(to: "BAD")
        XCTAssert(!result)
        XCTAssert(true.isEqual(to: "true"))
        XCTAssert(true.isEqual(to: "YES"))
        XCTAssert(false.isEqual(to: "false"))
        XCTAssert(false.isEqual(to: "NO"))

        // Some Dates
        let date1 = Date.init(timeIntervalSinceReferenceDate: 0.0)
        let date2 = Date.init(timeIntervalSinceReferenceDate: 1000.0)
        XCTAssert(date1.isEqual(to: date1))
        XCTAssert(!date1.isEqual(to: date2))
        XCTAssert(!date1.isEqual(to: "BAD"))
        
        // Some Data
        var i1 = UInt64(1)
        var i2 = UInt64(10)
        let data1 = Data(bytes: &i1, count: 8)
        let data2 = Data(bytes: &i2, count: 8)
        XCTAssert(data1.isEqual(to: data1))
        XCTAssert(!data1.isEqual(to: data2))
        XCTAssert(!data1.isEqual(to: "BAD"))
    }
    
    func testMisc() -> Void {
        XCTAssert(!(NSNull() < NSNull()))
    }
    
    func testMiscUnsignedInt() -> Void {
        // This method is hard to hit via normal unit testing, because normally it'd never get called, because for performance reasons, we always try to convert to a signed integer first, and if that succeeds, we'll never call the method below, but of course, since we're messaging a signed integer, we'll always succeed. That being said, SignedInteger must implement this method as it's part of one of it's protocols, so in case we ever start calling it in the future, let's make sure it's doing what it should be doing.
        let lhs = UInt64(1)
        var rhs = try? 1.unsignedValueForComparison()
        XCTAssert(lhs == rhs)
        rhs = try? (-1).unsignedValueForComparison()
        XCTAssert(rhs == nil)
        
        rhs = try? Float(1).unsignedValueForComparison()
        XCTAssert(lhs == rhs)
        rhs = try? Float(-1).unsignedValueForComparison()
        XCTAssert(rhs == nil)
    }
    
    func testComparables() {
        XCTAssert(AJRAnyCompare(nil, nil) == .orderedSame);
        XCTAssert(AJRAnyCompare(1, nil) == .orderedDescending);
        XCTAssert(AJRAnyCompare(nil, 1) == .orderedAscending);
        XCTAssert(AJRAnyCompare(1, 1) == .orderedSame);
        XCTAssert(AJRAnyCompare(1, 2) == .orderedAscending);
        XCTAssert(AJRAnyCompare(2, 1) == .orderedDescending);
        XCTAssert(AJRAnyCompare(1, nil) > .orderedSame);
        XCTAssert(AJRAnyCompare(nil, 1) < .orderedSame);

        XCTAssert(AJRAnyCompare(NSNull(), NSNull()) == .orderedSame);
        XCTAssert(AJRAnyCompare(1, NSNull()) == .orderedDescending);
        XCTAssert(AJRAnyCompare(NSNull(), 1) == .orderedAscending);

        XCTAssert(AJRAnyCompare(AJRTestComparable(value: 1), nil) == .orderedDescending);
        XCTAssert(AJRAnyCompare(nil, AJRTestComparable(value: 1)) == .orderedAscending);
        XCTAssert(AJRAnyCompare(AJRTestComparable(value: 1), AJRTestComparable(value: 1)) == .orderedSame);
        XCTAssert(AJRAnyCompare(AJRTestComparable(value: 1), AJRTestComparable(value: 2)) < .orderedSame);
        XCTAssert(AJRAnyCompare(AJRTestComparable(value: 2), AJRTestComparable(value: 1)) > .orderedSame);
        
        XCTAssert(AJRAnyCompare(1, 1.1) < .orderedSame)
        XCTAssert(AJRAnyCompare(1.1, 1) > .orderedSame)
        XCTAssert(AJRAnyCompare(1.0, 1) == .orderedSame)
        
        XCTAssert(AJRAnyCompare(1, AJRNonEquatableObject()) == .incomparable)
        XCTAssert(AJRAnyCompare(AJRNonEquatableObject(), 1) == .incomparable)
        
        var left : Int? = nil
        var right : Int? = nil
        XCTAssert(AJRAnyCompare(left, right) == .orderedSame)
        left = 1; right = nil
        XCTAssert(AJRAnyCompare(left, right) > .orderedSame)
        XCTAssert(AJRAnyCompare(left, NSNull()) > .orderedSame)
        left = nil; right = 1
        XCTAssert(AJRAnyCompare(left, right) < .orderedSame)
        XCTAssert(AJRAnyCompare(NSNull(), right) < .orderedSame)
        left = 1; right = 1
        XCTAssert(AJRAnyCompare(left, right) == .orderedSame)
        
        // This weirdness is simple because the debugger won't let me step into AJRAnyCompare if it's part of the XCTAssert() function call.
        var result = AJRAnyCompare(1, UInt.max); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(UInt.max, 1); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(-1, UInt.max); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(UInt.max, -1); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(1, UInt(1)); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(UInt(1), 1); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(2, UInt(1)); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(UInt(1), 2); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(1, UInt(2)); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(UInt(2), 1); XCTAssert(result == .orderedDescending)

        result = AJRAnyCompare(-1, 1.5); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(UInt(1), 1.5); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(-1, -1.0); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(UInt(1), 1.0); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(-1, -2.0); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(UInt(1), -2.0); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(1.5, -1); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(1.5, UInt(1)); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(UInt(Int.max), AJRTestComparable(value: UInt.max)); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(UInt.max, AJRTestComparable(value: UInt.max)); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(UInt.max, AJRTestComparable(value: UInt.max - 1)); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(UInt(1), AJRErrorTestComparable()); XCTAssert(result == .incomparable)
        result = AJRAnyCompare(UInt(1), Float(Int.max)); XCTAssert(result == .orderedAscending)

        result = AJRAnyCompare(1, AJRErrorTestComparable()); XCTAssert(result == .incomparable)
        
        // Do some Floats and Doubles testing.
        result = AJRAnyCompare(Float(1.0), nil); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(nil, Float(1.0)); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(Float(1.0), Float(1.0)); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(Float(1.0), Double(1.0)); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(Float(1.0), Double(2.0)); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(Float(1.0), Double(0.0)); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(Double(1.0), Float(1.0)); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(Double(1.0), Float(2.0)); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(Double(1.0), Float(0.0)); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(Float(1.0), 1); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(Float(1.0), AJRErrorTestComparable()); XCTAssert(result == .incomparable)
        result = AJRAnyCompare(Double(1.0), AJRErrorTestComparable()); XCTAssert(result == .incomparable)
        
        // Some strings
        let leftString : Any = "foo";
        let rightString : Any = "bar";
        result = AJRAnyCompare(leftString, leftString); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(leftString, rightString); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(rightString, leftString); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(leftString, Date()); XCTAssert(result == .incomparable)
        result = AJRAnyCompare(1, "1"); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(-1, "-1"); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare("1", 1); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare("-1", -1); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare("1", 2); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare("2", 1); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(String(describing: UInt64.max), UInt64.max); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare(String(describing: UInt64.max), UInt64.max - 1); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare(String(describing: UInt64.max - 1), UInt64.max); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare("1", UInt64.max); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare(String(describing: UInt64(Int64.max) + 1), UInt64(0)); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare("1.0", 1.0); XCTAssert(result == .orderedSame)
        result = AJRAnyCompare("1.0", 0.0); XCTAssert(result == .orderedDescending)
        result = AJRAnyCompare("1.0", 2.0); XCTAssert(result == .orderedAscending)
        result = AJRAnyCompare("BAD", 2.0); XCTAssert(result == .incomparable)
        // Because we won't normally hit this error condition...
        XCTAssert((try? "BAD".unsignedValueForComparison()) == nil)
        
        // Some Booleans
        result = true.compare(to: true); XCTAssert(result == .orderedSame)
        result = true.compare(to: false); XCTAssert(result == .orderedAscending)
        result = false.compare(to: true); XCTAssert(result == .orderedDescending)
        result = true.compare(to: "true"); XCTAssert(result == .orderedSame)
        result = true.compare(to: "false"); XCTAssert(result == .orderedAscending)
        result = false.compare(to: "true"); XCTAssert(result == .orderedDescending)
        result = false.compare(to: "BAD"); XCTAssert(result == .incomparable)
        
        // Some Dates
        let date1 = Date.init(timeIntervalSinceReferenceDate: 0.0)
        let date2 = Date.init(timeIntervalSinceReferenceDate: 1000.0)
        result = date1.compare(to: date1); XCTAssert(result == .orderedSame)
        result = date1.compare(to: date2); XCTAssert(result < .orderedSame)
        result = date2.compare(to: date1); XCTAssert(result > .orderedSame)
        result = date2.compare(to: "BAD"); XCTAssert(result == .incomparable)

        // Some Data
        var i1 = UInt64(1).byteSwapped
        var i2 = UInt64(10).byteSwapped
        var i3 = UInt32(10).byteSwapped
        var i4 = UInt32(0).byteSwapped
        let data1 = Data(bytes: &i1, count: 8)
        let data2 = Data(bytes: &i2, count: 8)
        let data3 = Data(bytes: &i3, count: 4)
        let data4 = Data(bytes: &i4, count: 4)
        result = data1.compare(to: data1); XCTAssert(result == .orderedSame)
        result = data1.compare(to: data2); XCTAssert(result == .orderedAscending)
        result = data2.compare(to: data1); XCTAssert(result == .orderedDescending)
        result = data1.compare(to: "BAD"); XCTAssert(result == .incomparable)
        result = data1.compare(to: data3); XCTAssert(result != .orderedSame)
        result = data1.compare(to: data3); XCTAssert(result != .orderedDescending)
        result = data1.compare(to: data4); XCTAssert(result != .orderedAscending)
        result = data4.compare(to: data1); XCTAssert(result != .orderedDescending)
    }
    
    public func testCompareFunction() -> Void {
        let comparator = { (lhs : Any, rhs : Any) -> ComparisonResult in
            let result = AJRAnyCompare(lhs, rhs)
            if result == .orderedAscending {
                return .orderedAscending
            } else if result == .orderedDescending {
                return .orderedDescending
            }
            return .orderedSame
        }
        var result : ComparisonResult = .orderedSame
        result = AJRCompare(nil, nil, comparator); XCTAssert(result == .orderedSame)
        result = AJRCompare(1, nil, comparator); XCTAssert(result == .orderedDescending)
        result = AJRCompare(nil, 1, comparator); XCTAssert(result == .orderedAscending)
        result = AJRCompare(1, 1, comparator); XCTAssert(result == .orderedSame)
    }

}
