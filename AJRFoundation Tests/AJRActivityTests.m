//
//  AJRActivityTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 12/6/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRActivityTests : XCTestCase

@end

@implementation AJRActivityTests

- (void)testObjCOnlyInterface {
    // We have a couple of methods that will never be called from Swift, so test those here.
    
    AJRActivity *activity = [AJRActivity activity];
    XCTAssert(activity != nil);
}

@end
