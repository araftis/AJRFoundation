/*!
 @header NSRunLoop+Extensions.h
 @discussion Useful utility methods on NSRunLoop.
 @author A.J. Raftis
 @copyright 2008 A.J. Raftis. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <AJRFoundation/AJRSemaphores.h>

/*!
 If queue is the main queue, then the block is scheduled to run on the main thread's run loop. Otherwise, the block is dispatched asynchronously to the onto the main thread.
 
 @param queue The queue on which to execute the provided block.
 @param block The block to execute.
 */
extern void AJRAsyncPerformBlock(dispatch_queue_t queue, dispatch_block_t block);

/*!
 @category NSRunLoop (Extensions)
 @discussion Adds a useful convenience method to pinging the run loop.
 */
@interface NSRunLoop (Extensions)

/*!
 @discussion This causes the run loop to process all outstanding events as though it were idle. These include delayed notifications, timers, screen updates, distributed object responses, and other events enqued or waiting on the run loop.
 */
- (void)ping;

- (void)spinRunLoopInMode:(NSRunLoopMode)mode waitingForSemaphore:(id <AJRSemaphore>)semaphore;
- (void)spinRunLoopInMode:(NSRunLoopMode)mode waitingForSemaphore:(id <AJRSemaphore>)semaphore timeout:(NSTimeInterval)timeout;

@end
