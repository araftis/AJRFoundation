/*
NSNumber+ExtensionsTests.m
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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

@interface NSNumber_ExtensionsTests : XCTestCase

@end

#define ALWAYS_NSUINTEGER @((NSUInteger)NSIntegerMax + 1)

@implementation NSNumber_ExtensionsTests

- (void)testComparingToStrings {
    XCTAssert([@(1) isEqualToString:@"1"]);
    XCTAssert([ALWAYS_NSUINTEGER isEqualToString:ALWAYS_NSUINTEGER.description]);
    XCTAssert([@(0) isEqualToString:@"0"]);
    XCTAssert(![@(1) isEqualToString:@"0"]);
    XCTAssert(![@(0) isEqualToString:@"1"]);
    XCTAssert([@(-1) isEqualToString:@"-1"]);
    XCTAssert(![@(-1) isEqualToString:@"1"]);
    XCTAssert([@(1.0) isEqualToString:@"1.0"]);
    XCTAssert([@(-1.0) isEqualToString:@"-1.0"]);
}

- (void)testPositiveAndNegative {
    XCTAssert(@(1).isPositive);
    XCTAssert(!@(-1).isPositive);
    XCTAssert(ALWAYS_NSUINTEGER.isPositive);
    XCTAssert(@(1.0).isPositive);
    XCTAssert(!@(-1.0).isPositive);
}

- (void)testCreation {
    // NOTE: This method calls through to -[NSString numberValue], so we test this more thoroughly via the NSString+ExtensionsTests.m.
    XCTAssert([[NSNumber numberFromString:@"1"] isEqualToNumber:@(1)]);
}

- (void)testRandomNumbers {
    // Just call this and hope for no crash. We can't really "test" it, because this goes through a code path that's only visited if we haven't yet called +[NSNumber seedRandomNumbersWithSeed:]. However, that means the return value will always be random :-/. After this, we'll call +[NSNumber seedRandomNumbersWithSeed:] and make sure we get back consistent values.
    AJRPrintf(@"%@\n", NSNumber.randomNumber);
    
    [NSNumber seedRandomNumbersWithSeed:61671];
    NSNumber *random = NSNumber.randomNumber;
    XCTAssert([random isEqualToNumber:@(244140405)], @"%@ wasn't equal to 244140405", random);
    
    for (NSInteger x = 0; x < 1000; x++) {
        random = [NSNumber randomNumberInRange:(NSRange){10, 10}];
        XCTAssert(random.integerValue >= 10 && random.integerValue < 20);
    }
}

@end
