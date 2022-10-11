/*
AJRFunctionsTests.swift
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

class AJRFunctionsTestsSwift: XCTestCase {

    func testClamp() {
        XCTAssert(AJRClamp(50, min: 0, max: 100) == 50)
        XCTAssert(AJRClamp(-50, min: 0, max: 100) == 0)
        XCTAssert(AJRClamp(150, min: 0, max: 100) == 100)
    }
    
    func testFileNameMatching() {
        XCTAssert(AJRFileNameMatch(pattern: "*.*", in: "test.txt", options: []))
    }
    
    func testForceRetains() {
        autoreleasepool {
            // NOTE: This code is a little dicey, because we're testing code that's a little iffy. It's possible this could break in the future. In fact, it's likely, if you notice that the numbers in the asserts are somewhat contrived based on observing what retain/release calls the compiler is putting on the object automatically.
            let object = NSObject()
            let baseRetainCount = AJRGetRetainCount(object)
            
            XCTAssert(baseRetainCount > 0)
            
            AJRForceRetain(object)
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 2)
            
            AJRForceRetain(object)
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 3)
            
            AJRForceRelease(object)
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 2)
            
            autoreleasepool {
                AJRForceAutorelease(object)
            }
            XCTAssert(AJRGetRetainCount(object) == baseRetainCount + 1)
        }
    }

}