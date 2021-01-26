//
//  AJRTimeFormatter.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 10/26/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRTimeFormatter.h"

#import "NSString+Extensions.h"

@implementation AJRTimeFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    long secondsIn = [anObject longValue];
    NSInteger seconds = secondsIn % 60;
    NSInteger minutes = (secondsIn / 60) % 60;
    NSInteger hours = (secondsIn / (60 * 60)) % 24;
    NSInteger days = (secondsIn / (60 * 60 * 24));
    NSMutableString *returnValue = [NSMutableString string];
    
    if (days != 0) {
        [returnValue appendFormat:@"%ld d", (long)days];
    }
    if (hours != 0 || [returnValue length]) {
        if ([returnValue length] > 0) [returnValue appendString:@", "];
        [returnValue appendFormat:@"%ld h", (long)hours];
    }
    if (minutes != 0 || [returnValue length]) {
        if ([returnValue length] > 0) [returnValue appendString:@", "];
        [returnValue appendFormat:@"%ld m", (long)minutes];
    }
    if (seconds != 0 || [returnValue length]) {
        if ([returnValue length] > 0) [returnValue appendString:@", "];
        [returnValue appendFormat:@"%ld s", (long)seconds];
    }

    return returnValue;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    *anObject = [NSNumber numberWithLongLong:[string longLongValue]];
    return YES;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

@end
