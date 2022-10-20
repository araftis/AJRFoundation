/*
AJRConversionsTests.m
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

@interface AJRConversionsTest : XCTestCase

@end

@implementation AJRConversionsTest

- (void)testArrays {
    NSArray *result;
    NSArray *testArray = @[@"1", @"2", @"3"];
    
    result = AJRArrayFromValue(testArray);
    XCTAssert([result isEqualToArray:testArray]);
    
    result = AJRArrayFromValue(@"random");
    XCTAssert([result isEqualToArray:@[@"random"]]);
    
    result = AJRArrayFromValue(@"(\"1\", \"2\", \"3\")");
    XCTAssert([result isEqualToArray:testArray]);
    
    result = AJRArrayFromValue(nil);
    XCTAssert([result isEqualToArray:@[]]);
}

- (void)testDictionaries {
    NSDictionary *result;
    NSDictionary *testDictionary = @{ @"one":@"1", @"two":@"2", @"three":@"3" };
    
    result = AJRDictionaryFromValue(testDictionary);
    XCTAssert([result isEqualToDictionary:testDictionary]);
    
    result = AJRDictionaryFromValue(@"{ \"one\" = \"1\"; \"two\" = \"2\"; \"three\" = \"3\";}");
    XCTAssert([result isEqualToDictionary:testDictionary]);
    
    result = AJRDictionaryFromValue(nil);
    XCTAssert([result isEqualToDictionary:@{}]);
    
    BOOL caughtException = NO;
    @try {
        result = AJRDictionaryFromValue(@"random");
    } @catch (NSException *localException) {
        caughtException = YES;
    }
    XCTAssert(caughtException);
}

- (void)testTimeIntervals {
    NSTimeInterval result;
    
    result = AJRTimeIntervalFromValue(nil, 1.0);
    XCTAssert(result == 1.0);
    
    result = AJRTimeIntervalFromValue(@(2.0), 1.0);
    XCTAssert(result == 2.0);
    
    result = AJRTimeIntervalFromValue(@"2.0", 1.0);
    XCTAssert(result == 2.0);
    
    result = AJRTimeIntervalFromValue(@"2", 1.0);
    XCTAssert(result == 2.0, @"%.f isn't 2.0", result);
    
    result = AJRTimeIntervalFromValue(@"bogus", 1.0);
    XCTAssert(result == 1.0);
    
    result = AJRTimeIntervalFromValue([[NSObject alloc] init], 1.0);
    XCTAssert(result == 1.0);
}

- (void)testBools {
    BOOL result;
    
    result = AJRBoolFromValue(@YES, NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@NO, YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@(1), NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@(0), YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"YES", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"NO", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"Y", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"N", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"yes", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"no", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"y", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"n", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"true", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"false", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"t", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"f", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"TRUE", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"FALSE", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(@"T", NO);
    XCTAssert(result);
    
    result = AJRBoolFromValue(@"F", YES);
    XCTAssert(!result);
    
    result = AJRBoolFromValue([[NSObject alloc] init], NO);
    XCTAssert(!result);
    
    result = AJRBoolFromValue(nil, YES);
    XCTAssert(result);
}

- (void)testStrings {
    NSString *result;
    
    result = AJRStringFromValue(nil, @"test");
    XCTAssert([result isEqualToString:@"test"]);
    
    result = AJRStringFromValue(nil, nil);
    XCTAssert(result == nil);
    
    result = AJRStringFromValue(@(10), @"test");
    XCTAssert([result isEqualToString:@"10"]);
    
    result = AJRStringFromValue(@"good", @"test");
    XCTAssert([result isEqualToString:@"good"]);
}

- (void)testIntegers {
    NSInteger result;
    
    result = AJRIntegerFromValue(nil, 1);
    XCTAssert(result == 1);
    
    result = AJRIntegerFromValue(@(10), 1);
    XCTAssert(result == 10);
    
    result = AJRIntegerFromValue(@"10", 1);
    XCTAssert(result == 10);
    
    result = AJRIntegerFromValue(@"10.5", 1);
    XCTAssert(result == 10);
    
    result = AJRIntegerFromValue(@"bogus", 1);
    XCTAssert(result == 1);
    
    result = AJRIntegerFromValue([[NSObject alloc] init], 1);
    XCTAssert(result == 1);
}

- (void)testLongs {
    long result;
    
    result = AJRLongFromValue(nil, 1);
    XCTAssert(result == 1);
    
    result = AJRLongFromValue(@(10), 1);
    XCTAssert(result == 10);
    
    result = AJRLongFromValue(@"10", 1);
    XCTAssert(result == 10);
    
    result = AJRLongFromValue(@"10.5", 1);
    XCTAssert(result == 10);
    
    result = AJRLongFromValue(@"bogus", 1);
    XCTAssert(result == 1);
    
    if (sizeof(long) == 8) {
        result = AJRLongFromValue(@(INT64_MAX), 1);
        XCTAssert(result == INT64_MAX);
    }
    
    result = AJRLongFromValue([[NSObject alloc] init], 1);
    XCTAssert(result == 1);
}

- (void)testLongLongs {
    long long result;
    
    result = AJRLongLongFromValue(nil, 1);
    XCTAssert(result == 1);
    
    result = AJRLongLongFromValue(@(10), 1);
    XCTAssert(result == 10);
    
    result = AJRLongLongFromValue(@"10", 1);
    XCTAssert(result == 10);
    
    result = AJRLongLongFromValue(@"10.5", 1);
    XCTAssert(result == 10);
    
    result = AJRLongLongFromValue(@"bogus", 1);
    XCTAssert(result == 1);
    
    if (sizeof(long long) == 8) {
        result = AJRLongLongFromValue(@(INT64_MAX), 1);
        XCTAssert(result == INT64_MAX);
    }
    
    result = AJRLongLongFromValue([[NSObject alloc] init], 1);
    XCTAssert(result == 1);
}

- (void)testMilliseconds {
    long long result;
    
    result = AJRMillisecondsFromValue(nil, 1);
    XCTAssert(result == 1);
    
    result = AJRMillisecondsFromValue(@(2), 1);
    XCTAssert(result == 2);
    
    result = AJRMillisecondsFromValue([NSDate dateWithTimeIntervalSince1970:1.0], 1);
    XCTAssert(result == 1000);
    
    result = AJRMillisecondsFromValue(@"1s", 1);
    XCTAssert(result == 1000);
    
    result = AJRMillisecondsFromValue(@"1m", 1);
    XCTAssert(result == 1000 * 60);
    
    result = AJRMillisecondsFromValue(@"1h", 1);
    XCTAssert(result == 1000 * 60 * 60);
    
    result = AJRMillisecondsFromValue(@"1d", 1);
    XCTAssert(result == 1000 * 60 * 60 * 24);
    
    result = AJRMillisecondsFromValue(@"1", 0);
    XCTAssert(result == 1);
    
    result = AJRMillisecondsFromValue([[NSObject alloc] init], 1);
    XCTAssert(result == 1);
}

@end
