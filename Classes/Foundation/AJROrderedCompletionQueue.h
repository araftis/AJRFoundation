/*
AJROrderedCompletionQueue.h
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRQueueState) {
    AJRQueueStateRunning,
    AJRQueueStatePaused,
};

/*! Defines a block that creates a limited resource. This will be called a limited number of times to create a resource to share across multiple threads. */
typedef id _Nonnull (^AJRLimitedResourceCreationBlock)(NSError **error);
/*! Defines a block that will be called with a limited resource. The resource is generally created via a AJRLimitedResourceCreationBlock. */
typedef id _Nonnull (^AJRLimitedResourceWorkBlock)(id limitedResource);
/*! Defines a block that executes without need to access a limited resource. */
typedef id _Nonnull (^AJRWorkBlock)(void);
/*! A block that's called when a job completes. The completion blocks will be called in order of originally submittal. */
typedef void (^AJRWorkCompletionBlock)(id results);

@interface AJROrderedCompletionQueue : NSObject

@property (nonatomic,assign) NSUInteger maxResourceCount;
@property (nonatomic,strong) dispatch_queue_t completionQueue;
@property (nonatomic,readonly) AJRQueueState state;

- (id)initWithLimitedResourceCreationBlock:(AJRLimitedResourceCreationBlock)creationBlock;

- (void)performBlock:(AJRWorkBlock)block withCompletionBlock:(AJRWorkCompletionBlock)completionBlock;
- (void)performLimitedResourceBlock:(AJRLimitedResourceWorkBlock)block withCompletionBlock:(AJRWorkCompletionBlock)completionBlock;

#pragma mark - Controls

- (AJRQueueState)state;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
