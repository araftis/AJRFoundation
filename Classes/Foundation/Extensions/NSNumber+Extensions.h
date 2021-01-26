
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (AJRExtensions)

- (BOOL)isEqualToString:(NSString *)other;

+ (void)seedRandomNumbersWithSeed:(unsigned int)seed;
+ (id)randomNumber;
+ (id)randomNumberInRange:(NSRange)range;
+ (nullable NSNumber *)numberFromString:(NSString *)string;

@property (nonatomic,readonly) BOOL isFloatingPoint;
@property (nonatomic,readonly) BOOL isPositive;
@property (nonatomic,readonly) BOOL isNegative;
@property (nonatomic,readonly) BOOL isInteger;

@end

NS_ASSUME_NONNULL_END
