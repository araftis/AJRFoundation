/*
 NSThread+ExtensionsTests.m
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
