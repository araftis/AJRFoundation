/*
 XMLElement+ExtensionsTests.swift
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

import XCTest

class XMLElement_ExtensionsTests: XCTestCase {

    func testAttributes() {
        let element = XMLElement(name: "test", stringValue: "Some text");
        let attribute1 = XMLNode.attribute(withName: "a1", stringValue: "test1") as! XMLNode
        let attribute2 = XMLNode.attribute(withName: "a2", stringValue: "test2") as! XMLNode
        let attribute3 = XMLNode.attribute(withName: "a3", stringValue: "test3") as! XMLNode

        element.addAttribute(attribute1)
        XCTAssert(element.description == "<test a1=\"test1\">Some text</test>")
        element.addAttribute(attribute3)
        XCTAssert(element.description == "<test a1=\"test1\" a3=\"test3\">Some text</test>")
        element.replaceAttribute(attribute1, with: attribute2)
        XCTAssert(element.description == "<test a2=\"test2\" a3=\"test3\">Some text</test>")
    }

}
