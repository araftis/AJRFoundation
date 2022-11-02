/*
 AJRGate.h
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

@interface AJRGate : NSObject

/*!
 Creates a new gate, ready for use. A newly created gate is initially closed.
 
 In many ways a gate is a fancy wrapper around a condition, but it makes block a collection of threads easier when you just want to be able to pause/resume that group of threads.
*/
+ (AJRGate *)gate;
- (id)init;

/*!
 Waits forever for the gate to open. If the thread is interrupted, then an InterruptedException is thrown and the Gate become invalid. By invalid, all future attempts to wait for the gate will just re-throw the interrupted exception.
 */
- (void)wait;

/*!
 Waits on the gate for the specified period of time.  If the thread is interrupted, then an InterruptedException is thrown and the Gate become invalid. By invalid, all future attempts to wait for the gate will just re-throw the interrupted exception.
 
 @param timeInterval The amount of time, in milliseconds, to wait.
 
 @return true if the gate is open. You can use this to determin if you continued because the gate was open or if your time just expired.
*/
- (BOOL)waitForTimeInterval:(NSTimeInterval)timeInterval;

/*!
 Waits on the gate until the specific date.  If the thread is interrupted, then an InterruptedException is thrown and the Gate become invalid. By invalid, all future attempts to wait for the gate will just re-throw the interrupted exception.
 
 @param date The date to wait until.
 
 @return true if the gate is open. You can use this to determin if you continued because the gate was open or if your time just expired.
*/
- (BOOL)waitUntilDate:(NSDate *)date;

/*!
 Returns true if the gate is open. This is mostly for informational purposes, since by the time you checked the return value of this method and acted on it, the gate could have transitioned back to closed.

 @return true if the gate is open.
*/
@property (nonatomic,readonly,getter=isOpen) BOOL open;

/*!
 Opens the gate, allowing all threads waiting on the gate to proceed. This also marks the gate as open and sets the count of waiting threads to 0. You can call closeGate() to move the gate back to a closed state. As long as the gate is open, calling waitForGate() will return immediately.
*/
- (void)open;

/*!
 Closes the gate. Once closed, threads will start waiting on the gate again.
 
 @return YES if the gate was actually closed. The gate will not closed if it was previous interrupted or if it's already closed.
*/
- (BOOL)close;

/*!
 Returns the number of threads waiting for the gate to open. Note that this is for informational purposes only, as by the time you do something with the return value, the number of threads waiting may have changed.
 
 @return The number of waiting threads.
 */
@property (nonatomic,readonly) NSUInteger waiting;

@end

NS_ASSUME_NONNULL_END
