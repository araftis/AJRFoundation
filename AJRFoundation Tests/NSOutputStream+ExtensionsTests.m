/*
 NSOutputStream+ExtensionsTests.m
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
    NSError *localError = nil;
    bytesWritten = [outputStream writeUnicodeBOM];
    XCTAssert(bytesWritten >= 0);
    XCTAssert([outputStream writeIndent:1 width:4 error:&localError]);
    XCTAssert(localError == nil, @"Expected no error.");
    [outputStream writeString:@"<-- tabs\n"];
    bytesWritten = [outputStream writeIndent:30 width:4 error:NULL];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    [outputStream writeString:@"<-- tabs\n"];
    bytesWritten = [outputStream writeString:@"test\n" error:NULL];
    XCTAssert(bytesWritten > 0, "wrote: %d", (int)bytesWritten);
    bytesWritten = [outputStream writeFormat:@"test: %d\n", 1];
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
    XCTAssert([result isEqualToString:expectedResult], @"Expected: %@, got: %@", expectedResult, result);
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
