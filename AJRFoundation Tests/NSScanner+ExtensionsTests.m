/*
NSScanner+ExtensionsTests.m
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

@interface NSScanner_ExtensionsTests : XCTestCase

@end

@implementation NSScanner_ExtensionsTests

- (void)testOctalScanning {
    NSScanner *scanner = [NSScanner scannerWithString:@"1 2 3 4 5 6 7 +10 11 12 13 14 15 -10"];
    NSInteger value;
    
    for (NSInteger x = 0; x < 13; x++) {
        XCTAssert([scanner scanOctalInteger:&value] && value == x + 1);
    }
    XCTAssert([scanner scanOctalInteger:&value] && value == -8);
    XCTAssert(![scanner scanOctalInteger:&value]);
}

- (void)testDateScanning {
    NSScanner *scanner = [NSScanner scannerWithString:@"6/16/1971"];
    NSInteger value;
    AJRDateSegmentStringType type;
    
    XCTAssert([scanner scanDateSegment:&value] && value == 6);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 16 && type == AJRDateSegmentStringTypeNumeric);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 1971 && type == AJRDateSegmentStringTypeNumeric);

    scanner = [NSScanner scannerWithString:@"Wednesday, June 16, 1971"];
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 3 && type == AJRDateSegmentStringTypeDayOfWeek);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 6 && type == AJRDateSegmentStringTypeMonth);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 16 && type == AJRDateSegmentStringTypeNumeric);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 1971 && type == AJRDateSegmentStringTypeNumeric);

    scanner = [NSScanner scannerWithString:@"Gooberday, June 16, 1971"];
    XCTAssert([scanner scanDateSegment:&value segmentType:&type]);
    XCTAssert(type == AJRDateSegmentStringTypeInvalid);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 6 && type == AJRDateSegmentStringTypeMonth);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 16 && type == AJRDateSegmentStringTypeNumeric);
    XCTAssert([scanner scanDateSegment:&value segmentType:&type] && value == 1971 && type == AJRDateSegmentStringTypeNumeric);
}

@end
