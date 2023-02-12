/*
 NSDate+Extensions.m
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

#import "NSDate+Extensions.h"

#import "AJRFunctions.h"

const long long AJRMillisPerSecond = 1000LL;
const long long AJRSecondsPerMinute = 60LL;
const long long AJRMinutesPerHour = 60LL;
const long long AJRSecondsPerHour = (60LL * 60LL);
const long long AJRSecondsPerDay = (24LL * 60LL * 60LL);
const long long AJRHoursPerDay = 24LL;
const long long AJRDaysPerWeek = 7LL;
const long long AJRMillisPerMinute = (AJRSecondsPerMinute * AJRMillisPerSecond);
const long long AJRMillisPerHour = (AJRMinutesPerHour * AJRMillisPerMinute);
const long long AJRMillisPerDay = (AJRHoursPerDay * AJRMillisPerHour);
const long long AJRMillisPerWeek = (AJRDaysPerWeek * AJRMillisPerDay);
const long long AJRMillisPer30DayMonth = (30LL * AJRMillisPerDay);
const long long AJRMillisPer365DayYear = (365LL * AJRMillisPerDay);

NSString *AJRISO8601DateFormat = @"%Y-%m-%d";
NSString *AJRISO8601DateTimeFormat = @"%Y-%m-%dT%H:%M:%S%z";

@implementation NSDate (Extensions)

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)timeZone {
	return [[self alloc] initWithYear:year month:month day:day hour:hour minute:minute second:second timeZone:timeZone];
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)timeZone usingCalendar:(NSCalendar *)calendar {
	return [[self alloc] initWithYear:year month:month day:day hour:hour minute:minute second:second timeZone:timeZone usingCalendar:calendar];
}

- (id)initWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)timeZone {
	return [self initWithYear:year month:month day:day hour:hour minute:minute second:second timeZone:timeZone usingCalendar:[NSCalendar currentCalendar]];
}

- (id)initWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)timeZone usingCalendar:(NSCalendar *)calendar {
	NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
	[components setTimeZone:timeZone];
    
    return [self initWithTimeIntervalSinceReferenceDate:[[calendar dateFromComponents:components] timeIntervalSinceReferenceDate]];
}

- (NSInteger)dayOfCommonEra {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:0 timeZone:0] toDate:self options:0] day];
}

- (NSInteger)dayOfMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)dayOfWeek {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSInteger)dayOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate dateWithYear:[self yearOfCommonEra] month:1 day:0 hour:0 minute:0 second:0 timeZone:0] toDate:self options:0] day];
}

- (NSInteger)hourOfDay {
    return [[[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:self] hour];
}

- (NSInteger)minuteOfHour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)monthOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)secondOfMinute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

- (NSInteger)yearOfCommonEra {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSDate *)dateByAddingYears:(NSInteger)year months:(NSInteger)month days:(NSInteger)day hours:(NSInteger)hour minutes:(NSInteger)minute seconds:(NSInteger)second {
	return [self dateByAddingYears:year months:month days:day hours:hour minutes:minute seconds:second usingCalendar:[NSCalendar currentCalendar]];
}

- (NSDate *)dateByAddingYears:(NSInteger)year months:(NSInteger)month days:(NSInteger)day hours:(NSInteger)hour minutes:(NSInteger)minute seconds:(NSInteger)second usingCalendar:(NSCalendar *)calendar {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSDate *newDate;
    
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    
    newDate = [calendar dateByAddingComponents:components toDate:self options:0];
    
    return newDate;
}

- (NSDate *)dateWithZeroTime {
    return [NSDate dateWithYear:[self yearOfCommonEra] month:[self monthOfYear] day:[self dayOfMonth] hour:0 minute:0 second:0 timeZone:[NSTimeZone localTimeZone]];
}

- (NSDate*)dateByAddingDays:(NSInteger)days {
	return [self dateByAddingDays:days usingCalendar:NSCalendar.currentCalendar];
}

- (NSDate*)dateByAddingDays:(NSInteger)days usingCalendar:(NSCalendar *)calendar {
    return [self dateByAddingYears:0 months:0 days:days hours:0 minutes:0 seconds:0 usingCalendar:calendar];
}

- (NSInteger)daysSinceDate:(NSDate *)otherDate {
	return [self daysSinceDate:otherDate usingCalendar:NSCalendar.currentCalendar];
}

- (NSInteger)daysSinceDate:(NSDate *)otherDate usingCalendar:(NSCalendar *)calendar {
	NSDate *selfAdjustedToNoon = [[NSDate alloc] initWithYear:[self yearOfCommonEra]
                                                        month:[self monthOfYear]
                                                          day:[self dayOfMonth]
                                                         hour:12
                                                       minute:0
                                                       second:0
                                                     timeZone:[NSTimeZone localTimeZone]];
    NSDate *otherAdjustedToNoon = [[NSDate alloc] initWithYear:[otherDate yearOfCommonEra]
                                                         month:[otherDate monthOfYear]
                                                           day:[otherDate dayOfMonth]
                                                          hour:12
                                                        minute:0
                                                        second:0
                                                      timeZone:[NSTimeZone localTimeZone]];
	// NOTE: The time is arbitrary, we just want the dates to have the same time, since normally when computing the number of days between two dates, you count partial days as full days.
    NSTimeInterval daysSince = ([selfAdjustedToNoon timeIntervalSinceDate:otherAdjustedToNoon] / 86400);
    return daysSince;
}

- (NSInteger)daysSinceToday {
	return [self daysSinceTodayUsingCalendar:NSCalendar.currentCalendar];
}

- (NSInteger)daysSinceTodayUsingCalendar:(NSCalendar *)calendar {
	return [self daysSinceDate:[NSDate date] usingCalendar:calendar];
}

+ (id)dateWithUNIXTime:(time_t)aTime {
    NSDate        *date;
    struct tm    *tm;
    
    tm = localtime(&aTime);
    date = [NSDate dateWithYear:tm->tm_year + 1900 month:tm->tm_mon + 1 day:tm->tm_mday hour:tm->tm_hour minute:tm->tm_min second:tm->tm_sec timeZone:[NSTimeZone localTimeZone]];
    
    return date;
}

- (time_t)unixTime {
    struct tm        tm;
    NSTimeZone        *detail = [NSTimeZone timeZoneForSecondsFromGMT:0];
    time_t            gmt;
    
    tm.tm_sec = (int)[self secondOfMinute];
    tm.tm_min = (int)[self minuteOfHour];
    tm.tm_hour = (int)[self hourOfDay] - 1;
    tm.tm_mday = (int)[self dayOfMonth];
    tm.tm_mon = (int)[self monthOfYear] - 1;
    tm.tm_year = (int)[self yearOfCommonEra] - 1900;
    tm.tm_wday = (int)[self dayOfWeek];
    tm.tm_yday = (int)[self dayOfYear];
    tm.tm_isdst = [detail isDaylightSavingTime];
    gmt = mktime(&tm);
    tm.tm_gmtoff = [detail secondsFromGMT];
    tm.tm_zone = (char *)[[detail abbreviation] UTF8String];
    
    return gmt;
}

#pragma mark Milliseconds

static NSArray<NSString *> *_ajrUnitMultiplierKeys = nil;
static NSArray<NSNumber *> *_ajrUnitMultiplierValues = nil;

+ (void)_faultUnits {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        _ajrUnitMultiplierKeys = @[@"ms", @"milli", @"mo", @"m", @"s", @"h", @"d", @"w", @"y"];
        _ajrUnitMultiplierValues = @[
			@(1LL),
			@(1LL),
			@(AJRMillisPer30DayMonth),
			@(AJRMillisPerMinute),
			@(AJRMillisPerSecond),
			@(AJRMillisPerHour),
			@(AJRMillisPerDay),
			@(AJRMillisPerWeek),
			@(AJRMillisPer365DayYear)];
	});
}

+ (NSArray<NSString *> *)_unitMultiplierKeys {
    [self _faultUnits];
    return _ajrUnitMultiplierKeys;
}

+ (NSArray<NSNumber *> *)_unitMultiplierValues {
    [self _faultUnits];
    return _ajrUnitMultiplierValues;
}

static BOOL _ajrScanQuantityAndMultiplier(NSScanner *scanner, double *value, double baseMultiplier) {
    __block double baseQuantity;
    __block BOOL didSetValue = NO;
    BOOL scannedQuantity = NO;
    
    if (![scanner scanDouble:&baseQuantity]) {
        baseQuantity = 1.0;
    } else {
        scannedQuantity = YES;
    }
    
    NSString *scannedString;
    if ([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&scannedString]) {
        if ([scannedString length]) {
            scannedString = [scannedString lowercaseString];
            
			[[NSDate _unitMultiplierKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger index, BOOL *stop) {
				if ([scannedString hasPrefix:key]) {
					*value = baseQuantity * [[NSDate _unitMultiplierValues][index] longLongValue];
					didSetValue = YES;
					*stop = YES;
				}
			}];
        }
    }
    
    // If we didn't scan a multiplier, but we did scan
    // a quantity, the value is the quantity by itself
    // i.e. an implicit multiplier of 1
    if (!didSetValue && scannedQuantity) {
        *value = baseQuantity * baseMultiplier;
        didSetValue = YES;
    }
    
    return didSetValue;
}

static BOOL _ajrScanLongLongQuantityAndMultiplier(NSScanner *scanner, long long *value, double baseMultiplier) {
	double intermediateValue;
	BOOL result = _ajrScanQuantityAndMultiplier(scanner, &intermediateValue, baseMultiplier);
	if (result) {
		AJRSetOutParameter(value, (long long)intermediateValue);
	}
	return result;
}

+ (long long)millisecondsForTimePeriodString:(NSString *)value defaultValue:(long long)defaultValue {
    long long longLongValue = defaultValue;
    
    if ([value length]) {
        NSScanner *scanner = [NSScanner scannerWithString:value];
        long long scannedValue;
        long long startingValue = 0;
        
        while (_ajrScanLongLongQuantityAndMultiplier(scanner, &scannedValue, 1.0)) {
            startingValue += scannedValue;
        }
        
        if (startingValue != 0LL) {
            longLongValue = startingValue;
        }
    }
    
    return longLongValue;
}

+ (NSTimeInterval)timeIntervalForTimePeriodString:(NSString *)value defaultValue:(NSTimeInterval)defaultValue {
    NSTimeInterval timeIntervalValue = defaultValue;
    
    if ([value length]) {
        NSScanner *scanner = [NSScanner scannerWithString:value];
        double scannedValue;
		BOOL first = YES;
        
        while (_ajrScanQuantityAndMultiplier(scanner, &scannedValue, AJRMillisPerSecond)) {
			if (first) {
				timeIntervalValue = (double)scannedValue / 1000.0;
				first = NO;
			} else {
				timeIntervalValue += (double)scannedValue / 1000.0;
			}
		}
    }
    
    return timeIntervalValue;
}

@end
