//
//  AJRTimeIntervalFormatter.m
//
//  Created by A.J. Raftis on 2/14/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRTimeIntervalFormatter.h"

#import <AJRFoundation/AJRFoundation.h>

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

- (NSString *)stringForObjectValue:(id)anObject {
	if (anObject != nil) {
		return AJRFormat(@"%.*T", _precision, [anObject doubleValue]);
	}
	return @"";
}

#define SECONDS_IN_MINUTE 60.0
#define SECONDS_IN_HOUR (60.0 * 60.0)
#define SECONDS_IN_DAY (24.0 * 60.0 * 60.0)

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
