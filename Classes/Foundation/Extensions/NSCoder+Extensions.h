
#import <AJRFoundation/AJRFoundationOS.h>

@interface NSCoder (Extensions)

- (void)encodeRange:(NSRange)range forKey:(NSString *)key;

- (NSRange)decodeRangeForKey:(NSString *)key;

- (BOOL)decodeBoolForKey:(NSString *)key defaultValue:(BOOL)value;
- (NSInteger)decodeIntegerForKey:(NSString *)key defaultValue:(NSInteger)value;
- (float)decodeFloatForKey:(NSString *)key defaultValue:(float)value;
- (double)decodeDoubleForKey:(NSString *)key defaultValue:(double)value;

@end
