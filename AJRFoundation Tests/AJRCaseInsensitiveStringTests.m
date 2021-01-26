//
//  AJRCaseInsensitiveStringTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 11/5/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRCaseInsensitiveStringTests : XCTestCase

@end

@implementation AJRCaseInsensitiveStringTests

- (void)testComparisons {
    NSString *test = [AJRCaseInsensitiveString stringWithString:@"THIS IS A TEST"];
    
    XCTAssert([test isKindOfClass:AJRCaseInsensitiveString.class]);
    XCTAssert([test isEqualToString:@"this is a test"]);
    XCTAssert([test isEqual:@"this is a test"]);
    XCTAssert(test.hash == [AJRCaseInsensitiveString stringWithString:@"tHiS iS a TeSt"].hash);
    XCTAssert(test.length == 14);
    XCTAssert([test characterAtIndex:0] == 'T');
    XCTAssert([test characterAtIndex:1] == 'H');
    XCTAssert([test characterAtIndex:2] == 'I');
    XCTAssert([test characterAtIndex:3] == 'S');
    XCTAssert([test compare:@"this is a test"] == NSOrderedSame);
    XCTAssert([test compare:@"this was a test"] == NSOrderedAscending);
    XCTAssert([test compare:@"this can a test"] == NSOrderedDescending);
    XCTAssert([test hasPrefix:@"this"]);
    XCTAssert([test hasSuffix:@"test"]);
    XCTAssert(![test hasPrefix:@"test"]);
    XCTAssert(![test hasSuffix:@"this"]);
    XCTAssert([test rangeOfString:@"is a"].location == 5);
    XCTAssert([test rangeOfString:@"is a" options:NSBackwardsSearch].location == 5);
    
    NSString *key1 = [AJRCaseInsensitiveString stringWithString:@"ONE"];
    NSString *key2 = [AJRCaseInsensitiveString stringWithString:@"TWO"];
    NSDictionary *dictionary = @{key1: @"uno", key2: @"dos"};
    XCTAssert([dictionary[@"one"] isEqualToString:@"uno"]);
    XCTAssert([dictionary[@"two"] isEqualToString:@"dos"]);
    
    XCTAssert([[key1 description] isEqualToString:@"ONE"]);
    XCTAssert(![[key1 description] isEqualToString:@"one"]);
}

@end
