//
//  AJRConversions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSArray *AJRArrayFromValue(id _Nullable value);
extern NSDictionary *AJRDictionaryFromValue(id _Nullable value);
extern NSTimeInterval AJRTimeIntervalFromValue(id _Nullable value, NSTimeInterval defaultValue);
extern BOOL AJRBoolFromValue(id _Nullable value, BOOL defaultValue);
extern NSString *AJRStringFromValue(id _Nullable value, NSString * _Nullable defaultValue);
extern NSInteger AJRIntegerFromValue(id _Nullable value, NSInteger defaultValue);
extern long AJRLongFromValue(id _Nullable value, long defaultValue);
extern long long AJRLongLongFromValue(id _Nullable value, long long defaultValue);
extern long long AJRMillisecondsFromValue(id _Nullable value, long long defaultValue);

NS_ASSUME_NONNULL_END
