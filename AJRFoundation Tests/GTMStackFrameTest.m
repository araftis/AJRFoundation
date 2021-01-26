//
//  GTMStackFrameTest.m
//  AJRFoundation
//
//  Created by Alex Raftis on 1/27/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import <AJRFoundation/GTMStackFrame.h>
#import <AJRFoundation/GTMStackTrace.h>

#import <AJRTestFoundation/AJRTestCase.h>

@interface GTMStackFrameTest : AJRTestCase

@end

@implementation GTMStackFrameTest

- (void)testStackTrace
{
    [self print:@"stack trace = %@\n", [NSThread stackTrace]];
    [self print:@"stack trace = %@\n", [[NSThread stackTrace] valueForKey:@"displaySymbol"]];
}

- (void)testExceptionStackTrace
{
    NSException    *exception = [[NSException alloc] initWithName:@"Test" reason:@"Because we want to fail" userInfo:nil];
    
    @try {
        @throw exception;
    } @catch (NSException *newException) {
        [self print:@"stack trace = %@\n", [newException stackTrace]];
    }
}

@end
