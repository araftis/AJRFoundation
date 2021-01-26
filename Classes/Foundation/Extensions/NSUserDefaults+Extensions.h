//
//  NSUserDefaults+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 9/15/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (Extensions)

- (Class)classForKey:(NSString *)key defaultValue:(nullable Class)defaultValue;
- (void)setClass:(nullable Class)class forKey:(NSString *)key;

- (NSUnit *)unitsForKey:(NSString *)key defaultValue:(nullable NSUnit *)defaultValue;
- (void)setUnits:(nullable NSUnit *)units forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
