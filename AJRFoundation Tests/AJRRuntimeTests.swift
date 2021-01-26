//
//  AJRRuntimeTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/21/19.
//

import XCTest

import AJRFoundation

class AJRRuntimeTests: XCTestCase {

    func testClassName() {
        XCTAssert(AJRStringFromClassSansModule(Self.self) == "AJRRuntimeTests")
    }

    func testExceptionCatching() throws {
        var caughtException = false
        do {
            try NSObject.catchException {
                NSObject.ajr_testMethodThatThrowsException()
            }
        } catch {
            caughtException = true
        }
        
        XCTAssert(caughtException, "We expected to catch an exception, but we didn't :-(")
    }
    
}
