/*
 AJRLoggingTests.m
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

@interface AJRLoggingTest : XCTestCase

@end

@implementation AJRLoggingTest

- (void)testBasicLogging
{
    AJRLogSetGlobalLogLevel(AJRLogLevelInfo);
    AJRLogResetCounts();

    AJRLog(nil, AJRLogLevelDefault, @"Test Log Global/Generic\n");
    AJRLogEmergency(@"Test Log Emergency\n");
    AJRLogAlert(@"Test Log Alert\n");
    AJRLogCritical(@"Test Log Critical\n");
    AJRLogError(@"Test Log Error\n");
    AJRLogWarning(@"Test Log Warning\n");
    AJRLogNotice(@"Test Log Notice\n");
    AJRLogInfo(@"Test Log Info");
    AJRLogDebug(@"Test Log Debug");

    XCTAssert(AJRLogGetDefaultCount() == 1, @"Alert count is %ld, not 1", AJRLogGetDefaultCount());
    XCTAssert(AJRLogGetEmergencyCount() == 1, @"Alert count is %ld, not 1", AJRLogGetEmergencyCount());
    XCTAssert(AJRLogGetAlertCount() == 1, @"Alert count is %ld, not 1", AJRLogGetAlertCount());
    XCTAssert(AJRLogGetCriticalCount() == 1, @"Critical count is %ld, not 1", AJRLogGetCriticalCount());
    XCTAssert(AJRLogGetErrorCount() == 1, @"Error count is %ld, not 1", AJRLogGetErrorCount());
    XCTAssert(AJRLogGetWarningCount() == 1, @"Warning count is %ld, not 1", AJRLogGetWarningCount());
    XCTAssert(AJRLogGetNoticeCount() == 1, @"Notice count is %ld, not 1", AJRLogGetNoticeCount());
    XCTAssert(AJRLogGetInfoCount() == 1, @"Info count is %ld, not 1", AJRLogGetInfoCount());
    XCTAssert(AJRLogGetDebugCount() == 0, @"Debug count is %ld, not 0", AJRLogGetDebugCount());
    
    AJRLogSetGlobalLogLevel(AJRLogLevelDebug);
    XCTAssert(AJRLogGetGlobalLogLevel() == AJRLogLevelDebug);
    AJRLogDebug(@"Test Log Debug 2\n");

    XCTAssert(AJRLogGetDebugCount() == 1, @"Debug count is %ld, not 1", AJRLogGetDebugCount());
}

// Declared in AJRLogging.m
NSDictionary<NSNumber *, NSString *> *AJRGetLogLevelStrings(void);

- (void)testLogStrings {
    NSDictionary<NSNumber *, NSString *> *levels = AJRGetLogLevelStrings();
    
    for (NSNumber *level in [levels keyEnumerator]) {
        if ([level integerValue] == AJRLogLevelDefault) continue;
        NSString *levelString = [levels objectForKey:level];
        AJRLogLevel logLevel = AJRLogLevelFromString(levelString);
        XCTAssert(logLevel != AJRLogLevelDefault);
        XCTAssert([levelString isEqualToString:AJRStringFromLogLevel(logLevel)]);
    }
    
    XCTAssert(AJRLogLevelFromString(@"incorrect") == AJRLogLevelDefault);
    XCTAssert(AJRStringFromLogLevel((AJRLogLevel)0xDEADBEEF) == nil);
}

static void AJRLoggingTestFunction(void) {
    // Makes sure our macros work from a function.
    AJRLogDebug(@"Debug test.");
}

- (void)testStreamRedirects {
    NSOutputStream *outputStreamDebug = [NSOutputStream outputStreamToMemory];
    NSOutputStream *outputStreamGlobal = [NSOutputStream outputStreamToMemory];
    
    AJRLogSetUsesSyslog(NO); // Because we're testing global, and the default "global" stream is syslog.
    XCTAssert(AJRLogGetUsesSyslog() == NO, @"Call to AJRSetLogUsingSyslog() failed.");
    AJRLogSetGlobalLogLevel(AJRLogLevelDebug);
    AJRLogSetOutputStream(outputStreamGlobal, AJRLogLevelDefault);
    AJRLogSetOutputStream(outputStreamDebug, AJRLogLevelDebug);
    
    AJRLog(nil, AJRLogLevelInfo, @"Global test.");
    AJRLoggingTestFunction();
    
    NSString *string = [outputStreamDebug ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([string hasSuffix:@"Debug test.\n"]);
    string = [outputStreamGlobal ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([string hasSuffix:@"Global test.\n"]);
    
    AJRLogSetOutputStream(nil, AJRLogLevelDefault);
    AJRLogSetOutputStream(nil, AJRLogLevelDebug);
}

- (void)testDomains {
    NSString *domain = @"Test";
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    
    AJRLogSetOutputStream(stream, AJRLogLevelInfo);
    AJRLogSetLogLevel(AJRLogLevelInfo, domain);
    AJRLog(@"Test", AJRLogLevelInfo, @"First line.");
    AJRLogSetLogLevel(AJRLogLevelNotice, domain);
    AJRLog(@"Test", AJRLogLevelInfo, @"Second line.");
    AJRLogSetLogLevel(AJRLogLevelDefault, @"Test");
    AJRLog(@"Test", AJRLogLevelInfo, @"Third line.");
    AJRLog(@"Test", AJRLogLevelDebug, @"Forth line.");

    NSString *string = [stream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([string rangeOfString:@"First line."].location != NSNotFound);
    XCTAssert([string rangeOfString:@"Second line."].location == NSNotFound);
    XCTAssert([string rangeOfString:@"Third line."].location != NSNotFound);
    XCTAssert([string rangeOfString:@"Forth line."].location == NSNotFound);
    
    AJRLogSetOutputStream(nil, AJRLogLevelInfo);
}

@end
