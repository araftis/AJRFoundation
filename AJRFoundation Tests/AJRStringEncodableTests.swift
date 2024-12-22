//
//  AJRStringEncodableTests.swift
//  AJRFoundationTests
//
//  Created by AJ Raftis on 4/29/23.
//

import XCTest
import AJRFoundation

final class AJRStringEncodableTests: XCTestCase {

    func testIntegers() throws {
        let value = 123456789
        let string = value.stringEncodableValue
        let valueFromString = Int(stringEncodableValue: string)

        XCTAssert(string == "123456789")
        XCTAssert(valueFromString == value)
        XCTAssert(Int(stringEncodableValue: "") == nil)
        XCTAssert(Int(stringEncodableValue: "123.5") == nil)
        XCTAssert(Int(stringEncodableValue: "123a") == nil)
        XCTAssert(Int(stringEncodableValue: "a") == nil)
        XCTAssert(Int(stringEncodableValue: "-10") == -10)
        XCTAssert((-10).stringEncodableValue == "-10")
        XCTAssert(Int(stringEncodableValue: "-0") == 0)
        XCTAssert(Int(stringEncodableValue: "0") == 0)
        XCTAssert(Int(stringEncodableValue: "1-1") == nil)
    }

    func testFloatingPoint() throws {
        var value = 3.14156e54
        print(value)
        value = Double.nan
        print(value)
        value = Double.infinity
        print(value)
        value = -Double.infinity
        print(value)
    }

}
