/*
AJRFunctions.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "AJRFunctions.h"

#import "AJRFileFinder.h"
#import "AJRFormat.h"
#import "AJRLogging.h"
#import "AJRRuntime.h"
#import "AJRUnicode.h"
#import "NSCharacterSet+Extensions.h"
#import "NSDate+Extensions.h"
#import "NSError+Extensions.h"
#import "NSScanner+Extensions.h"

#import <objc/runtime.h>

NSFileHandle *AJRStdErr = nil;
NSFileHandle *AJRStdOut = nil;
NSFileHandle *AJRStdIn = nil;

NSString * const AJRDateErrorDomain = @"AJRDateErrorDomain";

struct _AJROpaqueAssertStruct {};
const struct _AJROpaqueAssertStruct _cmd = {};
const struct _AJROpaqueAssertStruct self = {};

@interface AJRFunctionSetup : NSObject
@end

@implementation AJRFunctionSetup

+ (void)load {
    @autoreleasepool {
        AJRStdErr = [NSFileHandle fileHandleWithStandardError];
        AJRStdOut = [NSFileHandle fileHandleWithStandardOutput];
        AJRStdIn = [NSFileHandle fileHandleWithStandardInput];
    }
}

@end

static NSString *tempDirectoryPath = nil;

void AJRVFPrintf(NSFileHandle *fileHandle, NSString *format, va_list ap) {
    NSString *output = AJRFormatv(format, ap);
    [fileHandle writeData:[output dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
}

void AJRVPrintf(NSString *format, va_list ap) {
    AJRVFPrintf(AJRStdOut, format, ap);
}

void AJRFPrintf(NSFileHandle *fileHandle, NSString *format, ...) {
    va_list ap;
    
    va_start(ap, format);
    AJRVFPrintf(fileHandle, format, ap);
    va_end(ap);
}

void AJRPrintf(NSString *format, ...) {
    va_list ap;
    
    va_start(ap, format);
    AJRVFPrintf(AJRStdOut, format, ap);
    va_end(ap);
}

NSString *AJRPrettyPrintKey(NSString *key) {
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    NSCharacterSet *lowercase = [NSCharacterSet lowercaseLetterCharacterSet];
    NSScanner *scanner;
    NSMutableString *string = [NSMutableString string];
    NSString *nextChunk = nil;
    
    if (![key length]) {
        return nil;
    }
    
    // Make the first charater uppercase.
    [string appendString:[[key substringToIndex:1] uppercaseString]];
    
    if ([key length] == 1) return string;
    
    // Create a scanner with the rest of the string
    scanner = [NSScanner scannerWithString:[key substringFromIndex:1]];
    
    // Append lowercase characters onto our string and put a space in front of
    // uppercase characters.
    while ([scanner scanUpToCharactersFromSet:uppercase intoString:&nextChunk]) {
        [string appendString:nextChunk];
        
        if ([scanner scanUpToCharactersFromSet:lowercase intoString:&nextChunk]) {
            [string appendFormat:@" %@", nextChunk];
        }
    }
    
    return string;
}


NSString *AJRGetEnvironmentVariable(NSString *var) {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    __block NSString *returnValue = [environment objectForKey:var];
    
    if (returnValue == nil) {
        [environment enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            if ([key caseInsensitiveCompare:var] == NSOrderedSame)         {
                returnValue = [environment objectForKey:key];
                *stop = YES;
            }
        }];
    }
    
    return returnValue;
}

NSString *AJRFindExecutable(NSString *execName) {
    return [[AJRFileFinder findInEnvironmentPathExecutablesNamed:execName] firstObject];
}

#pragma mark - Geometry

NSString *AJRStringFromRect(CGRect rect) {
    return [NSString stringWithFormat:@"{%@, %@}", AJRStringFromPoint(rect.origin), AJRStringFromSize(rect.size)];
}

NSString *AJRStringFromSize(CGSize size) {
    return [NSString stringWithFormat:@"{%g, %g}", size.width, size.height];
}

NSString *AJRStringFromPoint(CGPoint point) {
    return [NSString stringWithFormat:@"{%g, %g}", point.x, point.y];
}

CGRect AJRRectFromString(NSString *string) {
    CGRect rect = CGRectZero;
    [[NSScanner scannerWithString:string] scanRect:&rect];
    return rect;
}

CGSize AJRSizeFromString(NSString *string) {
    CGSize size = (CGSize){0.0, 0.0};
    [[NSScanner scannerWithString:string] scanSize:&size];
    return size;
}

CGPoint AJRPointFromString(NSString *string) {
    CGPoint point = (CGPoint){0.0, 0.0};
    [[NSScanner scannerWithString:string] scanPoint:&point];
    return point;
}

NSString *AJRBadObjectVersionException = @"AJRBadObjectVersionException";

#pragma mark - Name Manipulation

NSString *AJRVariableNameFromClassName(NSString *className) {
    NSString *packageName = nil;
    NSRange range;

    if ((range = [className rangeOfString:@"."]).location != NSNotFound) {
        packageName = AJRVariableNameFromClassName([className substringToIndex:range.location]);
        className = [className substringFromIndex:range.location + range.length];
    }

    NSMutableString *string = [className mutableCopy];
    NSCharacterSet *swiftIdentifier = [NSCharacterSet ajr_swiftIdentifierCharacterSet];

    // A bit heavy handed. We could make this smarted.
    while ((range = [string rangeOfCharacterFromSet:[swiftIdentifier invertedSet]]).location != NSNotFound) {
        [string replaceCharactersInRange:range withString:@"_"];
    }

    NSInteger index = 0;
    NSInteger length = [string length];
    NSCharacterSet *capitals = [NSCharacterSet uppercaseLetterCharacterSet];
    for (index = 0; index < length && [capitals characterIsMember:[string characterAtIndex:index]]; index++) {
    }

    if (index > 0 && index != length) {
        [string deleteCharactersInRange:(NSRange){0, index - 1}];
        [string replaceCharactersInRange:(NSRange){0, 1} withString:[[string substringToIndex:1] lowercaseString]];
    }

    if (packageName != nil) {
        if ([string length] > 0) {
            [string insertString:@"_" atIndex:0];
        }
        [string insertString:packageName atIndex:0];
    }

    return [string copy];
}

extern NSString *AJRVariableNameFromClass(Class class) {
    return AJRVariableNameFromClassName(AJRStringFromClassSansModule(class));
}

#pragma mark - Dates

static NSError *_AJRBoundMonthDayYear(NSCalendar *calendar, NSInteger month, NSInteger day, NSInteger year) {
    NSInteger daysInMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:AJRDateFromMonthDayAndYear(calendar, month, 1, year)].length;
    
    if ((month < 1) || (month > 12)) {
        return [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeMonthOutOfRange format:@"The entered month must be within January (1) through December (12)."];
    }
    
    if (day < 1) {
        return [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeDayOutOfRange message:@"Day must be at least 1."];
    }
    
    if (day > daysInMonth) {
        return [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeDayOutOfRange format:@"There are only %ld days in the month of %@ in the year %ld.", (long)daysInMonth, [[[[NSDateFormatter alloc] init] monthSymbols] objectAtIndex:month - 1], (long)year];
    }

    return nil;
}

NSInteger AJRYearDerivedFromYearWithoutCentury(NSInteger inputYear, NSInteger currentYear) {
    // This code is designed to compute the current 2 digit year based off the current year. Basically, it assumes you'll want the actual year closer to the current year. So if you input say 01/01/01, and the current year is close to the turn of the century, then the returned year would be say 2001, not 1901.
    if (inputYear < 100) {
        NSInteger returnYear = inputYear;
        NSInteger century = (currentYear / 100) * 100;
        
        if (currentYear % 100 >= 70) {
            if (inputYear < 50) {
                returnYear += (century + 100);
            } else {
                returnYear += century;
            }
        } else if (currentYear % 100 < 30) {
            if (inputYear >= 50) {
                returnYear += (century - 100);
            } else {
                returnYear += century;
            }
        } else {
            returnYear += century;
        }
        
        return returnYear;
    } else {
        return inputYear;
    }
}

NSDate *AJRDateFromMonthDayAndYear(NSCalendar *calendar, NSInteger month, NSInteger day, NSInteger year) {
    return [NSDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil usingCalendar:calendar];
}

NSDate *AJRDateFromString(NSString *string, NSCalendar *calendar, NSError **error) {
    return AJRDateFromStringAndFormat(string, nil, calendar, error);
}

NSDate *AJRDateFromStringAndFormat(NSString *string, NSString * _Nullable format, NSCalendar * _Nullable calendar, NSError * _Nullable * _Nullable error) {
    NSInteger m, d, y, currentYear, w, x;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSMutableArray *formats = nil;
    NSArray *work;
    BOOL usedMonth = NO, usedDay = NO, usedYear = NO;
    BOOL /*hasMonth = NO,*/ hasDay = NO/*, hasYear = NO*/;
    NSDateComponents *today;
    NSString *formatSubstring;
    AJRDateSegmentStringType type;
    
    AJRAssert(string != nil, @"\"string\" may not be nil");

    if (calendar == nil) {
        calendar = [NSCalendar currentCalendar];
    }
    
    /*
     * Get the current time. This will fill in for any unsupplied values.
     */
    today = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:[NSDate date]];
    m = [today month];
    d = [today day];
    y = currentYear = [today year];
    
    [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:NULL];
    // 6/24/97 AJR (1319)
    // This means that we have only digits, so do special parsing to deal with dates that have no whitespace.
    if ([scanner isAtEnd]) {
        NSInteger length = [string length];
        
        if ((length == 1) || (length == 3) || (length == 5) || (length == 7) || (length > 8)) {
            AJRSetOutParameter(error, [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeInvalidFormat message:@"When entering a date with out separators, you must enter mm, mmyy, mmddyy, or mmddyyyy"]);
            return nil;
        }
        
        if (length >= 2) {
            usedMonth = YES;
            m = ([string characterAtIndex:0] - '0') * 10 + ([string characterAtIndex:1] - '0');
        }
        if (length >= 4) {
            usedDay = YES;
            d = ([string characterAtIndex:2] - '0') * 10 + ([string characterAtIndex:3] - '0');
        }
        if (length >= 8) {
            y = ([string characterAtIndex:4] - '0') * 1000 + ([string characterAtIndex:5] - '0') * 100 + ([string characterAtIndex:6] - '0') * 10 + ([string characterAtIndex:7] - '0') * 1;
            usedYear = YES;
        } else if (length >= 6) {
            y = ([string characterAtIndex:4] - '0') * 10 + ([string characterAtIndex:5] - '0');
            usedYear = YES;
        }
        
        if (!usedMonth && !usedDay && !usedYear) {
            NSError *localError = [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeNoValidDate format:@"Could not find a valid date in “%@”.", string];
            AJRSetOutParameter(error, localError);
            return nil;
        }
        
        // Now, if we scanned a day, but not a year, then we'll make the year the "day", since we're going to ajrsume that the user meant to enter mmyy.
        if (usedDay && !usedYear) {
            y = AJRYearDerivedFromYearWithoutCentury(d, currentYear);
            d = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:AJRDateFromMonthDayAndYear(calendar, m, 1, y)].length;
            //usedDay = NO;
            //usedYear = YES;
        } else {
            if (usedYear) y = AJRYearDerivedFromYearWithoutCentury(y, currentYear);
        }
        
        NSError *localError = _AJRBoundMonthDayYear(calendar, m, d, y);
        if (localError != nil) {
            AJRSetOutParameter(error, localError);
            return nil;
        }
        
        return AJRDateFromMonthDayAndYear(calendar, m, d, y);
    }
    [scanner setScanLocation:0];
    
    // Scan our format string and grab all valid format characters. We do so by subdividing format by % and grabbing each, valid bit.
    work = [format componentsSeparatedByString:@"%"];
    if (work) {
        // First, lets pull out all valid format information. Currently, we're only concerned with month, day, or year formating. The rest is ignored.
        formats = [NSMutableArray array];
        for (x = 0; x < (const NSInteger)[work count]; x++) {
            formatSubstring = [work objectAtIndex:x];
            if ([formatSubstring length]) {
                switch ([formatSubstring characterAtIndex:0]) {
                        // Valid Months
                    case 'm':
                    case 'B':
                    case 'b':
                        [formats addObject:@"m"];
                        //hasMonth = YES;
                        break;
                        // Valid Days
                    case 'd':
                    case 'e':
                        hasDay = YES;
                        [formats addObject:@"d"];
                        break;
                        // Valid Years
                    case 'Y':
                    case 'y':
                        [formats addObject:@"y"];
                        //hasYear = YES;
                        break;
                }
            }
        }
        
        // Now, we can look at what we've got, and hopefully get some meaningful information out of it.
        x = 0;
        
        while (1) {
            
            // Get the current format character.
            if (x < [formats count]) {
                formatSubstring = [formats objectAtIndex:x];
            } else {
                formatSubstring = nil;
            }
            
            // Scan the next segment, or break on end of string.
            if (![scanner scanDateSegment:&w segmentType:&type]) break;
            
            if (type == AJRDateSegmentStringTypeDayOfWeek) {
                AJRLog(nil, AJRLogLevelWarning, @"We don't handle days of week yet in date parsing, so ignoring.");
                continue;
            }
            
            if (type == AJRDateSegmentStringTypeInvalid) {
                NSError *localError = [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeInvalidFormat format:@"An invalid substring was encountered while interpreting the date \"%@\".", string];
                AJRSetOutParameter(error, localError);
                return nil;
            }
            
            // We parsed a number.
            switch ([formatSubstring characterAtIndex:0]) {
                    
                case 'm':
                    // I put in error handling, then discovered that, for now, we'll never enter this code, because there's only four states, and we error out of two of them above, so there's no point in checking the other two states.
                    //if (!((type == AJRDateSegmentStringTypeNumeric) || (type == AJRDateSegmentStringTypeMonth))) {
                    //	NSError *localError = [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeInvalidFormat format:@"A substring was encountered while parsing the date \"%@\" that does not represent a month, but a month was expected.", string];
                    //	AJRSetOutParameter(error, localError);
                    //	return nil;
                    //}
                    //usedMonth = YES;
                    m = w;
                    break;
                    
                case 'd':
                    // Bring this code back if we introduce additional types that might cause us to not error out above.
                    //if (!((type == AJRDateSegmentStringTypeNumeric) || (type == AJRDateSegmentStringTypeDayOfWeek))) {
                    //	NSError *localError = [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeInvalidFormat format:@"A substring was encountered while parsing the date \"%@\" that does not represent a day, but a day was expected.", string];
                    //	AJRSetOutParameter(error, localError);
                    //	return nil;
                    //}
                    usedDay = YES;
                    d = w;
                    break;
                    
                case 'y':
                    // Bring this code back if we introduce additional types that might cause us to not error out above.
                    //if (type != AJRDateSegmentStringTypeNumeric) {
                    //	NSError *localError = [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeInvalidFormat format:@"A substring was encountered while parsing the date \"%@\" that does not represent a year, but a year was expected.", string];
                    //	AJRSetOutParameter(error, localError);
                    //	return nil;
                    //}
                    usedYear = YES;
                    y = w;
                    break;
            }
            
            x++;
        }
        
        y = AJRYearDerivedFromYearWithoutCentury(y, currentYear);
        
        // If we don't have days, and we didn't, in fact, scan a day, then we need to set the day to the last day of the month.
        if (!hasDay || (usedYear && !usedDay) || (!usedYear && !usedDay)) {
            d = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:AJRDateFromMonthDayAndYear(calendar, m, 1, y)].length;
        }
    } else {
        // There's no format information, so this is easy.
        do {
            [scanner scanDateSegment:&w segmentType:&type];
            if (type == AJRDateSegmentStringTypeDayOfWeek) {
                AJRLog(nil, AJRLogLevelWarning, @"We don't handle days yet in date parsing, so ignoring.");
            }
        } while (type == AJRDateSegmentStringTypeDayOfWeek);
        
        if (w != NSNotFound) {
            //usedMonth = YES;
            m = w;
        } else {
            NSError *localError = [NSError errorWithDomain:AJRDateErrorDomain code:AJRDateErrorCodeInvalidFormat format:@"No valid date was found in the string \"%@\".", string];
            AJRSetOutParameter(error, localError);
            return nil;
        }
        
        do {
            [scanner scanDateSegment:&w segmentType:&type];
            if (type == AJRDateSegmentStringTypeDayOfWeek) {
                AJRLog(nil, AJRLogLevelWarning, @"We don't handle days yet in date parsing, so ignoring.");
            }
        } while (type == AJRDateSegmentStringTypeDayOfWeek);
        
        if (w != NSNotFound) {
            usedDay = YES;
            d = w;
        }
        
        do {
            [scanner scanDateSegment:&w segmentType:&type];
            if (type == AJRDateSegmentStringTypeDayOfWeek) {
                AJRLog(nil, AJRLogLevelWarning, @"We don't handle days yet in date parsing, so ignoring.");
            }
        } while (type == AJRDateSegmentStringTypeDayOfWeek);
        
        if (w != NSNotFound) {
            y = w;
            usedYear = YES;
        }
        
        if (usedDay && !usedYear) {
            y = AJRYearDerivedFromYearWithoutCentury(d, currentYear);
            d = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:AJRDateFromMonthDayAndYear(calendar, m, 1, y)].length;
        } else {
            y = AJRYearDerivedFromYearWithoutCentury(y, currentYear);
        }
    }
    
    NSError *localError = _AJRBoundMonthDayYear(calendar, m, d, y);
    if (localError != nil) {
        AJRSetOutParameter(error, localError);
        return nil;
    }
    
    return AJRDateFromMonthDayAndYear(calendar, m, d, y);
}

static NSString *AJRDigitsSuperscript = @"⁰¹²³⁴⁵⁶⁷⁸⁹";
static NSString *AJRDigitsSubscript = @"₀₁₂₃₄₅₆₇₈₉";

NSString *AJRNumberToString(long long number, NSString *digits, wchar_t separator) {
    NSUInteger bufferLength = 41;
    wchar_t buffer[bufferLength];
    NSInteger pos = 0;
    BOOL neg = number < 0LL;
    long long base = [digits length];
    
    number = llabs(number);
    buffer[bufferLength - pos - 1] = '\0';
    pos++;
    if (number) {
        while (number != 0LL) {
            buffer[bufferLength - pos - 1] = [digits characterAtIndex:(NSInteger)(number % base)];
            pos++;
            number /= base;
            if (separator && number && pos % 4 == 0) {
                buffer[bufferLength - pos - 1] = separator;
                pos++;
            }
        }
    } else {
        buffer[bufferLength - pos - 1] = '0';
        pos++;
    }
    
    if (neg) {
        buffer[bufferLength - pos - 1] = '-';
        pos++;
    }
    
    return [[NSString alloc] initWithUnicode32String:buffer + (bufferLength - pos)];
}

double AJRWholeNumberWithNumeratorAndDenominatorFromDouble(double input, double minimumDenominator, double *numeratorOut, double *denominatorOut) {
    double whole;
    double fraction;
    double low, high;
    double numerator, denominator;
    double halfStep;
    BOOL negative;
    
    minimumDenominator = exp2(round(log(minimumDenominator) / log(2.0)));
    
    fraction = fabs(modf(fabs(input), &whole));
    low = 0.0;
    numerator = 0.0;
    denominator = minimumDenominator;
    halfStep = (1.0 / minimumDenominator) / 2.0;
    negative = signbit(input);

    if (fraction != 0.0) {
        double test;
        
        for (double scan = 0.0; scan <= minimumDenominator; scan += 1.0) {
            high = (scan + 1.0) / minimumDenominator;
            
            if (fraction >= (low - halfStep) && fraction < (high - halfStep)) {
                numerator = scan;
                break;
            }
            
            low = high;
        }
        
        if (numerator != 0.0) {
            denominator = minimumDenominator;
            
            do {
                test = numerator / 2.0;
                if (floor(test) == test) {
                    numerator = test;
                    denominator /= 2.0;
                }
            } while (numerator == test);
        }
    }
    
    if (numerator == denominator) {
        whole += 1.0;
        numerator = 0;
        denominator = minimumDenominator;
    }
    
    AJRSetOutParameter(denominatorOut, denominator);
    AJRSetOutParameter(numeratorOut, numerator);
    
    return negative ? -whole : whole;
}

double AJRRoundToNearestFraction(double input, double minimumDenominator) {
    double denominator, numerator;
    double whole = AJRWholeNumberWithNumeratorAndDenominatorFromDouble(input, minimumDenominator, &numerator, &denominator);
    double result = fabs(whole) + (numerator / denominator);
    
    return signbit(whole) ? -result : result;
}

NSString *AJRFractionFromDouble(double input, double minimumDenominator) {
    double denominator, numerator;
    double whole = AJRWholeNumberWithNumeratorAndDenominatorFromDouble(input, minimumDenominator, &numerator, &denominator);
    BOOL negative = signbit(whole);
    NSString *result = nil;

    whole = fabs(whole);
    if (numerator != 0.0) {
        if (whole == 0) {
            result = AJRFormat(@"%@%@%lc%@", negative ? @"-" : @"", AJRNumberToString(numerator, AJRDigitsSuperscript, 0), UNICODE_FRACTION_SLASH, AJRNumberToString(denominator, AJRDigitsSubscript, 0));
        } else {
            result = AJRFormat(@"%@%.0f %@%lc%@", negative ? @"-" : @"", whole, AJRNumberToString(numerator, AJRDigitsSuperscript, 0), UNICODE_FRACTION_SLASH, AJRNumberToString(denominator, AJRDigitsSubscript, 0));
        }
    } else {
        result = [NSString stringWithFormat:@"%.0f", input];
    }
    
    return result;
}

NSString *AJRApplicationCachePath(void) {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath;
    
    if (basePath) {
        cachePath = [basePath stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    }
    
    return cachePath;
}

NSURL *AJRApplicationCacheURL(void) {
    NSString *path = AJRApplicationCachePath();
    return path != nil ? [NSURL fileURLWithPath:path] : nil;
}

NSString *AJRDocumentsDirectoryPath(void) {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *documentPath;

    if (basePath) {
        documentPath = [basePath stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    }

    return documentPath;
}

NSURL *AJRDocumentsDirectoryURL(void) {
    NSString *path = AJRDocumentsDirectoryPath();
    return path != nil ? [NSURL fileURLWithPath:path] : nil;
}

NSURL *AJRHomeDirectoryURL(void) {
    NSURL *URL = [NSURL fileURLWithPath:NSHomeDirectory()];

    // I'm not sure how to test this. This case comes up during sand boxing, but we don't have a way to test while sand boxed and then when not sand boxed. I'm open to suggestions.
    if ([[URL pathComponents] containsObject:@"Library"]) {
        while (![[URL lastPathComponent] isEqualToString:@"Library"]) {
            URL = [URL URLByDeletingLastPathComponent];
        }
    }

    return URL;
}

NSString *AJRApplicationSupportPath(void) {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *applicationSupportPath = nil;

    if (basePath) {
        applicationSupportPath = [basePath stringByAppendingPathComponent:NSProcessInfo.processInfo.processName];
    }

    return applicationSupportPath;
}

NSURL *AJRApplicationSupportURL(void) {
    NSString *path = AJRApplicationSupportPath();
    return path != nil ? [NSURL fileURLWithPath:path] : nil;
}

BOOL AJREqual(id left, id right) {
    if (left == nil && right == nil) {
        return YES;
    } else if ((left == nil && right != nil) || (left != nil && right == nil)) {
        return NO;
    }
    return [left isEqual:right];
}

NSComparisonResult AJRCompare(id _Nullable left, id _Nullable right) {
    return AJRCompareUsingSelector(left, right, NULL);
}

typedef NSComparisonResult (*AJRCompareIMP)(id self, SEL _cmd, id other);

NSComparisonResult AJRCompareUsingSelector(id _Nullable left, id _Nullable right, SEL selectorIn) {
    SEL selector = selectorIn ?: @selector(compare:);
    NSComparisonResult result = NSOrderedSame;

    if (left != nil && right != nil) {
        // Check some of the common sort selectors to avoid having to do an actual method look up, which while not overly expensive, could be expensive in a tight loop comparing thousands of objects.
        if (selector == @selector(compare:)) {
            result = [left compare:right];
        } else if (selector == @selector(caseInsensitiveCompare:)) {
            result = [left caseInsensitiveCompare:right];
        } else if (selector == @selector(localizedStandardCompare:)) {
            result = [left localizedStandardCompare:right];
        } else {
            AJRCompareIMP compare = (AJRCompareIMP)class_getMethodImplementation([left class], selector);
            if (compare) {
                result = compare(left, selector, right);
            }
        }
    } else if (left == nil && right != nil) {
        return NSOrderedAscending;
    } else if (left != nil && right == nil) {
        return NSOrderedDescending;
    }

    return result;
}

BOOL AJRApproximateEquals(double left, double right, NSInteger places) {
    NSInteger multiplier = pow(10, places);
    NSInteger iLeft = (NSInteger)round(left * (double)multiplier);
    NSInteger iRight = (NSInteger)round(right * (double)multiplier);
    return iLeft == iRight;
}

uint32_t AJRHash32(uint32_t input) {
    input = ((input >> 16) ^ input) * 0x45d9f3b;
    input = ((input >> 16) ^ input) * 0x45d9f3b;
    input = (input >> 16) ^ input;
    return input;
}

uint64_t AJRHash64(uint64_t input) {
    input = (input ^ (input >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
    input = (input ^ (input >> 27)) * UINT64_C(0x94d049bb133111eb);
    input = input ^ (input >> 31);
    return input;
}

double AJRRoundToPlaces(double input, int places) {
    double multiplier = pow(10.0, (double)places);
    return round(input * multiplier) / multiplier;
}

NSInteger AJRComputeGCD(NSInteger a, NSInteger b) {
    return b == 0 ? a : AJRComputeGCD(b, a % b);
}

#pragma mark - Range Functions

BOOL AJRRangeIntersect(NSRange a, NSRange b) {
    return ((a.location >= b.location && a.location <= b.location + b.length)
            || (a.location + a.length >= b.location && a.location + a.length <= b.location + b.length)
            || (b.location >= a.location && b.location <= a.location + a.length)
            || (b.location + b.length >= a.location && b.location + b.length <= a.location + a.length)
            );
}

#pragma mark - Unique ID

NSString *AJRSemiuniqueIdentifier(void) {
    return [NSString randomStringUsingPattern:@"$$$-$$-$$$"];
}

#pragma mark - Assertions

void _AJRHandleAssertion_impl(volatile const void *owner, NSString *functionOrMethod, NSUInteger lineNumber, NSString *expression, NSString *format, ...) {
    NSString *message;
    
    va_list ap;
    va_start(ap, format);
    message = AJRFormatv(format, ap);
    va_end(ap);
    
    // It might be worth while to make the ajrsertion handler settable.
    NSString *formattedMessage = AJRFormat(@"Assertion %@ failed in %@:%d: %@", expression, functionOrMethod, (int)lineNumber, message);
    AJRLog(nil, AJRLogLevelCritical, @"%@", formattedMessage);

    @throw [NSException exceptionWithName:@"AJRAssertionFailure" reason:formattedMessage userInfo:@{@"expression":expression, @"function":functionOrMethod, @"lineNumber":@(lineNumber)}];
}

void _AJRHandleSoftAssertion_impl(volatile const void *owner, NSString *functionOrMethod, NSUInteger lineNumber, NSString *expression, NSString *format, ...) {
    NSString *message;
    
    va_list ap;
    va_start(ap, format);
    message = AJRFormatv(format, ap);
    va_end(ap);
    
    // It might be worth while to make the ajrsertion handler settable.
    NSString *formattedMessage = AJRFormat(@"Assertion %@ failed in %@:%d: %@", expression, functionOrMethod, (int)lineNumber, message);
    AJRLog(nil, AJRLogLevelWarning, @"%@", formattedMessage);
}

#pragma mark - File Types

NSString *AJRUTIForPathExtension(NSString *extension) {
    NSString *UTI = nil;
    if ([extension length] > 0) {
        UTI = CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL));
    }
    return UTI;
}

#pragma mark - Misc

NSBundle *AJRFoundationBundle(void) {
    return [NSBundle bundleWithIdentifier:@"com.ajr.framework.AJRFoundation"];
}

id AJRCopyCodableObject(id <NSCoding,NSObject> object, Class decodedClass) {
    NSData *data;
    id newObject;
    NSError *localError = nil;

    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [archiver encodeObject:object forKey:@"__ROOT__"];
    [archiver finishEncoding];
    data = archiver.encodedData;
    if (data != nil) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&localError];
        if (unarchiver) {
            unarchiver.requiresSecureCoding = NO;
            if (decodedClass && [object class] != decodedClass) {
                [unarchiver setClass:decodedClass forClassName:NSStringFromClass([object class])];
            }
            newObject = [unarchiver decodeObjectForKey:@"__ROOT__"];
        } else {
            AJRLogWarning(@"Failed to archive object during copy: %@: %@\n", self, localError.localizedDescription);
        }
    }

    return newObject;
}

NSData *AJRDataFromCodableObject(id <NSCoding, NSObject> object) {
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [archiver encodeObject:object forKey:@"__ROOT__"];
    [archiver finishEncoding];
    return archiver.encodedData;
}

id AJRObjectFromEncodedData(NSData *data, NSError **error) {
    id object = nil;
    NSError *localError = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&localError];
    if (unarchiver) {
        unarchiver.requiresSecureCoding = NO;
        object = [unarchiver decodeObjectForKey:@"__ROOT__"];
    }
    return AJRAssertOrPropagateError(object, error, localError);
}

#pragma mark - Dispatch

static void AJRRunOnMainThread(void (^block)(void), BOOL synchronous) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        if (synchronous) {
            dispatch_sync(dispatch_get_main_queue(), block);
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

void AJRRunAsyncOnMainThread(void (^block)(void)) {
    AJRRunOnMainThread(block, NO);
}

void AJRRunSyncOnMainThread(void (^block)(void)) {
    AJRRunOnMainThread(block, YES);
}

void AJRRunAfterDelay(NSTimeInterval delay, void (^block)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}
