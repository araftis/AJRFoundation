/*
 NSRunLoop+Extensions.m
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

#import "NSRunLoop+Extensions.h"

#import "AJRLogging.h"

#import <libkern/OSAtomic.h>
#import <stdatomic.h>

void AJRAsyncPerformBlock(dispatch_queue_t queue, dispatch_block_t block) {
    if (queue == dispatch_get_main_queue()) {
        CFRunLoopRef mainRunLoop = CFRunLoopGetMain();
        CFRunLoopPerformBlock(mainRunLoop, kCFRunLoopCommonModes, ^{
            @try {
                block();
            } @catch (NSException *exception) {
                NSUncaughtExceptionHandler *handler = NSGetUncaughtExceptionHandler();
                if (handler != NULL) {
                    handler(exception);
                } else {
                    AJRLog(nil, AJRLogLevelError, @"Unhandled exception: %@", exception);
                    AJRLog(nil, AJRLogLevelError, @"Backtrace: %@", [exception callStackSymbols]);
                }
            } @finally {
                CFRunLoopStop(mainRunLoop);
            }
        });
        CFRunLoopWakeUp(mainRunLoop);
    } else {
        dispatch_async(queue, block);
    }
}

@implementation NSRunLoop (Extensions)

- (void)ping {
    [self runUntilDate:[NSDate date]];
}

static CFRunLoopSourceContext AJRRunLoopSourceContextWithPerformFunction(void (*function)(void *)) {
    return (CFRunLoopSourceContext) {
        .version = 0,
        .info = NULL,
        .retain = NULL,
        .release = NULL,
        .copyDescription = NULL,
        .equal = NULL,
        .hash = NULL,
        .schedule = NULL,
        .perform = function
    };
}

static void emptySignal(void *info) {
    // This signale does nothing other than wake up the blocking thread
}

- (void)spinRunLoopInMode:(NSRunLoopMode)mode whileBlockExecutesConcurrently:(void (^)(void))block {
    CFRunLoopSourceContext signalContext = AJRRunLoopSourceContextWithPerformFunction(emptySignal);
    CFRunLoopSourceRef signalSource = CFRunLoopSourceCreate(NULL, 50, &signalContext);
    CFRunLoopRef cfRunLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFStringRef cfRunLoopMode = CFBridgingRetain(mode);
    CFRunLoopAddSource(cfRunLoop, signalSource, cfRunLoopMode);
    
    __block _Atomic(int32_t) signal = 0;
    int32_t initialGeneration = signal;
    AJRAsyncPerformBlock(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        block();
        atomic_fetch_add(&signal, 1);
        CFRunLoopSourceSignal(signalSource);
        CFRunLoopWakeUp(cfRunLoop);
    });
    do {
        @autoreleasepool {
            CFRunLoopRunInMode(cfRunLoopMode, 60 * 60 * 5, TRUE);
        }
    } while (atomic_fetch_add(&signal, 0) == initialGeneration);

    CFRunLoopRemoveSource(cfRunLoop, signalSource, cfRunLoopMode);
    CFRunLoopSourceInvalidate(signalSource);
    CFRelease(signalSource);
    CFRelease(cfRunLoopMode);
}

- (void)spinRunLoopInMode:(NSRunLoopMode)mode waitingForSemaphore:(id <AJRSemaphore>)semaphore {
    [self spinRunLoopInMode:mode waitingForSemaphore:semaphore timeout:[[NSDate distantFuture] timeIntervalSinceNow]];
}

- (void)spinRunLoopInMode:(NSRunLoopMode)mode waitingForSemaphore:(id <AJRSemaphore>)semaphore timeout:(NSTimeInterval)timeout {
    [self spinRunLoopInMode:mode whileBlockExecutesConcurrently:^{
        BOOL result = [semaphore waitWithTimeout:timeout];
        AJRLog(nil, AJRLogLevelDebug, @"result: %B", result);
    }];
}

@end

