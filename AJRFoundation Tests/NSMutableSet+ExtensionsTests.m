//
//  NSMutableSet+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/18/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSMutableSet_ExtensionsTests : XCTestCase

@end

@implementation NSMutableSet_ExtensionsTests

- (void)testAdding {
    NSMutableSet *set = [NSMutableSet set];
    
    [set addObjectIfNotNil:@"one"];
    [set addObjectIfNotNil:nil];
    XCTAssert(set.count == 1);
    XCTAssert([set containsObject:@"one"]);
}

@end
