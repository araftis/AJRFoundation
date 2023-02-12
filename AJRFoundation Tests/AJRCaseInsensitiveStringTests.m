/*
 AJRCaseInsensitiveStringTests.m
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
