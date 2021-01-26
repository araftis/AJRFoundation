//
//  NSOutputStreamTest.m
//  AJRFoundation Tests
//
//  Created by A.J. Raftis on 6/3/18.
//

#import <AJRFoundation/AJRFoundation.h>
#import <XCTest/XCTest.h>

@interface NSOutputStreamTest : XCTestCase

@end

@implementation NSOutputStreamTest

static NSString * const expectedResult = @"    <-- tabs\n"
                                         @"                                                                                                                        <-- tabs\n"
                                         @"test\n"
                                         @"test: 1\n"
                                         @"test\n"
                                         @"test: 2\n";

- (void)_testWithEncoding:(NSStringEncoding)encoding {
    NSOutputStream *outputStream;
    
    outputStream = [NSOutputStream outputStreamToMemory];
    if (encoding != NSUTF8StringEncoding) {
        [outputStream setEncoding:encoding];
    }
    
    [outputStream open];
    
    NSInteger bytesWritten = 0;
    bytesWritten = [outputStream writeUnicodeBOM];
    XCTAssert(bytesWritten >= 0);
    bytesWritten = [outputStream writeIndent:1 width:4];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    [outputStream writeString:@"<-- tabs\n"];
    bytesWritten = [outputStream writeIndent:30 width:4];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    [outputStream writeString:@"<-- tabs\n"];
    bytesWritten = [outputStream writeCString:"test\n"];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    bytesWritten = [outputStream writeCFormat:"test: %d\n", 1];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    bytesWritten = [outputStream writeString:@"test\n"];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    bytesWritten = [outputStream writeFormat:@"test: %d\n", 2];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    
    NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    NSString *result = [[NSString alloc] initWithData:data encoding:encoding];
    
    NSStringEncoding detected = [NSString stringEncodingForData:data encodingOptions:nil convertedString:&result usedLossyConversion:NULL];
    // Work around for an apparent Foundation bug
    if (detected == NSUTF32BigEndianStringEncoding && [result characterAtIndex:0] == 0xFEFF) {
        result = [result substringFromIndex:1];
    }
    
    AJRPrintf(@"===== Test with encoding: %lu =====\n", (unsigned long)encoding);
    AJRPrintf(@"%@\n", result);
    XCTAssert([result isEqualToString:expectedResult]);
    if (![result isEqualToString:expectedResult]) {
        AJRPrintf(@"encoding: %lu, detected: %lu\n", encoding, detected);
        [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/tmp/1.txt" atomically:NO];
        [[expectedResult dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/tmp/2.txt" atomically:NO];
    }
    
    [outputStream close];
}

- (void)testExample {
    [self _testWithEncoding:NSUTF16StringEncoding];
    [self _testWithEncoding:NSUTF16BigEndianStringEncoding];
    [self _testWithEncoding:NSUTF16LittleEndianStringEncoding];
    [self _testWithEncoding:NSUTF32StringEncoding];
    [self _testWithEncoding:NSUTF32BigEndianStringEncoding];
    [self _testWithEncoding:NSUTF32LittleEndianStringEncoding];
    [self _testWithEncoding:NSUTF8StringEncoding];
}

- (void)testEncodings {
    // We test most encoding stuff above, but we still want to test resetting the encoding.
    NSError *localError;
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    XCTAssert(output != nil && localError == nil);
    
    output.encoding = NSUTF32BigEndianStringEncoding;
    XCTAssert(output.encoding == NSUTF32BigEndianStringEncoding);
    XCTAssert([output.encodingName isEqualToString:@"utf-32be"]);
    output.encoding = 0;
    XCTAssert(output.encoding == NSUTF8StringEncoding);
    XCTAssert([output.encodingName isEqualToString:@"utf-8"]);
    
    [output close];
}

- (void)testWritingCharacters {
    NSError *localError;
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    [output open];
    XCTAssert(output.streamStatus == NSStreamStatusOpen);
    
    size_t bytesWritten;
    XCTAssert([output writeCharacter:0x00000041 bytesWritten:&bytesWritten error:&localError]); // A
    XCTAssert(localError == nil);
    XCTAssert(bytesWritten == 1);
    XCTAssert([output writeCharacter:0x000000C1 bytesWritten:&bytesWritten error:&localError]); // Á
    XCTAssert(localError == nil);
    XCTAssert(bytesWritten == 2);
    XCTAssert([output writeCharacter:0x00000226 bytesWritten:&bytesWritten error:&localError]); // Ȧ
    XCTAssert(localError == nil);
    XCTAssert(bytesWritten == 2);
    XCTAssert([output writeCharacter:0x0000265E bytesWritten:&bytesWritten error:&localError]); // ♞
    XCTAssert(localError == nil);
    XCTAssert(bytesWritten == 3);
    XCTAssert([output writeCharacter:0x0001F600 bytesWritten:&bytesWritten error:&localError]); // 😀
    XCTAssert(localError == nil);
    XCTAssert(bytesWritten == 4);
    XCTAssert(![output writeCharacter:0xCCDDEEFF bytesWritten:&bytesWritten error:&localError]); // Illegal
    XCTAssert(localError != nil);
    
    [output close];
    
    // Let's go ahead and see if we produced exactly what we expected.
    NSString *string = [output ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([string isEqualToString:@"AÁȦ♞😀"]);
}

@end
