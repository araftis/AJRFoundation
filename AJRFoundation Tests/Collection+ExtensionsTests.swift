/*
Collection+ExtensionsTests.swift
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

import XCTest

import AJRFoundation

class Collection_ExtensionsTests: XCTestCase {

    func testJoining() {
        XCTAssert([1].componentsJoinedByString(separator: ", ", twoValueSeparator: " and ", finalSeparator: ", and ") == "1")
        XCTAssert([1, 2].componentsJoinedByString(separator: ", ", twoValueSeparator: " and ", finalSeparator: ", and ") == "1 and 2")
        XCTAssert([1, 2, 3].componentsJoinedByString(separator: ", ", twoValueSeparator: " and ", finalSeparator: ", and ") == "1, 2, and 3")
    }
    
    func testJSON() {
        var string = [1].jsonString
        XCTAssert(string == "[\n  1\n]")
        string = ["one":1].jsonString
        XCTAssert(string == "{\n  \"one\" : 1\n}")
        string = ["one":Collection_ExtensionsTests()].jsonString
        XCTAssert(string == nil)
    }

    func testUnion() {
        let array1 = ["a", "b", "c"]
        let array2 = ["a", "b", "d"]

        var result = array1.union(array2)
        print("array result: \(result)")
        XCTAssert(AJRAnyEquals(result, ["a", "b", "c", "d"]))

        let string1 = "abc"
        let string2 = "abd"

        result = string1.union(string2)
        print("string result: \(result)")
        XCTAssert(AJRAnyEquals(result, [Character("a"), Character("b"), Character("c"), Character("d")]))
    }

}
