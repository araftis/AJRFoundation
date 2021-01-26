//
//  NSAttributedString+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/27/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSAttributedString_ExtensionsTests : XCTestCase

@end

@implementation NSAttributedString_ExtensionsTests

- (void)testWordCount {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"This is a test"];
    XCTAssert([string wordCount] == 4);
}

@end
