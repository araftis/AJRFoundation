
#import <Foundation/Foundation.h>

extern NSString *AJRISO8601DateFormat;
extern NSString *AJRISO8601DateTimeFormat;

extern const long long AJRMillisPerSecond;
extern const long long AJRSecondsPerMinute;
extern const long long AJRMinutesPerHour;
extern const long long AJRSecondsPerHour;
extern const long long AJRSecondsPerDay;
extern const long long AJRHoursPerDay;
extern const long long AJRDaysPerWeek;
extern const long long AJRMillisPerMinute;
extern const long long AJRMillisPerHour;
extern const long long AJRMillisPerDay;
extern const long long AJRMillisPerWeek;
extern const long long AJRMillisPer30DayMonth;
extern const long long AJRMillisPer365DayYear;

@interface NSDate (Extensions)

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)timeZone usingCalendar:(NSCalendar *)calendar;

- (id)initWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)aTimeZone;
- (id)initWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second timeZone:(NSTimeZone *)aTimeZone usingCalendar:(NSCalendar *)calendar;

- (NSInteger)dayOfCommonEra;
- (NSInteger)dayOfMonth;
- (NSInteger)dayOfWeek;
- (NSInteger)dayOfYear;
- (NSInteger)hourOfDay;
- (NSInteger)minuteOfHour;
- (NSInteger)monthOfYear;
- (NSInteger)secondOfMinute;
- (NSInteger)yearOfCommonEra;

- (NSDate *)dateByAddingYears:(NSInteger)year months:(NSInteger)month days:(NSInteger)day hours:(NSInteger)hour minutes:(NSInteger)minute seconds:(NSInteger)second;
- (NSDate *)dateByAddingYears:(NSInteger)year months:(NSInteger)month days:(NSInteger)day hours:(NSInteger)hour minutes:(NSInteger)minute seconds:(NSInteger)second usingCalendar:(NSCalendar *)calendar;

- (NSDate *)dateWithZeroTime;
- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateByAddingDays:(NSInteger)days usingCalendar:(NSCalendar *)calendar;
- (NSInteger)daysSinceDate:(NSDate *)otherDate;
- (NSInteger)daysSinceDate:(NSDate *)otherDate usingCalendar:(NSCalendar *)calendar;
- (NSInteger)daysSinceToday;
- (NSInteger)daysSinceTodayUsingCalendar:(NSCalendar *)calendar;

#pragma mark - UNIX Time

+ (id)dateWithUNIXTime:(time_t)aTime;
- (time_t)unixTime;

 #pragma mark -  Working with milliseconds

+ (long long)millisecondsForTimePeriodString:(NSString *)value defaultValue:(long long)defaultValue;
+ (NSTimeInterval)timeIntervalForTimePeriodString:(NSString *)value defaultValue:(NSTimeInterval)defaultValue;

@end
