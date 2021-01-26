
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
