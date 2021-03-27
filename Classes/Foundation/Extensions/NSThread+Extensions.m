
#import "NSThread+Extensions.h"

#import "AJRLogging.h"

@implementation NSThread (AJRFoundationExtensions)

- (void)_ajr_performBlock:(void (^)(void))block {
    @try {
        block();
    } @catch (NSException *exception) {
        AJRLog(nil, AJRLogLevelWarning, @"An error occured while performing block on thread '%@': %@", self, exception);
        AJRLog(nil, AJRLogLevelWarning, @"%@\n", NSThread.callStackSymbols);
    }
}

- (void)performAsyncBlock:(void (^)(void))block {
    [self performSelector:@selector(_ajr_performBlock:) onThread:self withObject:block waitUntilDone:NO];
}

- (void)performSyncBlock:(void (^)(void))block {
    [self performSelector:@selector(_ajr_performBlock:) onThread:self withObject:block waitUntilDone:YES];
}

@end
