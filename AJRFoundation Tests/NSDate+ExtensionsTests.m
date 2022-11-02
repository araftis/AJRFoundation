/*
 NSDate+ExtensionsTests.m
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

@interface NSDateTest : XCTestCase

@end

@implementation NSDateTest

- (void)testDateUnits {
    NSDate *date = [NSDate date];
    time_t now = time(&now);
    struct tm *unixTime = localtime(&now);
    
    AJRPrintf(@"dayOfCommonEra = %d\n", [date dayOfCommonEra]);
    AJRPrintf(@"dayOfMonth = %d\n", [date dayOfMonth]);
    AJRPrintf(@"dayOfWeek = %d\n", [date dayOfWeek]);
    AJRPrintf(@"dayOfYear = %d\n", [date dayOfYear]);
    AJRPrintf(@"hourOfDay = %d\n", [date hourOfDay]);
    AJRPrintf(@"minuteOfHour = %d\n", [date minuteOfHour]);
    AJRPrintf(@"monthOfYear = %d\n", [date monthOfYear]);
    AJRPrintf(@"secondOfMinute = %d\n", [date secondOfMinute]);
    AJRPrintf(@"yearOfCommonEra = %d\n", [date yearOfCommonEra]);
    
    XCTAssertTrue(unixTime->tm_mday == [date dayOfMonth], @"Day of month wrong: %ld instead of %d", [date dayOfMonth], unixTime->tm_mday);
    XCTAssertTrue(unixTime->tm_wday + 1 == [date dayOfWeek], @"Day of week wrong: %ld instead of %d", [date dayOfWeek], unixTime->tm_wday + 1);
    XCTAssertTrue(unixTime->tm_yday + 1 == [date dayOfYear], @"Day of year wrong: %ld instead of %d", [date dayOfYear], unixTime->tm_yday);
    XCTAssertTrue(unixTime->tm_hour == [date hourOfDay], @"Hour of day wrong: %ld instead of %d", [date hourOfDay], unixTime->tm_hour);
    XCTAssertTrue(unixTime->tm_min == [date minuteOfHour], @"Minute of hour wrong: %ld instead of %d", [date minuteOfHour], unixTime->tm_min);
    XCTAssertTrue(unixTime->tm_mon + 1 == [date monthOfYear], @"Month of year wrong: %ld instead of %d", [date monthOfYear], unixTime->tm_mon + 1);
    XCTAssertTrue(unixTime->tm_sec == [date secondOfMinute], @"Second of minute wrong: %ld instead of %d", [date secondOfMinute], unixTime->tm_sec);
    XCTAssertTrue(unixTime->tm_year + 1900 == [date yearOfCommonEra], @"Year of common era wrong: %ld instead of %d", [date yearOfCommonEra], unixTime->tm_year + 1900 );
}

- (void)testDateWithZeroTime {
    NSDate *date = [NSDate date];
    NSDate *zeroDate = [date dateWithZeroTime];
    
    AJRPrintf(@"dateWithZeroTime = %@\n", zeroDate);
    XCTAssertTrue([zeroDate hourOfDay] == 0, @"Hour of day wasn't 0");
    XCTAssertTrue([zeroDate minuteOfHour] == 0, @"Minute of hour wasn't 0");
    XCTAssertTrue([zeroDate secondOfMinute] == 0, @"Second of minute wasn't 0");
}

- (void)testUnixTime {
    NSDate *date = [NSDate dateWithYear:1971 month:6 day:16 hour:3 minute:47 second:0 timeZone:[NSTimeZone localTimeZone]];
    time_t unixTime = [date unixTime];
    struct tm *tm = localtime(&unixTime);
    
    AJRPrintf(@"test date = %@\n", date);
    
    XCTAssertTrue(tm->tm_year == 71, @"Year wasn't 71 (1971), it was %d", tm->tm_year);
    XCTAssertTrue(tm->tm_mon == 5, @"Month wasn't 5 (June), it was %d", tm->tm_mon);
    XCTAssertTrue(tm->tm_mday == 16, @"Day wasn't 16, it was %d", tm->tm_mday);
    XCTAssertTrue(tm->tm_hour == 3, @"Hour wasn't 3, it was %d", tm->tm_hour);
    XCTAssertTrue(tm->tm_min == 47, @"Minute wasn't 47, it was %d", tm->tm_min);
    XCTAssertTrue(tm->tm_sec == 0, @"Second wasn't 0, it was %d", tm->tm_sec);
}

- (void)testDateWithUnixTime {
    NSDate *date;
    
    date = [NSDate dateWithUNIXTime:45917220]; // June 16, 1971 @ 3:47 AM
    
    AJRPrintf(@"date = %@\n", date);

    XCTAssertTrue([date yearOfCommonEra] == 1971, @"Year wasn't 71 (1971), it was %ld", [date yearOfCommonEra]);
    XCTAssertTrue([date monthOfYear] == 6, @"Month wasn't 5 (June), it was %ld", [date monthOfYear]);
    XCTAssertTrue([date dayOfMonth] == 16, @"Day wasn't 16, it was %ld", [date dayOfMonth]);
    XCTAssertTrue([date hourOfDay] == 3, @"Hour wasn't 3, it was %ld", [date hourOfDay]);
    XCTAssertTrue([date minuteOfHour] == 47, @"Minute wasn't 47, it was %ld", [date minuteOfHour]);
    XCTAssertTrue([date secondOfMinute] == 0, @"Second wasn't 0, it was %ld", [date secondOfMinute]);
}

- (void)testDateCreation {
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-8*60*60];
    NSDate *date1 = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:timeZone];
    NSDate *date2 = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:timeZone usingCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
    
    XCTAssert([date1 isEqualToDate:date2]);
}

- (void)testDateMath {
    NSDate *date = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:NSTimeZone.localTimeZone];
    NSDate *result = [date dateByAddingYears:40 months:0 days:0 hours:0 minutes:0 seconds:0];
    
    XCTAssert([result yearOfCommonEra] == 2011);

    result = [date dateByAddingDays:365 + 45];
    
    XCTAssert([result yearOfCommonEra] == 1972);
    XCTAssert([result monthOfYear] == 7);
    XCTAssert([result dayOfMonth] == 30);
    
    date = [NSDate date];
    result = [date dateByAddingDays:-10];
    XCTAssert([date daysSinceDate:result] == 10);
    XCTAssert([result daysSinceToday] == -10);
}

- (void)testScanning {
    NSTimeInterval interval;
    
    interval = [NSDate timeIntervalForTimePeriodString:@"1h 15m 10s 15ms" defaultValue:0];
    XCTAssert(interval == (1.0 * AJRSecondsPerHour) + (15.0 * AJRSecondsPerMinute) + 10.0 + (15.0 / AJRMillisPerSecond));
}

@end
