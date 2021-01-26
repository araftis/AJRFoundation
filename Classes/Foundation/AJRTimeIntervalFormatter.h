//
//  AJRTimeIntervalFormatter.h
//  iTunes Movie Importer
//
//  Created by A.J. Raftis on 2/14/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRTimeIntervalFormatter : NSNumberFormatter

- (instancetype)initWithPrecision:(NSInteger)precision;

@property (nonatomic,assign) NSInteger precision;

@property (nonatomic,class,readonly) AJRTimeIntervalFormatter *shared;
+ (nullable NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval;
+ (BOOL)getTimeInterval:(NSTimeInterval *)timeInterval fromString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
