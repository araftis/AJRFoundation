/*
 AJRTimeIntervalFormatter.m
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

#import "AJRTimeIntervalFormatter.h"

#import <AJRFoundation/AJRFoundation.h>

#define SECONDS_IN_MINUTE 60.0
#define SECONDS_IN_HOUR (60.0 * 60.0)
#define SECONDS_IN_DAY (24.0 * 60.0 * 60.0)

NSTimeInterval AJRTimeIntervalFromString(NSString *string) {
    NSArray *parts = [string componentsSeparatedByString:@":"];
    NSInteger count = parts.count;
    NSTimeInterval time = 0.0;

    if (count > 0) {
        NSInteger days = 0, hours = 0, minutes = 0;
        double seconds = 0.0;
        seconds = [parts[count - 1] doubleValue];
        if (count > 1) {
            minutes = [parts[count - 2] integerValue];
        }
        if (count > 2) {
            hours = [parts[count - 3] integerValue];
        }
        if (count > 3) {
            days = [parts[count - 4] integerValue];
        }
        time = ((double)days * SECONDS_IN_DAY) + ((double)hours * SECONDS_IN_HOUR) + ((double)minutes * SECONDS_IN_MINUTE) + seconds;
    }

    return time;
}

extern NSString *AJRStringFromTimeInterval(NSTimeInterval value, NSInteger precision) {
    return AJRFormat(@"%.*T", precision, value);
}

@implementation AJRTimeIntervalFormatter

- (id)init {
    return [self initWithPrecision:3];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        if ([coder containsValueForKey:@"precision"]) {
            _precision = [coder decodeIntegerForKey:@"precision"];
        } else {
            _precision = 3;
        }
    }
    return self;
}

- (instancetype)initWithPrecision:(NSInteger)precision {
    if ((self = [super init])) {
        _precision = precision;
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)object {
	if (object != nil) {
		return AJRStringFromTimeInterval([object doubleValue], _precision);
	}
	return @"";
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string range:(inout NSRange *)rangep error:(out NSError **)error {
	NSArray *parts = [string componentsSeparatedByString:@":"];
	NSInteger count = parts.count;
	NSTimeInterval time = 0.0;
	
	if (count > 0) {
		NSInteger days = 0, hours = 0, minutes = 0;
		double seconds = 0.0;
		seconds = [parts[count - 1] doubleValue];
		if (count > 1) {
			minutes = [parts[count - 2] integerValue];
		}
		if (count > 2) {
			hours = [parts[count - 3] integerValue];
		}
		if (count > 3) {
			days = [parts[count - 4] integerValue];
		}
		time = ((double)days * SECONDS_IN_DAY) + ((double)hours * SECONDS_IN_HOUR) + ((double)minutes * SECONDS_IN_MINUTE) + seconds;
	}
	
	if (obj != NULL) {
		*obj = @(time);
	}
	
	return YES;
}

+ (AJRTimeIntervalFormatter *)shared {
	static AJRTimeIntervalFormatter *formatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [[AJRTimeIntervalFormatter alloc] init];
	});
	return formatter;
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval {
	return [[self shared] stringForObjectValue:@(timeInterval)];
}

+ (BOOL)getTimeInterval:(NSTimeInterval *)timeInterval fromString:(NSString *)string error:(NSError **)error {
	BOOL success = NO;
	NSNumber *parsedTimeInterval;
	NSError *localError;
	if ([[self shared] getObjectValue:&parsedTimeInterval forString:string range:NULL error:&localError]) {
		AJRSetOutParameter(timeInterval, [parsedTimeInterval doubleValue]);
		success = YES;
	} else {
		success = NO;
	}
	
	return AJRAssertOrPropagateError(success, error, localError);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeInteger:_precision forKey:@"precision"];
}

@end
