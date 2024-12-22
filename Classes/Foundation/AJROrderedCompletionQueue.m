/*
 AJROrderedCompletionQueue.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import "AJROrderedCompletionQueue.h"

#import "AJRLogging.h"

AJRLoggingDomain AJROrderedCompletionQueueDomain = @"AJROrderedCompletionQueueDomain";

@implementation AJROrderedCompletionQueue {
    AJRLimitedResourceCreationBlock _limitedResourceCreationBlock;
    NSMutableArray *_limitedResources;
    NSUInteger _limitedResourcesCreated;
    dispatch_queue_t _dispatchQueue;
    NSCondition *_semaphore;
    NSInteger _workIndex;
    id <NSLocking> _workIndexLock;
    NSInteger _nextCompletionWorkIndex;
    NSMutableDictionary *_completionBlocks;
    NSCondition *_pauseCondition; // Protects access to _state, and notified threads waiting for the state to change from paused to running when that change occurs.
    AJRQueueState _state;
}

- (id)initWithLimitedResourceCreationBlock:(AJRLimitedResourceCreationBlock)creationBlock {
    if ((self = [super init])) {
        _dispatchQueue = dispatch_queue_create("AJRLimitResourceQueue", DISPATCH_QUEUE_CONCURRENT);
        _semaphore = [[NSCondition alloc] init];
        _limitedResourceCreationBlock = creationBlock;
        _limitedResources = [NSMutableArray array];
        _completionBlocks = [NSMutableDictionary dictionary];
        _completionQueue = dispatch_get_main_queue();
        _maxResourceCount = 10;
        _workIndex = 0;
        _workIndexLock = [[NSLock alloc] init];
        _pauseCondition = [[NSCondition alloc] init];
        _state = AJRQueueStateRunning;
    }
    return self;
}

#pragma mark - Work

- (void)performBlock:(AJRWorkBlock)block withCompletionBlock:(AJRWorkCompletionBlock)completionBlock {
    [self performBlock:block orBlockWithLimitedResource:nil completionBlock:completionBlock];
}

- (void)performLimitedResourceBlock:(AJRLimitedResourceWorkBlock)block withCompletionBlock:(AJRWorkCompletionBlock)completionBlock {
    [self performBlock:nil orBlockWithLimitedResource:block completionBlock:completionBlock];
}

/*! Asynchronously performs the work in block with a provided limited resource and then calls completion block. Completion blocks will be called in the order the work blocks are submitted. */
- (void)performBlock:(AJRWorkBlock)voidWork orBlockWithLimitedResource:(AJRLimitedResourceWorkBlock)resourceWork completionBlock:(AJRWorkCompletionBlock)completionBlock {
    if (_maxResourceCount == 1) {
        id limitedResource = [_limitedResources firstObject];
        id results = nil;

        if (limitedResource == nil) {
            NSError *localError = nil;
            limitedResource = _limitedResourceCreationBlock(&localError);
            if (limitedResource) {
                [_limitedResources addObject:limitedResource];
            } else {
                AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelError, @"error creating resource: %@", [localError localizedDescription]);
                abort();
            }
        }
        
        @try {
            if (resourceWork) {
                results = resourceWork(limitedResource);
            } else if (voidWork) {
                results = voidWork();
            }
        } @catch (NSException *localException) {
            AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelError, @"Exception while performing work: %@", [localException description]);
        }

        completionBlock(results);
    } else {
        NSInteger localWorkIndex;
        
        // Get a local work index. This controls the order in which completion blocks will be called. This is effectively a serialized job identifier.
        [_workIndexLock lock];
        localWorkIndex = _workIndex++;
        [_workIndexLock unlock];
        
        dispatch_async(_dispatchQueue, ^{
            id limitedResource = nil;
            id results = nil;
            
            [self->_semaphore lock];
            
            AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelDebug, @"(%ld) Queued %@work block", (long)localWorkIndex, resourceWork ? @"limited resource " : @"");

            // First, get a limited resource, assuming the block we were passed was a limited resource block.
            if (resourceWork) {
                // We need a limited resource
                do {
                    // Do we have any created, ready to go?
                    if ([self->_limitedResources count] == 0) {
                        // No, then have we already created the max amount?
                        if (self->_limitedResourcesCreated < self->_maxResourceCount) {
                            // We haven't created the max amount, yet, so we'll go ahead and create one.
                            
                            // First, increment _limitedResourcesCreated
                            self->_limitedResourcesCreated++;
                            
                            // And now that we've done that, release our lock, since resource creation can be time consuming.
                            [self->_semaphore unlock];
                            
                            // Attempt to create the resource.
                            NSError *localError;
                            limitedResource = self->_limitedResourceCreationBlock(&localError);
                            if (limitedResource != nil) {
                                AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelDebug, @"(%ld) Created resource: %@", (long)localWorkIndex, limitedResource);
                            } else {
                                // Just abort on error for now. We should do something nicer here.
                                AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelError, @"(%ld) Couldn't create resource: %@", (long)localWorkIndex, [localError localizedDescription]);
                                abort();
                            }
                        } else {
                            // We've created the maximum number of resources we can create, so we have to wait for one to become available.
                            AJRPrintf(@"*** Waiting ***\n");
                            [self->_semaphore wait];
                        }
                    } else {
                        // We have some, so take the last object. We could take any, but the last one is the least expensive to remove, so take it.
                        AJRPrintf(@"*** Taking a Resource  ***\n");
                        limitedResource = [self->_limitedResources lastObject];
                        [self->_limitedResources removeLastObject];
                        // We got a resource, so release the lock
                        [self->_semaphore unlock];
                    }
                    // This is done in a while loop, because we might not be the thread that gets a resource.
                } while (limitedResource == nil);
            } else {
                // We didn't need a special resource, so release the lock;
                [self->_semaphore unlock];
            }
            
            // Wait, if we're paused
            [self->_pauseCondition lock];
            while (self->_state == AJRQueueStatePaused) {
                [self->_pauseCondition wait];
            }
            [self->_pauseCondition unlock];
            
            // Now that we have a limited resource, we can allow our block to do its work.
            @try {
                if (resourceWork) {
                    results = resourceWork(limitedResource);
                } else if (voidWork) {
                    results = voidWork();
                }
            } @catch (NSException *localException) {
                AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelError, @"(%ld) Exception while performing work: %@", (long)localWorkIndex, [localException description]);
            }
            
            // Our job is complete, so we can give back the limit resource we're using.
            [self->_semaphore lock];
            // We done with the limited resource, so give it back immediately, assuming we have one. This will allow other threads to unblock the quickest.
            if (limitedResource) {
                AJRPrintf(@"*** Giving back ***\n");
                // Give back the limit resource, assuming we created one.
                [self->_limitedResources addObject:limitedResource];
                // Signal anyone who's waiting for a limited resource.
                [self->_semaphore broadcast];
            }
            
            // And put our completion block information into the dictionary tracking the completion blocks, now that we're done.
            AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelDebug, @"(%ld) completionBlock: %@, results: %@", (long)localWorkIndex, completionBlock, results);
            if (results) {
                [self->_completionBlocks setObject:@{@"block":completionBlock, @"results":results} forKey:@(localWorkIndex)];
            } else {
                // And queue our completion block.
                [self->_completionBlocks setObject:@{@"block":completionBlock} forKey:@(localWorkIndex)];
            }
            
            // See if we should submit our completion block
            if (self->_nextCompletionWorkIndex == localWorkIndex) {
                NSDictionary *dictionary;
                
                // We're going to loop until _nextCompletionWorkIndex doesn't produce a completion block. Effectively, we'll drain as many completion blocks as possible.
                while ((dictionary = [self->_completionBlocks objectForKey:@(self->_nextCompletionWorkIndex)]) != nil) {
                    //NSUInteger capturedValue = _nextCompletionWorkIndex;
                    dispatch_async(self->_completionQueue, ^{
                        AJRWorkCompletionBlock completionBlockToExecute = dictionary[@"block"];
                        id results = dictionary[@"results"];
                        @try {
                            AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelDebug, @"(%ld) completing work: completionBlock: %@, results: %@", (long)localWorkIndex, completionBlockToExecute, results);
                            completionBlockToExecute(results);
                        } @catch (NSException *exception) {
                            AJRLog(AJROrderedCompletionQueueDomain, AJRLogLevelError, @"(%ld) Exception while calling completion block for limited resource: %@", (long)localWorkIndex, [exception description]);
                        }
                    });
                    [self->_completionBlocks removeObjectForKey:@(self->_nextCompletionWorkIndex)];
                    // Increment this to indicate we can complete the next block.
                    self->_nextCompletionWorkIndex++;
                }
            }
            // And release the lock.
            [self->_semaphore unlock];
        });
    }
}

#pragma mark - Controls

- (AJRQueueState)state {
    return _state;
}

- (void)pause {
    [_pauseCondition lock];
    _state = AJRQueueStatePaused;
    [_pauseCondition unlock];
}

- (void)resume {
    [_pauseCondition lock];
    if (_state == AJRQueueStatePaused) {
        [_pauseCondition broadcast];
    }
    [_pauseCondition unlock];
}

@end
