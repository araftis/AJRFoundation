//
//  NSThread+Extensions.h
//  AJRFoundation
//
//  Created by AJ Raftis on 1/25/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (Extensions)

- (void)performAsyncBlock:(void (^)(void))block;
- (void)performSyncBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
