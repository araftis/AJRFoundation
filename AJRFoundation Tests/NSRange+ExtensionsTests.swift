//
//  NSRange+ExtensionsTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/23/19.
//

import XCTest

class NSRange_ExtensionsTests: XCTestCase {

    func testNotFound() {
        let notFound = NSRange.notFound
        XCTAssert(notFound.isNotFound)
    }

}
