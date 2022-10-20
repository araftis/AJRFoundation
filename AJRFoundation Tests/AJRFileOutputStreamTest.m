/*
AJRFileOutputStreamTest.m
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

@interface AJRFileOutputStreamTest : XCTestCase

@end

@implementation AJRFileOutputStreamTest
{
    NSMutableSet<NSString *> *_filesToRemove;
}

- (void)setUp {
    _filesToRemove = [NSMutableSet set];
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    
    for (NSString *file in _filesToRemove) {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    [_filesToRemove removeAllObjects];
}

- (void)queueFileToRemove:(NSString *)file {
    [_filesToRemove addObject:file];
}

- (void)testBasicFileIO {
    NSString *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AJRFileTest1.txt"];
    FILE *file = fopen([filename UTF8String], "w");
    
    XCTAssert(file != NULL, "Failed to open file: %@: %s", filename, strerror(errno));
    if (file) {
        [self queueFileToRemove:filename];
        
        @autoreleasepool {
            AJRFileOutputStream *outputStream = [AJRFileOutputStream outputStreamWithFile:file];
            [outputStream setCloseOnDeallocate:YES];
            [outputStream open];
            if ([outputStream hasSpaceAvailable] && [outputStream streamStatus] == NSStreamStatusOpen) {
                [outputStream writeString:@"This is a test.\n"];
            }
        }
        
        NSString *result = [[NSString alloc] initWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
        XCTAssert(AJREqual(result, @"This is a test.\n"));
    }
}

- (void)testBasicFileDescriptorIO {
    NSString *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AJRFileTest2.txt"];
    int file = open([filename UTF8String], O_CREAT | O_WRONLY);
    
    XCTAssert(file >= 0, "Failed to open file: %@: %s", filename, strerror(errno));
    if (file) {
        [self queueFileToRemove:filename];
        
        @autoreleasepool {
            AJRFileOutputStream *outputStream = [AJRFileOutputStream outputStreamWithFileDescriptor:file];
            [outputStream setCloseOnDeallocate:YES];
            [outputStream open];
            if ([outputStream hasSpaceAvailable] && [outputStream streamStatus] == NSStreamStatusOpen) {
                [outputStream writeString:@"This is a test.\n"];
            }
        }
        
        NSString *result = [[NSString alloc] initWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
        XCTAssert(AJREqual(result, @"This is a test.\n"));
    }
}

- (void)testErrors {
    NSString *filename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AJRFileTest3.txt"];
    FILE *file = fopen([filename UTF8String], "w");
    
    XCTAssert(file != NULL, "Failed to open file: %@: %s", filename, strerror(errno));
    if (file) {
        [self queueFileToRemove:filename];
        
        @autoreleasepool {
            AJRFileOutputStream *outputStream = [AJRFileOutputStream outputStreamWithFile:file];
            [outputStream setCloseOnDeallocate:YES];
            [outputStream open];
            if ([outputStream hasSpaceAvailable] && [outputStream streamStatus] == NSStreamStatusOpen) {
                [outputStream writeString:@"This is a test.\n"];
                [outputStream close];
                XCTAssert([outputStream streamStatus] == NSStreamStatusClosed);
                [outputStream writeString:@"This should be an error.\n"];
                XCTAssert([outputStream streamStatus] == NSStreamStatusError);
                XCTAssert([outputStream streamError] != nil);
            }
        }
        
        NSString *result = [[NSString alloc] initWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
        XCTAssert(AJREqual(result, @"This is a test.\n"));
    }

    filename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AJRFileTest4.txt"];
    file = fopen([filename UTF8String], "w");
    
    XCTAssert(file != NULL, "Failed to open file: %@: %s", filename, strerror(errno));
    if (file) {
        [self queueFileToRemove:filename];
        
        @autoreleasepool {
            AJRFileOutputStream *outputStream = [AJRFileOutputStream outputStreamWithFile:file];
            [outputStream setCloseOnDeallocate:YES];
            [outputStream open];
            if ([outputStream hasSpaceAvailable] && [outputStream streamStatus] == NSStreamStatusOpen) {
                [outputStream writeString:@"This is a test.\n"];
                [outputStream close];
                XCTAssert([outputStream streamStatus] == NSStreamStatusClosed);
                [outputStream open];
                XCTAssert([outputStream streamStatus] == NSStreamStatusError);
                XCTAssert([outputStream streamError] != nil);
            }
        }
        
        NSString *result = [[NSString alloc] initWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
        XCTAssert(AJREqual(result, @"This is a test.\n"));
    }

    // CONTINUING FROM ABOVE! Don't insert other code here.
    file = fopen([filename UTF8String], "r");
    
    XCTAssert(file != NULL, "Failed to open file: %@: %s", filename, strerror(errno));
    if (file) {
        @autoreleasepool {
            AJRFileOutputStream *outputStream = [AJRFileOutputStream outputStreamWithFile:file];
            [outputStream setCloseOnDeallocate:YES];
            [outputStream open];
            if ([outputStream hasSpaceAvailable] && [outputStream streamStatus] == NSStreamStatusOpen) {
                [outputStream writeString:@"This is a test.\n"];
                XCTAssert([outputStream streamStatus] == NSStreamStatusError);
            }
        }
        
        NSString *result = [[NSString alloc] initWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
        XCTAssert(AJREqual(result, @"This is a test.\n"));
    }
}

@end
