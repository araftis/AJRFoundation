//
//  NSCoder+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 12/14/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRFoundationOS.h>

@interface NSCoder (Extensions)

- (void)encodeRange:(NSRange)range forKey:(NSString *)key;

- (NSRange)decodeRangeForKey:(NSString *)key;

- (BOOL)decodeBoolForKey:(NSString *)key defaultValue:(BOOL)value;
- (NSInteger)decodeIntegerForKey:(NSString *)key defaultValue:(NSInteger)value;
- (float)decodeFloatForKey:(NSString *)key defaultValue:(float)value;
- (double)decodeDoubleForKey:(NSString *)key defaultValue:(double)value;

@end
