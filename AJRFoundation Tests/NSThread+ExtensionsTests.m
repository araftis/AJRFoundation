//
//  NSThread+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/29/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSThread_ExtensionsTests : XCTestCase

@end

@implementation NSThread_ExtensionsTests

- (void)testExample {
    AJRBasicSemaphore *semaphore1 = [AJRBasicSemaphore semaphore];
    AJRBasicSemaphore *semaphore2 = [AJRBasicSemaphore semaphore];

    __block BOOL done = NO;
    __block NSThread *thread = nil;
    [NSThread detachNewThreadWithBlock:^{
        thread = [NSThread currentThread];
        [semaphore1 signal];
        while (!done) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        }
        AJRPrintf(@"done!\n");
    }];
    
    [[NSRunLoop currentRunLoop] spinRunLoopInMode:NSDefaultRunLoopMode waitingForSemaphore:semaphore1];

    XCTAssert(thread != nil);
    if (thread != nil) {
        // We'll deadlock if this is nil.
        
        // Test async waiting
        AJRPrintf(@"dispatch!\n");
        [thread performAsyncBlock:^{
            AJRPrintf(@"signal 2\n");
            [semaphore2 signal];
        }];
        AJRPrintf(@"wait 2\n");
        [[NSRunLoop currentRunLoop] spinRunLoopInMode:NSDefaultRunLoopMode waitingForSemaphore:semaphore2];

        // Test sync waiting.
        __block BOOL testBoolean = NO;
        [thread performSyncBlock:^{
            testBoolean = YES;
        }];
        XCTAssert(testBoolean);
        
        // Test errors
        NSOutputStream *output = [NSOutputStream outputStreamToMemory];
        AJRLogSetOutputStream(output, AJRLogLevelWarning);
        [thread performSyncBlock:^{
            @throw [NSException exceptionWithName:@"Test" reason:@"Testing" userInfo:nil];
        }];
        XCTAssert([[output ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] rangeOfString:@"An error occured while performing block on thread"].location != NSNotFound);
        AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    }
    
    done = YES; // Tell our helper thread above that it can exit.
}

@end
