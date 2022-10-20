/*
AJRStringTests.swift
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

@testable import AJRFoundation

class AJRStringTests: XCTestCase {

    func testOffsetOverArticle() {
        let cases : [(string: String, offset: Int)] = [
            ("The test", 4),
            ("tHe test", 4),
            ("thE test", 4),
            ("THe test", 4),
            ("tHE test", 4),
            ("ThE test", 4),
            ("THE test", 4),
            ("thetest", 0),
            ("the", 0),
            ("an elephant", 3),
            ("An elephant", 3),
            ("aN elephant", 3),
            ("AN elephant", 3),
            ("anelephant", 0),
            ("an", 0),
            ("a test", 2),
            ("A test", 2),
            ("atest", 0),
            ("a", 0),
            ("toe test", 0),
            ("that test", 0),
            ("biscuit", 0),
            ("", 0),
        ]
        
        for (input, offset) in cases {
            XCTAssert(input.offsetOverLeadingArticle == input.index(input.startIndex, offsetBy: offset), "Failed to get an offset of \(offset) on input \(input)")
        }
    }
    
    func testComparisons() {
        XCTAssert(ComparisonResult.orderedAscending <= ComparisonResult.orderedSame)
        XCTAssert(ComparisonResult.orderedAscending <= ComparisonResult.orderedDescending)
        XCTAssert(ComparisonResult.orderedDescending >= ComparisonResult.orderedSame)
        XCTAssert(ComparisonResult.orderedDescending >= ComparisonResult.orderedAscending)
    }
    
    func testCaseInsensitivePrefix() {
        let test = "This is a string protocol object"
        let testStringProtocol = test[test.startIndex ..< test.endIndex]
        
        XCTAssert(test.hasCaseInsensitivePrefix("this"))
        XCTAssert(test.hasCaseInsensitivePrefix("tHis"))
        XCTAssert(test.hasCaseInsensitivePrefix("tHiS"))
        XCTAssert(test.hasCaseInsensitivePrefix("This"))
        XCTAssert(!test.hasCaseInsensitivePrefix("that"))
        
        XCTAssert(testStringProtocol.hasCaseInsensitivePrefix("this"))
        XCTAssert(testStringProtocol.hasCaseInsensitivePrefix("tHis"))
        XCTAssert(testStringProtocol.hasCaseInsensitivePrefix("tHiS"))
        XCTAssert(testStringProtocol.hasCaseInsensitivePrefix("This"))
        XCTAssert(!testStringProtocol.hasCaseInsensitivePrefix("that"))
        
        let test2 = "This"
        let testStringProtocol2 = test2[test2.startIndex ..< test2.endIndex]
        XCTAssert(!test2.hasCaseInsensitivePrefix("longer string"))
        XCTAssert(!testStringProtocol2.hasCaseInsensitivePrefix("longer string"))
    }
    
    func testEscapeHTML() {
        let string = "<HTML>Jack & Jill</HTML>"
        XCTAssert(string.escapingHTML == "&lt;HTML&gt;Jack &amp; Jill&lt;/HTML&gt;")
    }
    
    func testLocalizedCompare() {
        let string1 = "Office"
        let string2 = "The Office"
        let string3 = "The Anchor"
        let string4 = "Prudence"

        XCTAssert(string1.localizedStandardCompareIgnoringLeadingArticle(string2) == .orderedSame)
        XCTAssert(string1.localizedStandardCompareIgnoringLeadingArticle(string3) == .orderedDescending)
        XCTAssert(string1.localizedStandardCompareIgnoringLeadingArticle(string4) == .orderedAscending)
    }

}
