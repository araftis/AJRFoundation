/*
 NSNumber+Extensions.m
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

#import "NSNumber+Extensions.h"

#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "NSString+Extensions.h"

@implementation NSNumber (AJRExtensions)

- (BOOL)isEqualToString:(NSString *)other {
    if (self.isUnsignedInteger) {
        return self.unsignedLongLongValue == other.unsignedLongLongValue;
    } else if (self.isFloatingPoint) {
        return self.doubleValue == other.doubleValue;
    } else {
        return self.longLongValue == other.longLongValue;
    }
}

static BOOL _isSeeded = NO;
static NSLock *_lock = nil;

/*!
 Private method that makes sure we only access our private variables above while holding the lock. Also makes sure the lock exists in a thread safe manner.
 
 @param block A block to call once the lock is safely held. This block may access the  _isSeeded static variable.
 */
+ (void)accessSeedWithBlock:(void (^)(void))block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = [[NSLock alloc] init];
    });
    [_lock lock];
    @try {
        block();
    } @catch (NSException *localException) {
        // Ignore.
    } @finally {
        [_lock unlock];
    }
}

+ (void)seedRandomNumbersWithSeed:(unsigned int)seed {
    [self accessSeedWithBlock:^{
        srandom(seed);
        _isSeeded = YES;
    }];
}

+ (id)randomNumber {
    return [self randomNumberInRange:(NSRange){0, NSUIntegerMax}];
}

+ (id)randomNumberInRange:(NSRange)range {
    [self accessSeedWithBlock:^{
        if (!_isSeeded) {
            srandom([NSDate timeIntervalSinceReferenceDate]);
            _isSeeded = YES;
        }
    }];
    return [[self class] numberWithUnsignedInteger:(random() % range.length) + range.location];
}

+ (NSNumber *)numberFromString:(NSString *)string {
    return [string numberValue];
}

- (BOOL)isPositive {
    if (self.isUnsignedInteger) {
        return YES;
    } else if (self.isFloatingPoint) {
        return self.doubleValue >= 0.0;
    } else {
        return self.longLongValue >= 0;
    }
}

- (BOOL)isNegative {
    return !self.isPositive;
}

- (BOOL)isFloatingPoint {
    const char *type = [self objCType];
    return (strlen(type) > 0
            && (type[0] == @encode(float)[0]
                || type[0] == @encode(double)[0]
                || type[0] == @encode(long double)[0]));
}

- (BOOL)isUnsignedInteger {
    const char *type = [self objCType];
    return (strlen(type) > 0
            && (type[0] == @encode(uint8_t)[0]
                || type[0] == @encode(uint16_t)[0]
                || type[0] == @encode(uint32_t)[0]
                || type[0] == @encode(uint64_t)[0]
                || type[0] == @encode(unsigned long long)[0]
                || type[0] == @encode(_Bool)[0]));
}

- (BOOL)isInteger {
    const char *type = [self objCType];
    return (strlen(type) > 0
            && (type[0] == @encode(int8_t)[0] || type[0] == @encode(uint8_t)[0]
                || type[0] == @encode(int16_t)[0] || type[0] == @encode(uint16_t)[0]
                || type[0] == @encode(int32_t)[0] || type[0] == @encode(uint32_t)[0]
                || type[0] == @encode(int64_t)[0] || type[0] == @encode(uint64_t)[0]
                || type[0] == @encode(long long)[0] || type[0] == @encode(unsigned long long)[0]
                || type[0] == @encode(_Bool)[0]));
}

@end
