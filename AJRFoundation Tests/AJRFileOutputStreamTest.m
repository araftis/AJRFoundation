
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
