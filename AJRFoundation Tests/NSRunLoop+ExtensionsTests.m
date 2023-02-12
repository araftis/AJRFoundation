/*
 NSRunLoop+ExtensionsTests.m
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
