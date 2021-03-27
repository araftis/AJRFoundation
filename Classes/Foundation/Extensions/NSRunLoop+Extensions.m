
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
    /// This signale does nothing other than wake up the blocking thread
}

- (void)spinRunLoopInMode:(NSRunLoopMode)mode whileBlockExecutesConcurrently:(void (^)(void))block {
    CFRunLoopSourceContext signalContext = AJRRunLoopSourceContextWithPerformFunction(emptySignal);
    CFRunLoopSourceRef signalSource = CFRunLoopSourceCreate(NULL, 50, &signalContext); /// NSTask uses a similar techique and passes 50 for the mode, which seems completely arbitrary.
    CFRunLoopRef cfRunLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFStringRef cfRunLoopMode = CFBridgingRetain(mode);
    CFRunLoopAddSource(cfRunLoop, signalSource, cfRunLoopMode);
    
    //__block int32_t signal = 0;
    __block _Atomic(int32_t) signal = 0;
    int32_t initialGeneration = signal;
    AJRAsyncPerformBlock(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        block();
        atomic_fetch_add(&signal, 1);
        //OSAtomicIncrement32Barrier(&signal);
        CFRunLoopSourceSignal(signalSource);
        CFRunLoopWakeUp(cfRunLoop);
    });
    do {
        @autoreleasepool {
            CFRunLoopRunInMode(cfRunLoopMode, 60 * 60 * 5, TRUE);
        }
    } while (atomic_fetch_add(&signal, 0) == initialGeneration);
    //} while (OSAtomicAdd32Barrier(0, (int32_t *)&signal) == initialGeneration);
    
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

