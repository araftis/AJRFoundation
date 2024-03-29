/*
 ArrayTests.swift
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

@testable import AJRFoundation

class ArrayTests: XCTestCase {

    func testBinarySearch() {
        let input = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        XCTAssert(input.findIndex(of: 1) == 0)
        XCTAssert(input.findIndex(of: 2) == 1)
        XCTAssert(input.findIndex(of: 3) == 2)
        XCTAssert(input.findIndex(of: 4) == 3)
        XCTAssert(input.findIndex(of: 5) == 4)
        XCTAssert(input.findIndex(of: 6) == 5)
        XCTAssert(input.findIndex(of: 7) == 6)
        XCTAssert(input.findIndex(of: 8) == 7)
        XCTAssert(input.findIndex(of: 9) == 8)
        XCTAssert(input.findIndex(of: 10) == 9)
        XCTAssert(input.findIndex(of: 20) == nil)

        // These use the same underlying code as the above, so just make sure the API's working.
        XCTAssert(input.findIndex(of: 3, using: AJRCompare) == 2)
        
        let empty = [Int]()
        XCTAssert(empty.findIndex(of: 1) == nil)
        
        XCTAssert(AJRBinarySearch(object: 1, in: input, lowerIndex: 0, upperIndex: 0) == 0)
        XCTAssert(AJRBinarySearch(object: 20, in: input, lowerIndex: 0, upperIndex: 0) == nil)
    }
    
    func testFindInsertionPoint() {
        let input = [ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
        
        XCTAssert(input.findInsertionPoint(for: 1) == 0)
        XCTAssert(input.findInsertionPoint(for: 3) == 1)
        XCTAssert(input.findInsertionPoint(for: 5) == 2)
        XCTAssert(input.findInsertionPoint(for: 7) == 3)
        XCTAssert(input.findInsertionPoint(for: 9) == 4)
        XCTAssert(input.findInsertionPoint(for: 11) == 5)
        XCTAssert(input.findInsertionPoint(for: 13) == 6)
        XCTAssert(input.findInsertionPoint(for: 15) == 7)
        XCTAssert(input.findInsertionPoint(for: 17) == 8)
        XCTAssert(input.findInsertionPoint(for: 19) == 9)
        XCTAssert(input.findInsertionPoint(for: 21) == 10)
        
        // These use the same underlying code as the above, so just make sure the API's working.
        XCTAssert(input.findInsertionPoint(for: 9, using: AJRCompare) == 4)
    }
    
    func testUniqueObjects() {
        let input = [ 1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
        let unique = input.uniqueObjects
        
        XCTAssert(unique.count == 5)
        XCTAssert(unique.firstIndex(of: 1) != nil)
        XCTAssert(unique.firstIndex(of: 2) != nil)
        XCTAssert(unique.firstIndex(of: 3) != nil)
        XCTAssert(unique.firstIndex(of: 4) != nil)
        XCTAssert(unique.firstIndex(of: 5) != nil)
    }
    
    func testRemove() {
        var input = [ 1, 2, 3, 4, 5]
        
        input.remove(element: 3)
        
        XCTAssert(input == [ 1, 2, 4, 5])
    }
    
    func testEnumerate() {
        let input = [1,2,3,4,5]
        var output = [Int]()
        
        input.enumerate { (value) in
            output.append(value)
        }
        
        XCTAssert(input == output)
    }
    
    func testInsertion() {
        var input = [ 1, 3, 5, 7, 9 ]
        
        input.insert(sorted: 2)
        input.insert(sorted: 4)
        input.insert(sorted: 6)
        input.insert(sorted: 8, using: AJRCompare)
        input.insert(sorted: 10, using: AJRCompare)
        
        XCTAssert(input == [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
    func testFind() {
        let input = [ 1, 3, 5, 7, 9 ]
        
        XCTAssert(input.any(passing: { (value) -> Bool in
            return value == 3
        }) != nil)
        
        XCTAssert(input.any(passing: { (value) -> Bool in
            return value == 4
        }) == nil)
    }
    
    func testAnyObjectIndex() {
        let one = NSObject()
        let two = NSObject()
        let three = NSObject()
        let four = NSObject()
        let input = [ one, two, three ]
        
        XCTAssert(input.index(ofObjectIdenticalTo: one) == 0)
        XCTAssert(input.index(ofObjectIdenticalTo: two) == 1)
        XCTAssert(input.index(ofObjectIdenticalTo: three) == 2)
        XCTAssert(input.index(ofObjectIdenticalTo: four) == nil)
    }
    
}
