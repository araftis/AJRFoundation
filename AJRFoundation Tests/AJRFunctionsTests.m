/*
AJRFunctionsTests.m
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

@interface AJRTestCompareObject : NSObject <NSCoding>

@property (nonatomic,strong) NSNumber *value;

- (id)initWithValue:(NSNumber *)value;

@end

@implementation AJRTestCompareObject

- (id)initWithValue:(NSNumber *)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

- (NSComparisonResult)testCompare:(AJRTestCompareObject *)other {
    return [_value compare:other->_value];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        _value = [coder decodeObjectForKey:@"value"];
    }
    return self;
}

@end

@interface AJRTestCompareObjectSubclass : AJRTestCompareObject
@end

@implementation AJRTestCompareObjectSubclass

@end

@interface AJRFunctionsTests : XCTestCase

@end

@implementation AJRFunctionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRanges {
    NSRange a = { 10, 10 };
    NSRange b = { 5, 20 };
    
    XCTAssert(AJRRangeIntersect(a, b));
    XCTAssert(AJRRangeIntersect(b, a));
    
    b.location = 100;
    XCTAssert(!AJRRangeIntersect(a, b));
    XCTAssert(!AJRRangeIntersect(b, a));
    
    b.location = -100;
    XCTAssert(!AJRRangeIntersect(a, b));
    XCTAssert(!AJRRangeIntersect(b, a));
    
    b.location = a.location - b.length;
    XCTAssert(AJRRangeIntersect(a, b));
    XCTAssert(AJRRangeIntersect(b, a));
}

- (void)subtestPrintf:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    AJRVPrintf(format, ap);
    va_end(ap);
}

- (void)subtestPrintfTo:(NSFileHandle *)fileHandle format:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    AJRVFPrintf(fileHandle, format, ap);
    va_end(ap);
}

- (void)testPrintf {
    NSFileHandle *saved = AJRStdOut;
    AJRMemoryHandle *handle = [AJRMemoryHandle memoryHandleForWriting];
    
    AJRStdOut = handle;
    // Formatter is tested extensively in the AJRFormatTests unit tests. Here, let's just test this API.
    [self subtestPrintf:@"test:%d", (int)10];
    XCTAssert([[[NSString alloc] initWithData:handle.data encoding:NSUTF8StringEncoding] isEqualToString:@"test:10"]);

    handle = [AJRMemoryHandle memoryHandleForWriting];
    [self subtestPrintfTo:handle format:@"test:%d", (int)10];
    XCTAssert([[[NSString alloc] initWithData:handle.data encoding:NSUTF8StringEncoding] isEqualToString:@"test:10"]);

    handle = [AJRMemoryHandle memoryHandleForWriting];
    AJRFPrintf(handle, @"test:%d", (int)10);
    XCTAssert([[[NSString alloc] initWithData:handle.data encoding:NSUTF8StringEncoding] isEqualToString:@"test:10"]);
    
    AJRStdOut = [AJRMemoryHandle memoryHandleForWriting];
    AJRPrintf(@"test:%d", (int)10);
    XCTAssert([[[NSString alloc] initWithData:handle.data encoding:NSUTF8StringEncoding] isEqualToString:@"test:10"]);

    AJRStdOut = saved;
}

- (void)testPrettyPrintKey {
    XCTAssert([AJRPrettyPrintKey(@"camelCase") isEqualToString:@"Camel Case"]);
    XCTAssert(AJRPrettyPrintKey(@"") == nil);
    XCTAssert([AJRPrettyPrintKey(@"a") isEqualToString:@"A"]);
}

- (void)testGetEnvironmentVariable {
    XCTAssert([AJRGetEnvironmentVariable(@"TEST_VARIABLE") isEqualToString:@"Test"]);
    XCTAssert([AJRGetEnvironmentVariable(@"test_variable") isEqualToString:@"Test"]);
}

- (void)testFindExecutable {
    XCTAssert([AJRFindExecutable(@"ls") isEqualToString:@"/bin/ls"]);
}

- (void)testGeometryToStrings {
    CGRect integralRect = {{-10, -5}, {10, 50}};
    NSString *integralString = @"{{-10, -5}, {10, 50}}";
    CGRect fractionalRect = {{-10.5, -5.5}, {10.5, 50.5}};
    NSString *fractionalString = @"{{-10.5, -5.5}, {10.5, 50.5}}";
    XCTAssert([AJRStringFromRect(integralRect) isEqualToString:integralString]);
    XCTAssert([AJRStringFromRect(fractionalRect) isEqualToString:fractionalString]);
    XCTAssert(NSEqualRects(AJRRectFromString(integralString), integralRect));
    XCTAssert(NSEqualRects(AJRRectFromString(fractionalString), fractionalRect));
    XCTAssert(NSEqualSizes(AJRSizeFromString(@"{10, 50}"), integralRect.size));
    XCTAssert(NSEqualSizes(AJRSizeFromString(@"{10.5, 50.5}"), fractionalRect.size));
    XCTAssert(NSEqualPoints(AJRPointFromString(@"{-10, -5}"), integralRect.origin));
    XCTAssert(NSEqualPoints(AJRPointFromString(@"{-10.5, -5.5}"), fractionalRect.origin));
}

- (void)testDates {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger year = [components year];
    NSInteger day = [components day];
    NSError *localError = nil;
    NSDate *date;
    XCTAssert([AJRDateFromString(@"06", nil, NULL) isEqualToDate:[NSDate dateWithYear:year month:6 day:day hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([AJRDateFromString(@"0616", nil, NULL) isEqualToDate:[NSDate dateWithYear:2016 month:6 day:30 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([AJRDateFromString(@"061671", nil, NULL) isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([AJRDateFromString(@"06161971", nil, NULL) isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    date = AJRDateFromString(@"1", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError != nil);
    date = AJRDateFromString(@"111", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError != nil);
    date = AJRDateFromString(@"11111", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError != nil);
    date = AJRDateFromString(@"1111111", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError != nil);
    date = AJRDateFromString(@"111111111", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError != nil);

    // Bounds checking...
    date = AJRDateFromString(@"06311971", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError.code == AJRDateErrorCodeDayOutOfRange);
    
    date = AJRDateFromString(@"06001971", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError.code == AJRDateErrorCodeDayOutOfRange);

    date = AJRDateFromString(@"13011971", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError.code == AJRDateErrorCodeMonthOutOfRange);

    // We can't test this is the normal flow, because the normal flow will always use "now" to compute the current year.
    XCTAssert(AJRYearDerivedFromYearWithoutCentury(71, 2019) == 1971);
    XCTAssert(AJRYearDerivedFromYearWithoutCentury(71, 1991) == 1971);
    XCTAssert(AJRYearDerivedFromYearWithoutCentury(20, 1991) == 2020);
    XCTAssert(AJRYearDerivedFromYearWithoutCentury(71, 1950) == 1971);
    
    date = AJRDateFromString(@"", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError.code == AJRDateErrorCodeNoValidDate);

    XCTAssert([AJRDateFromString(@"June 16, 1971", nil, NULL) isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([AJRDateFromString(@"June 16", nil, NULL) isEqualToDate:[NSDate dateWithYear:2016 month:6 day:30 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([AJRDateFromString(@"June", nil, NULL) isEqualToDate:[NSDate dateWithYear:year month:6 day:day hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    
    AJRLogSetOutputStream([NSOutputStream outputStreamToMemory], AJRLogLevelWarning);
    XCTAssert([AJRDateFromString(@"Wednesday, June 16, 1971", nil, NULL) isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([[AJRLogGetOutputStream(AJRLogLevelWarning) ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] containsString:@"<WARNING>: We don't handle days yet in date parsing, so ignoring."]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    
    AJRLogSetOutputStream([NSOutputStream outputStreamToMemory], AJRLogLevelWarning);
    XCTAssert([AJRDateFromString(@"June, Wednesday, 16, 1971", nil, NULL) isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([[AJRLogGetOutputStream(AJRLogLevelWarning) ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] containsString:@"<WARNING>: We don't handle days yet in date parsing, so ignoring."]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    
    AJRLogSetOutputStream([NSOutputStream outputStreamToMemory], AJRLogLevelWarning);
    XCTAssert([AJRDateFromString(@"June 16, Wednesday, 1971", nil, NULL) isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([[AJRLogGetOutputStream(AJRLogLevelWarning) ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] containsString:@"<WARNING>: We don't handle days yet in date parsing, so ignoring."]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    
    date = AJRDateFromString(@"Squidward 16, 1971", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError.code == AJRDateErrorCodeInvalidFormat);

    date = AJRDateFromString(@"June 31, 1971", nil, &localError);
    XCTAssert(date == nil);
    XCTAssert(localError.code == AJRDateErrorCodeDayOutOfRange);
    
    localError = nil;
    date = AJRDateFromStringAndFormat(@"June 16", @"%m %d", nil, &localError);
    XCTAssert(localError == nil);
    XCTAssert([date isEqualToDate:[NSDate dateWithYear:year month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    
    localError = nil;
    date = AJRDateFromStringAndFormat(@"1971-6-16", @"%y/%m/%d", nil, &localError);
    XCTAssert(localError == nil);
    XCTAssert([date isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    
    AJRLogSetOutputStream([NSOutputStream outputStreamToMemory], AJRLogLevelWarning);
    localError = nil;
    date = AJRDateFromStringAndFormat(@"Wednesday, June 16, 1971", @"%m/%d/%y", nil, &localError);
    XCTAssert(localError == nil);
    XCTAssert([date isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    XCTAssert([[AJRLogGetOutputStream(AJRLogLevelWarning) ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] containsString:@"<WARNING>: We don't handle days of week yet in date parsing, so ignoring."]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    
    localError = nil;
    date = AJRDateFromStringAndFormat(@"Squidward 16", @"%m/%d", nil, &localError);
    XCTAssert(localError.code == AJRDateErrorCodeInvalidFormat);
    XCTAssert(date == nil);
    
    localError = nil;
    date = AJRDateFromStringAndFormat(@"June", @"%m/%d", nil, &localError);
    XCTAssert(localError == nil);
    XCTAssert([date isEqualToDate:[NSDate dateWithYear:year month:6 day:30 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
    
    localError = nil;
    date = AJRDateFromStringAndFormat(@"June 1971", @"%m/%y", nil, &localError);
    XCTAssert(localError == nil);
    XCTAssert([date isEqualToDate:[NSDate dateWithYear:1971 month:6 day:30 hour:0 minute:0 second:0 timeZone:nil usingCalendar:[NSCalendar currentCalendar]]]);
}

- (void)testNumericConversion {
    NSString *digits = @"0123456789";
    NSString *hexDigits = @"0123456789ABCDEF";

    XCTAssert([AJRNumberToString(0, digits, 0) isEqualToString:@"0"]);
    XCTAssert([AJRNumberToString(12345678, digits, 0) isEqualToString:@"12345678"]);
    XCTAssert([AJRNumberToString(12345678, digits, ',') isEqualToString:@"12,345,678"]);
    XCTAssert([AJRNumberToString(0x89ABCDEF, hexDigits, 0) isEqualToString:@"89ABCDEF"]);
    XCTAssert([AJRNumberToString(0x89ABCDEF, hexDigits, ',') isEqualToString:@"89,ABC,DEF"]);
    XCTAssert([AJRNumberToString(-12345678, digits, 0) isEqualToString:@"-12345678"]);
    XCTAssert([AJRNumberToString(-12345678, digits, ',') isEqualToString:@"-12,345,678"]);
    XCTAssert([AJRNumberToString(-0x89ABCDEFLL, hexDigits, 0) isEqualToString:@"-89ABCDEF"]);
    XCTAssert([AJRNumberToString(-0x89ABCDEFLL, hexDigits, ',') isEqualToString:@"-89,ABC,DEF"]);
}

- (void)testFractions {
    double increment = 1.0 / 64.0;
    
    for (double value = -2.0; value <= 2.0; value += increment) {
        NSString *result1 = AJRFractionFromDouble(value, 64.0);
        NSString *result2 = AJRFractionFromDouble(value, 32.0);
        NSString *result3 = AJRFractionFromDouble(value, 16.0);
        
        AJRPrintf(@"%@, %@, %@: %.5f\n", result1, result2, result3, AJRRoundToNearestFraction(value, 16.0));
    }
}

- (void)testRounding {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    double minimumDenominator = 32.0;
    
    [formatter setPositiveFormat:@"0.####################"];
    [formatter setNegativeFormat:@"-0.####################"];
    
    for (double value = -144.0; value < 144.0; value += 1.0) {
        double rounded = AJRRoundToNearestFraction(value / 72.0, minimumDenominator) * 72.0;
        
        AJRPrintf(@"%4.0f pts: %4.0f, %@”\n", value, rounded, AJRFractionFromDouble(value / 72.0, minimumDenominator));
    }
}

- (void)testPaths {
    NSURL *url = AJRApplicationCacheURL();
    NSURL *compareToURL = [NSURL fileURLWithPathComponents:@[NSHomeDirectory(), @"Library", @"Caches", NSProcessInfo.processInfo.processName]];
    XCTAssert([url isEqualToURL:compareToURL]);
    
    url = AJRDocumentsDirectoryURL();
    compareToURL = [NSURL fileURLWithPathComponents:@[NSHomeDirectory(), @"Documents", NSProcessInfo.processInfo.processName]];
    XCTAssert([url isEqualToURL:compareToURL]);
    
    url = AJRHomeDirectoryURL();
    compareToURL = [NSURL fileURLWithPathComponents:@[NSHomeDirectory()]];
    XCTAssert([url isEqualToURL:compareToURL]);
    
    url = AJRApplicationSupportURL();
    compareToURL = [NSURL fileURLWithPathComponents:@[NSHomeDirectory(), @"Library", @"Application Support", NSProcessInfo.processInfo.processName]];
    XCTAssert([url isEqualToURL:compareToURL]);
}

- (void)testEquality {
    XCTAssert(AJREqual(nil, nil));
    XCTAssert(!AJREqual(nil, @(1)));
    XCTAssert(!AJREqual(@(1), nil));
    XCTAssert(AJREqual(@(1), @(1)));
    XCTAssert(!AJREqual(@(1), @(2)));
    
    XCTAssert(AJRCompare(nil, nil) == NSOrderedSame);
    XCTAssert(AJRCompare(nil, @(1)) == NSOrderedAscending);
    XCTAssert(AJRCompare(@(1), nil) == NSOrderedDescending);
    XCTAssert(AJRCompare(@(1), @(1)) == NSOrderedSame);
    XCTAssert(AJRCompare(@(1), @(2)) == NSOrderedAscending);
    XCTAssert(AJRCompare(@(2), @(1)) == NSOrderedDescending);
    
    XCTAssert(AJRCompareUsingSelector(nil, nil, @selector(caseInsensitiveCompare:)) == NSOrderedSame);
    XCTAssert(AJRCompareUsingSelector(nil, @"alex", @selector(caseInsensitiveCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(@"alex", nil, @selector(caseInsensitiveCompare:)) == NSOrderedDescending);
    XCTAssert(AJRCompareUsingSelector(@"alex", @"Alex", @selector(caseInsensitiveCompare:)) == NSOrderedSame);
    XCTAssert(AJRCompareUsingSelector(@"alex", @"Lyn", @selector(caseInsensitiveCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(@"Lyn", @"alex", @selector(caseInsensitiveCompare:)) == NSOrderedDescending);
    
    XCTAssert(AJRCompareUsingSelector(nil, nil, @selector(localizedStandardCompare:)) == NSOrderedSame);
    XCTAssert(AJRCompareUsingSelector(nil, @"alex", @selector(localizedStandardCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(@"alex", nil, @selector(localizedStandardCompare:)) == NSOrderedDescending);
    XCTAssert(AJRCompareUsingSelector(@"alex", @"Alex", @selector(localizedStandardCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(@"alex", @"Lyn", @selector(localizedStandardCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(@"Lyn", @"alex", @selector(localizedStandardCompare:)) == NSOrderedDescending);
    
    AJRTestCompareObject *object1 = [[AJRTestCompareObject alloc] initWithValue:@(1)];
    AJRTestCompareObject *object2 = [[AJRTestCompareObject alloc] initWithValue:@(2)];
    XCTAssert(AJRCompareUsingSelector(nil, nil, @selector(testCompare:)) == NSOrderedSame);
    XCTAssert(AJRCompareUsingSelector(nil, object1, @selector(testCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(object1, nil, @selector(testCompare:)) == NSOrderedDescending);
    XCTAssert(AJRCompareUsingSelector(object1, object1, @selector(testCompare:)) == NSOrderedSame);
    XCTAssert(AJRCompareUsingSelector(object1, object2, @selector(testCompare:)) == NSOrderedAscending);
    XCTAssert(AJRCompareUsingSelector(object2, object1, @selector(testCompare:)) == NSOrderedDescending);
    
    XCTAssert(AJRApproximateEquals(1.000001, 1.000002, 2));
    XCTAssert(AJRApproximateEquals(1.000001, 1.000002, 3));
    XCTAssert(AJRApproximateEquals(1.000001, 1.000002, 4));
    XCTAssert(AJRApproximateEquals(1.000001, 1.000002, 5));
    XCTAssert(!AJRApproximateEquals(1.000001, 1.000002, 6));
}

- (void)testMath {
    // Just calling these to make sure we get different values. I suppose a better test would be to insert a bunch of sequential integers into a hash table and then verify that we got a good distribution in the hash function.
    XCTAssert(AJRHash32((uint32_t)1) == AJRHash32((uint32_t)1));
    XCTAssert(AJRHash32((uint32_t)1) != AJRHash32((uint32_t)2));
    XCTAssert(AJRHash64((uint64_t)1) == AJRHash64((uint64_t)1));
    XCTAssert(AJRHash64((uint64_t)1) != AJRHash64((uint64_t)2));
    
    XCTAssert(AJRRoundToPlaces(1.123456789, 0) == 1.0);
    XCTAssert(AJRRoundToPlaces(1.123456789, 1) == 1.1);
    XCTAssert(AJRRoundToPlaces(1.123456789, 2) == 1.12);
    XCTAssert(AJRRoundToPlaces(1.123456789, 3) == 1.123);
    XCTAssert(AJRRoundToPlaces(1.123456789, 4) == 1.1235);
    XCTAssert(AJRRoundToPlaces(1.123456789, 5) == 1.12346);
    XCTAssert(AJRRoundToPlaces(1.123456789, 6) == 1.123457);
    XCTAssert(AJRRoundToPlaces(1.123456789, 7) == 1.1234568);
    XCTAssert(AJRRoundToPlaces(1.123456789, 8) == 1.12345679);
    
    XCTAssert(AJRComputeGCD(2, 4) == 2);
    XCTAssert(AJRComputeGCD(2, 5) == 1);
    XCTAssert(AJRComputeGCD(2, 6) == 2);
    XCTAssert(AJRComputeGCD(3, 12) == 3);
    XCTAssert(AJRComputeGCD(4, 12) == 4);
}

- (void)testUniqueID {
    // This is just testing the API, as we test random string pattern generation more thoroughly in another unit test.
    XCTAssert(AJRSemiuniqueIdentifier() != nil);
}

- (void)testUTIs {
    // Test a few we know will be defined on the system.
    XCTAssert([AJRUTIForPathExtension(@"png") isEqualToString:@"public.png"]);
    XCTAssert([AJRUTIForPathExtension(@"jpg") isEqualToString:@"public.jpeg"]);
    XCTAssert([AJRUTIForPathExtension(@"jpeg") isEqualToString:@"public.jpeg"]);
    XCTAssert([AJRUTIForPathExtension(@"m4v") isEqualToString:@"com.apple.m4v-video"]);
    XCTAssert(AJRUTIForPathExtension(@"") == nil);
}

- (void)testBundle {
    XCTAssert([AJRFoundationBundle().infoDictionary[(__bridge NSString *)kCFBundleIdentifierKey] isEqualToString:@"com.ajr.framework.AJRFoundation"]);
}

- (void)testAssertions {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    
    AJRLogSetOutputStream(outputStream, AJRLogLevelWarning);
    AJRSoftAssert(YES, @"Test failure");
    XCTAssert([[outputStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] length] == 0);
    AJRSoftAssert(NO, @"Test failure");
    XCTAssert([[outputStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] hasPrefix:@"<WARNING>: Assertion NO failed in "]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);

    outputStream = [NSOutputStream outputStreamToMemory];
    
    BOOL caught = NO;
    AJRLogSetOutputStream(outputStream, AJRLogLevelCritical);
    @try {
        AJRAssert(YES, @"Test failure");
    } @catch (NSException *exception) {
        caught = YES;
    }
    XCTAssert([[outputStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] length] == 0);
    XCTAssert(caught == NO);
    @try {
        AJRAssert( NO, @"Test failure");
    } @catch (NSException *exception) {
        caught = YES;
    }
    XCTAssert(caught == YES);
    XCTAssert([[outputStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] hasPrefix:@"<CRITICAL>: Assertion NO failed in "]);
    AJRLogSetOutputStream(nil, AJRLogLevelCritical);
}

- (void)testCopying {
    id input = @"This is a test.";
    id output = AJRCopyCodableObject(input, [NSString class]);
    
    XCTAssert(input != output);
    XCTAssert([input isEqual:output]);
    
    input = [[AJRTestCompareObject alloc] initWithValue:@(10)];
    output = AJRCopyCodableObject(input, [AJRTestCompareObjectSubclass class]);
    XCTAssert(output != nil);
    XCTAssert([output isKindOfClass:[AJRTestCompareObjectSubclass class]]);
}

- (void)testVariableName {
    XCTAssert([AJRVariableNameFromClassName(@"AJRTestClass") isEqualToString:@"testClass"]);
    XCTAssert([AJRVariableNameFromClassName(@"TestClass") isEqualToString:@"testClass"]);
    XCTAssert([AJRVariableNameFromClassName(@"testClass") isEqualToString:@"testClass"]);
    XCTAssert([AJRVariableNameFromClassName(@"Package.AJRTestClass") isEqualToString:@"package_testClass"]);
    XCTAssert([AJRVariableNameFromClassName(@"Package.") isEqualToString:@"package"]);
    XCTAssert([AJRVariableNameFromClassName(@".") isEqualToString:@""]);
}

@end
