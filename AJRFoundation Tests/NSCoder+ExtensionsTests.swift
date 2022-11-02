/*
 NSCoder+ExtensionsTests.swift
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

class AJRSimpleCodingTest : NSObject, NSCoding {
    
    let value : Int
    
    override init() {
        self.value = 0
    }
    
    init(value: Int) {
        self.value = value
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(value, forKey: "value")
    }
    
    required init?(coder: NSCoder) {
        self.value = coder.decodeInteger(forKey: "value")
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AJRSimpleCodingTest {
            return value == object.value
        }
        return false
    }
}

class NSCoder_ExtensionsTests: XCTestCase {

    func testSwiftCodingConveniences() {
        let test1 = AJRSimpleCodingTest(value: 10)
        let test2 = AJRSimpleCodingTest(value: 20)
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        
        archiver["object1"] = test1
        archiver.encode(test2, forKey: "object2")
        archiver.finishEncoding()
        
        if let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: archiver.encodedData) {
            unarchiver.requiresSecureCoding = false
            let decoded1 : AJRSimpleCodingTest? = unarchiver["object1"]
            XCTAssert(decoded1 != nil)
            XCTAssert(decoded1 == test1)
            let decoded2 : AJRSimpleCodingTest? = unarchiver.decodeObject(forKey: "object2")
            XCTAssert(decoded2 != nil)
            XCTAssert(decoded2 == test2)
        } else {
            XCTAssert(false, "Failed to create decoder")
        }
    }

}
