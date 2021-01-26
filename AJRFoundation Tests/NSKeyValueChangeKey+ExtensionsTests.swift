//
//  NSKeyValueChangeKeyTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/21/19.
//

import XCTest

class NSKeyValueChangeKeyTests: XCTestCase {

    func testDescriptions() {
        XCTAssert("\(NSKeyValueChangeKey.indexesKey)" == "indexes")
    }

}
