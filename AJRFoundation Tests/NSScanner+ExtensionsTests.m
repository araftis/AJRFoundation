
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
