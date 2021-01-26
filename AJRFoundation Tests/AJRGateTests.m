//
//  AJRGateTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 12/6/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRGateTests : XCTestCase

@end

@implementation AJRGateTests

- (void)testObjCOnlyMethods {
    // These methods aren't exposed to Swift
    
    XCTAssert([AJRGate gate] != nil);
}

@end
