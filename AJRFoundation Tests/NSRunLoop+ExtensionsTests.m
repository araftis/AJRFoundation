//
//  NSRunLoop+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/23/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSRunLoop_ExtensionsTests : XCTestCase

@end

@implementation NSRunLoop_ExtensionsTests

- (void)testSpinning {
    AJRBasicSemaphore *semaphore = [AJRBasicSemaphore semaphore];
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:.25]];
        [semaphore signal];
    });
    
    [[NSRunLoop currentRunLoop] spinRunLoopInMode:NSDefaultRunLoopMode waitingForSemaphore:semaphore];
    NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate];
    
    XCTAssert((stop - start) > 0.25, @"expected to wait at least .25 seconds, but only waited %.3f", stop - start);
    
    // Test a quick ping of the run loop
    [NSRunLoop.currentRunLoop ping];
}

static NSInteger fileGlobalValue = 0;
static void AJRTestHandler(NSException *exception) {
    fileGlobalValue = 2;
}

- (void)testRunningAsync {
    __block NSInteger value = 0;
    
    AJRAsyncPerformBlock(dispatch_get_main_queue(), ^{
        value = 1;
    });
    
    // Value should be zero, beacuse while scheduled, the run loop hasn't run.
    XCTAssert(value == 0);
    // Now run the runloop for one cycle.
    [NSRunLoop.currentRunLoop ping];
    // And our value should now be one.
    XCTAssert(value == 1);
    
    // Test we handling failture with an exception handler in place.
    NSSetUncaughtExceptionHandler(AJRTestHandler);
    fileGlobalValue = 0;
    AJRAsyncPerformBlock(dispatch_get_main_queue(), ^{
        fileGlobalValue = 1;
        @throw [NSException exceptionWithName:@"AJRTest" reason:@"To fail during a test." userInfo:nil];
    });
    [NSRunLoop.currentRunLoop ping];
    XCTAssert(fileGlobalValue == 2);
    NSSetUncaughtExceptionHandler(NULL);
    
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(stream, AJRLogLevelError);
    // And test we handle failture without a test in place.
    fileGlobalValue = 0;
    AJRAsyncPerformBlock(dispatch_get_main_queue(), ^{
        fileGlobalValue = 1;
        @throw [NSException exceptionWithName:@"AJRTest" reason:@"To file during a test." userInfo:nil];
    });
    [NSRunLoop.currentRunLoop ping];
    XCTAssert(fileGlobalValue == 1);
    XCTAssert([[stream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] hasPrefix:@"<ERROR>: Unhandled exception: To file during a test."]);
    AJRLogSetOutputStream(nil, AJRLogLevelError);
}

@end
