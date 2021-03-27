
#import "NSCoder+Extensions.h"

@implementation NSCoder (Extensions)

- (void)encodeRange:(NSRange)range forKey:(NSString *)key {
	[self encodeObject:@{@"location":@(range.location), @"length":@(range.length)} forKey:key];
}

- (NSRange)decodeRangeForKey:(NSString *)key {
    NSRange range;
    NSDictionary *temp = [self decodeObjectForKey:key];
    
    range.location = [[temp objectForKey:@"location"] integerValue];
    range.length = [[temp objectForKey:@"length"] integerValue];
    
    return range;
}

- (BOOL)decodeBoolForKey:(NSString *)key defaultValue:(BOOL)value {
	if ([self containsValueForKey:key]) {
		return [self decodeBoolForKey:key];
	}
	return value;
}

- (NSInteger)decodeIntegerForKey:(NSString *)key defaultValue:(NSInteger)value {
	if ([self containsValueForKey:key]) {
		return [self decodeIntegerForKey:key];
	}
	return value;
}

- (float)decodeFloatForKey:(NSString *)key defaultValue:(float)value {
	if ([self containsValueForKey:key]) {
		return [self decodeFloatForKey:key];
	}
	return value;
}

- (double)decodeDoubleForKey:(NSString *)key defaultValue:(double)value {
	if ([self containsValueForKey:key]) {
		return [self decodeDoubleForKey:key];
	}
	return value;
}

@end
