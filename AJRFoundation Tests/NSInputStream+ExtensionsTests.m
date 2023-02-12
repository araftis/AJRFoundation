/*
 NSInputStream+ExtensionsTests.m
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

@interface NSInputStream_ExtensionsTests : XCTestCase

@end

@implementation NSInputStream_ExtensionsTests

- (void)testPrimitiveReadingAndWriting {
    NSError *localError;
    NSOutputStream *output;
    uint8_t buffer[20] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13 };
    
    output = [NSOutputStream outputStreamToMemory];
    XCTAssert(output != nil && localError == nil);
    [output open];
    XCTAssert(output.streamStatus == NSStreamStatusOpen);
    
    size_t bytesWritten = 0;
    XCTAssert([output writeBytes:buffer length:sizeof(buffer) / sizeof(uint8_t) bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(bytesWritten == sizeof(buffer) / sizeof(uint8_t));
    XCTAssert(localError == nil);
    
    [output close];
    
    // Make sure we generate an error.
    XCTAssert(![output writeBytes:buffer length:sizeof(buffer) / sizeof(uint8_t) bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(localError != nil);
    
    NSInputStream *input = [NSInputStream inputStreamWithData:[output ajr_data]];
    XCTAssert(output != nil);
    [input open];
    XCTAssert(input.streamStatus == NSStreamStatusOpen);
    
    uint8_t readBuffer[50];
    size_t bytesRead;
    XCTAssert([input readBytes:readBuffer length:10 bytesRead:&bytesRead error:&localError]);
    XCTAssert(bytesRead == 10);
    XCTAssert(localError == nil);
    
    for (NSInteger x = 0; x < 10; x++) {
        XCTAssert(buffer[x] == readBuffer[x], @"Value at index %d wasn't correct.", (int)x);
    }
    
    XCTAssert([input readBytes:readBuffer + 10 length:10 bytesRead:&bytesRead error:&localError]);
    XCTAssert(bytesRead == 10);
    for (NSInteger x = 0; x < 20; x++) {
        XCTAssert(buffer[x] == readBuffer[x], @"Value at index %d wasn't correct.", (int)x);
    }
    
    [input close];
    
    // Force an error.
    XCTAssert(![input readBytes:readBuffer length:10 bytesRead:&bytesRead error:&localError]);
    XCTAssert(localError != nil);
}

- (void)testReadingCharacters {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingCharacters" ofType:@"utf8" inDirectory:@"Test Files"];
    XCTAssert(path);

    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssert(data);

    NSString *original = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    XCTAssert(original);
    
    AJRPrintf(@"original: %@\n", original);
    
    NSInputStream *input = [NSInputStream inputStreamWithData:data];
    XCTAssert(input != nil);
    [input open];
    XCTAssert(input.streamStatus == NSStreamStatusOpen);
    
    NSError *localError = nil;
    uint32_t character;
    NSData *originalData = [original dataUsingEncoding:NSUTF32LittleEndianStringEncoding];
    uint32_t *originalCharacters = (uint32_t *)[originalData bytes];
    
    NSInteger offset = 0;
    while ([input readCharacter:&character error:&localError] > 0) {
        XCTAssert(localError == nil, @"We got an error we didn't expect: %@", localError.localizedDescription);
        XCTAssert(originalCharacters[offset] == character, @"Character at position %d didn't match expected value. Got 0x%x, expected 0x%x", (int)offset, (int)character, (int)originalCharacters[offset]);
        AJRPrintf(@"0x%x == 0x%x, %lc\n", (int)originalCharacters[offset], (int)character, character);
        offset++;
    }
    
    [input close];
    
    // Try to read one more character, which should produce an error, since we closed the file.
    XCTAssert([input readCharacter:&character error:&localError] == (size_t)-1);
    XCTAssert(localError != nil);
}

- (void)testReadingAndWritingDataTypes {
    float testFloatValue = 1234.5678;
    double testDoubleValue = 12345678.12345678;
    NSError *localError;

    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    XCTAssert(output != nil);
    XCTAssert(localError == nil);
    [output open];
    XCTAssert(output.streamStatus == NSStreamStatusOpen);
    
    // Files are big endian by default.
    XCTAssert(output.endianness == AJREndiannessBig);
    
    output.endianness = AJREndiannessLittle;
    XCTAssert([output writeInt8:0x11 error:&localError] && localError == nil);
    XCTAssert([output writeUInt8:0x22 error:&localError] && localError == nil);
    XCTAssert([output writeInt16:0x1122 error:&localError] && localError == nil);
    XCTAssert([output writeUInt16:0x3344 error:&localError] && localError == nil);
    XCTAssert([output writeInt32:0x11223344 error:&localError] && localError == nil);
    XCTAssert([output writeUInt32:0x55667788 error:&localError] && localError == nil);
    XCTAssert([output writeInt64:0x1122334455667788 error:&localError] && localError == nil);
    XCTAssert([output writeUInt64:0x99AABBCCDDEEFF00 error:&localError] && localError == nil);
    
    output.endianness = AJREndiannessBig;
    XCTAssert([output writeInt8:0x11 error:&localError] && localError == nil);
    XCTAssert([output writeUInt8:0x22 error:&localError] && localError == nil);
    XCTAssert([output writeInt16:0x1122 error:&localError] && localError == nil);
    XCTAssert([output writeUInt16:0x3344 error:&localError] && localError == nil);
    XCTAssert([output writeInt32:0x11223344 error:&localError] && localError == nil);
    XCTAssert([output writeUInt32:0x55667788 error:&localError] && localError == nil);
    XCTAssert([output writeInt64:0x1122334455667788 error:&localError] && localError == nil);
    XCTAssert([output writeUInt64:0x99AABBCCDDEEFF00 error:&localError] && localError == nil);
    XCTAssert([output writeInt16:0x1122 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([output writeUInt16:0x3344 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([output writeInt32:0x11223344 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([output writeUInt32:0x55667788 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([output writeInt64:0x1122334455667788 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([output writeUInt64:0x99AABBCCDDEEFF00 endianness:AJREndiannessBig error:&localError] && localError == nil);

    // And write some floating point. These ignore endianness, as floating point numbers have their own machine independent format.
    XCTAssert([output writeFloat:testFloatValue error:&localError] && localError == nil);
    XCTAssert([output writeDouble:testDoubleValue error:&localError] && localError == nil);

    [output close];
    
    // Now lets see if the bytes are in the file, and in the order we expect.
    NSData *data = [output ajr_data];
    const uint8_t *bytes = [data bytes];
    // Check the little endian values first.
    // int8_t in file.
    XCTAssert(bytes[ 0] == 0x11);
    // uint8_t in file.
    XCTAssert(bytes[ 1] == 0x22);
    // int16_t in file.
    XCTAssert(bytes[ 2] == 0x22);
    XCTAssert(bytes[ 3] == 0x11);
    // uint16_t in file.
    XCTAssert(bytes[ 4] == 0x44);
    XCTAssert(bytes[ 5] == 0x33);
    // int32_t in file.
    XCTAssert(bytes[ 6] == 0x44);
    XCTAssert(bytes[ 7] == 0x33);
    XCTAssert(bytes[ 8] == 0x22);
    XCTAssert(bytes[ 9] == 0x11);
    // uint32_t in file.
    XCTAssert(bytes[10] == 0x88);
    XCTAssert(bytes[11] == 0x77);
    XCTAssert(bytes[12] == 0x66);
    XCTAssert(bytes[13] == 0x55);
    // int64_t in file.
    XCTAssert(bytes[14] == 0x88);
    XCTAssert(bytes[15] == 0x77);
    XCTAssert(bytes[16] == 0x66);
    XCTAssert(bytes[17] == 0x55);
    XCTAssert(bytes[18] == 0x44);
    XCTAssert(bytes[19] == 0x33);
    XCTAssert(bytes[20] == 0x22);
    XCTAssert(bytes[21] == 0x11);
    // uint64_t in file.
    XCTAssert(bytes[22] == 0x00);
    XCTAssert(bytes[23] == 0xFF);
    XCTAssert(bytes[24] == 0xEE);
    XCTAssert(bytes[25] == 0xDD);
    XCTAssert(bytes[26] == 0xCC);
    XCTAssert(bytes[27] == 0xBB);
    XCTAssert(bytes[28] == 0xAA);
    XCTAssert(bytes[29] == 0x99);
    // Now check the big endian values first.
    NSInteger bigEndianOffset = 30;
    // int8_t in file.
    XCTAssert(bytes[bigEndianOffset +  0] == 0x11);
    // uint8_t in file.
    XCTAssert(bytes[bigEndianOffset +  1] == 0x22);
    // int16_t in file.
    XCTAssert(bytes[bigEndianOffset +  2] == 0x11);
    XCTAssert(bytes[bigEndianOffset +  3] == 0x22);
    // uint16_t in file.
    XCTAssert(bytes[bigEndianOffset +  4] == 0x33);
    XCTAssert(bytes[bigEndianOffset +  5] == 0x44);
    // int32_t in file.
    XCTAssert(bytes[bigEndianOffset +  6] == 0x11);
    XCTAssert(bytes[bigEndianOffset +  7] == 0x22);
    XCTAssert(bytes[bigEndianOffset +  8] == 0x33);
    XCTAssert(bytes[bigEndianOffset +  9] == 0x44);
    // uint32_t in file.
    XCTAssert(bytes[bigEndianOffset + 10] == 0x55);
    XCTAssert(bytes[bigEndianOffset + 11] == 0x66);
    XCTAssert(bytes[bigEndianOffset + 12] == 0x77);
    XCTAssert(bytes[bigEndianOffset + 13] == 0x88);
    // int64_t in file.
    XCTAssert(bytes[bigEndianOffset + 14] == 0x11);
    XCTAssert(bytes[bigEndianOffset + 15] == 0x22);
    XCTAssert(bytes[bigEndianOffset + 16] == 0x33);
    XCTAssert(bytes[bigEndianOffset + 17] == 0x44);
    XCTAssert(bytes[bigEndianOffset + 18] == 0x55);
    XCTAssert(bytes[bigEndianOffset + 19] == 0x66);
    XCTAssert(bytes[bigEndianOffset + 20] == 0x77);
    XCTAssert(bytes[bigEndianOffset + 21] == 0x88);
    // uint64_t in file.
    XCTAssert(bytes[bigEndianOffset + 22] == 0x99);
    XCTAssert(bytes[bigEndianOffset + 23] == 0xAA);
    XCTAssert(bytes[bigEndianOffset + 24] == 0xBB);
    XCTAssert(bytes[bigEndianOffset + 25] == 0xCC);
    XCTAssert(bytes[bigEndianOffset + 26] == 0xDD);
    XCTAssert(bytes[bigEndianOffset + 27] == 0xEE);
    XCTAssert(bytes[bigEndianOffset + 28] == 0xFF);
    XCTAssert(bytes[bigEndianOffset + 29] == 0x00);
    // int16_t in file.
    XCTAssert(bytes[bigEndianOffset + 30] == 0x11);
    XCTAssert(bytes[bigEndianOffset + 31] == 0x22);
    // uint16_t in file.
    XCTAssert(bytes[bigEndianOffset + 32] == 0x33);
    XCTAssert(bytes[bigEndianOffset + 33] == 0x44);
    // int32_t in file.
    XCTAssert(bytes[bigEndianOffset + 34] == 0x11);
    XCTAssert(bytes[bigEndianOffset + 35] == 0x22);
    XCTAssert(bytes[bigEndianOffset + 36] == 0x33);
    XCTAssert(bytes[bigEndianOffset + 37] == 0x44);
    // uint32_t in file.
    XCTAssert(bytes[bigEndianOffset + 38] == 0x55);
    XCTAssert(bytes[bigEndianOffset + 39] == 0x66);
    XCTAssert(bytes[bigEndianOffset + 40] == 0x77);
    XCTAssert(bytes[bigEndianOffset + 41] == 0x88);
    // int64_t in file.
    XCTAssert(bytes[bigEndianOffset + 42] == 0x11);
    XCTAssert(bytes[bigEndianOffset + 43] == 0x22);
    XCTAssert(bytes[bigEndianOffset + 44] == 0x33);
    XCTAssert(bytes[bigEndianOffset + 45] == 0x44);
    XCTAssert(bytes[bigEndianOffset + 46] == 0x55);
    XCTAssert(bytes[bigEndianOffset + 47] == 0x66);
    XCTAssert(bytes[bigEndianOffset + 48] == 0x77);
    XCTAssert(bytes[bigEndianOffset + 49] == 0x88);
    // uint64_t in file.
    XCTAssert(bytes[bigEndianOffset + 50] == 0x99);
    XCTAssert(bytes[bigEndianOffset + 51] == 0xAA);
    XCTAssert(bytes[bigEndianOffset + 52] == 0xBB);
    XCTAssert(bytes[bigEndianOffset + 53] == 0xCC);
    XCTAssert(bytes[bigEndianOffset + 54] == 0xDD);
    XCTAssert(bytes[bigEndianOffset + 55] == 0xEE);
    XCTAssert(bytes[bigEndianOffset + 56] == 0xFF);
    XCTAssert(bytes[bigEndianOffset + 57] == 0x00);

    // Now that we know the data in the file is valid, let's try reading the values back with our read routines.

    // Types we'll need
    int8_t int8;
    uint8_t uint8;
    int16_t int16;
    uint16_t uint16;
    int32_t int32;
    uint32_t uint32;
    int64_t int64;
    uint64_t uint64;
    float testFloat;
    double testDouble;

    NSInputStream *input = [NSInputStream inputStreamWithData:data];
    input.endianness = AJREndiannessLittle;
    [input open];
    XCTAssert(input.streamStatus == NSStreamStatusOpen);
    // int8_t
    XCTAssert([input readInt8:&int8 error:&localError] && localError == nil);
    XCTAssert(int8 == 0x11);
    XCTAssert([input readUInt8:&uint8 error:&localError] && localError == nil);
    XCTAssert(uint8 == 0x22);
    // int16_t
    XCTAssert([input readInt16:&int16 error:&localError] && localError == nil);
    XCTAssert(int16 == 0x1122);
    XCTAssert([input readUInt16:&uint16 error:&localError] && localError == nil);
    XCTAssert(uint16 == 0x3344);
    // int32_t
    XCTAssert([input readInt32:&int32 error:&localError] && localError == nil);
    XCTAssert(int32 == 0x11223344);
    XCTAssert([input readUInt32:&uint32 error:&localError] && localError == nil);
    XCTAssert(uint32 == 0x55667788);
    // int64_t
    XCTAssert([input readInt64:&int64 error:&localError] && localError == nil);
    XCTAssert(int64 == 0x1122334455667788);
    XCTAssert([input readUInt64:&uint64 error:&localError] && localError == nil);
    XCTAssert(uint64 == 0x99AABBCCDDEEFF00);
    // Now big-endian tests
    input.endianness = AJREndiannessBig;
    // int8_t
    XCTAssert([input readInt8:&int8 error:&localError] && localError == nil);
    XCTAssert(int8 == 0x11);
    XCTAssert([input readUInt8:&uint8 error:&localError] && localError == nil);
    XCTAssert(uint8 == 0x22);
    // int16_t
    XCTAssert([input readInt16:&int16 error:&localError] && localError == nil);
    XCTAssert(int16 == 0x1122);
    XCTAssert([input readUInt16:&uint16 error:&localError] && localError == nil);
    XCTAssert(uint16 == 0x3344);
    // int32_t
    XCTAssert([input readInt32:&int32 error:&localError] && localError == nil);
    XCTAssert(int32 == 0x11223344);
    XCTAssert([input readUInt32:&uint32 error:&localError] && localError == nil);
    XCTAssert(uint32 == 0x55667788);
    // int64_t
    XCTAssert([input readInt64:&int64 error:&localError] && localError == nil);
    XCTAssert(int64 == 0x1122334455667788);
    XCTAssert([input readUInt64:&uint64 error:&localError] && localError == nil);
    XCTAssert(uint64 == 0x99AABBCCDDEEFF00);
    // int16_t
    XCTAssert([input readInt16:&int16 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(int16 == 0x1122);
    XCTAssert([input readUInt16:&uint16 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(uint16 == 0x3344);
    // int32_t
    XCTAssert([input readInt32:&int32 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(int32 == 0x11223344);
    XCTAssert([input readUInt32:&uint32 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(uint32 == 0x55667788);
    // int64_t
    XCTAssert([input readInt64:&int64 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(int64 == 0x1122334455667788);
    XCTAssert([input readUInt64:&uint64 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(uint64 == 0x99AABBCCDDEEFF00);
    // Floating points
    XCTAssert([input readFloat:&testFloat error:&localError] && localError == nil);
    XCTAssert(testFloat == testFloatValue);
    XCTAssert([input readDouble:&testDouble error:&localError] && localError == nil);
    XCTAssert(testDouble == testDoubleValue);

    [input close];
    
    XCTAssert(![input readInt8:&int8 error:&localError] && localError != nil);
    XCTAssert(![input readUInt8:&uint8 error:&localError] && localError != nil);
    // int16_t
    XCTAssert(![input readInt16:&int16 endianness:AJREndiannessBig error:&localError] && localError != nil);
    XCTAssert(![input readUInt16:&uint16 endianness:AJREndiannessBig error:&localError] && localError != nil);
    // int32_t
    XCTAssert(![input readInt32:&int32 endianness:AJREndiannessBig error:&localError] && localError != nil);
    XCTAssert(![input readUInt32:&uint32 endianness:AJREndiannessBig error:&localError] && localError != nil);
    // int64_t
    XCTAssert(![input readInt64:&int64 endianness:AJREndiannessBig error:&localError] && localError != nil);
    XCTAssert(![input readUInt64:&uint64 endianness:AJREndiannessBig error:&localError] && localError != nil);
    // floating point
    XCTAssert(![input readFloat:&testFloat error:&localError] && localError != nil);
    XCTAssert(![input readDouble:&testDouble error:&localError] && localError != nil);
}

- (void)testReadLineNon8BitEncoding {
    NSError *localError;
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    [output open];
    XCTAssert(output.streamStatus == NSStreamStatusOpen);
    
    output.encoding = NSUTF32LittleEndianStringEncoding;
    
    // Make sure nl line endings work.
    XCTAssert([output writeString:@"one\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"two\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"three\n" error:&localError] && localError == nil);
    
    output.encoding = NSUTF32LittleEndianStringEncoding;

    // Also make sure cr/nl line endings work.
    XCTAssert([output writeString:@"four\r\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"five\r\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"six\r\n" error:&localError] && localError == nil);

    // And that cr only line endings work.
    XCTAssert([output writeString:@"seven\r" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"eight\r" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"nine\r" error:&localError] && localError == nil);

    [output close];
    
    NSInputStream *input = [NSInputStream inputStreamWithData:[output ajr_data]];
    
    [input open];
    XCTAssert(input.streamStatus == NSStreamStatusOpen);
    
    input.encoding = NSUTF32LittleEndianStringEncoding;
    
    NSString *line;
    
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"one"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"two"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"three"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"four"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"five"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"six"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"seven"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"eight"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"nine"]);
    // Attempt to read past EOF
    line = [input readLineReturningError:&localError];
    XCTAssert(line == nil && localError == nil);
    
    [input close];
    
    // Finally, make sure we fail gracefully on error.
    line = [input readLineReturningError:&localError];
    XCTAssert(line == nil && localError != nil);
}

- (void)testReadLine8BitEncoding {
    NSError *localError;
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    [output open];
    XCTAssert(output.streamStatus == NSStreamStatusOpen);
    
    output.encoding = NSUTF8StringEncoding;
    
    // Make sure nl line endings work.
    XCTAssert([output writeString:@"one\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"two\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"three\n" error:&localError] && localError == nil);
    
    output.encoding = NSUTF8StringEncoding;

    // Also make sure cr/nl line endings work.
    XCTAssert([output writeString:@"four\r\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"five\r\n" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"six\r\n" error:&localError] && localError == nil);

    // And that cr only line endings work.
    XCTAssert([output writeString:@"seven\r" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"eight\r" error:&localError] && localError == nil);
    XCTAssert([output writeString:@"nine\r" error:&localError] && localError == nil);

    [output close];
    
    NSInputStream *input = [NSInputStream inputStreamWithData:[output ajr_data]];
    
    [input open];
    XCTAssert(input.streamStatus == NSStreamStatusOpen);

    input.encoding = NSUTF8StringEncoding;
    
    NSString *line;
    
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"one"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"two"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"three"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"four"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"five"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"six"]);
    // Make sure ASCII encoding is working. This works, because while we wrote with UTF-8, we stayed with characters that fall within the ASCII range.
    input.encoding = NSASCIIStringEncoding;
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"seven"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"eight"]);
    line = [input readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"nine"]);
    // Attempt to read past EOF
    line = [input readLineReturningError:&localError];
    XCTAssert(line == nil && localError == nil);
    
    [input close];
    
    // Finally, make sure we fail gracefully on error.
    line = [input readLineReturningError:&localError];
    XCTAssert(line == nil && localError != nil);
}

- (void)testEncodings {
    // We test most encoding stuff above, but we still want to test resetting the encoding.
    NSError *localError;
    NSInputStream *input = [NSInputStream inputStreamWithData:[NSData data]];
    
    XCTAssert(input != nil && localError == nil);
    
    input.encoding = NSUTF32BigEndianStringEncoding;
    XCTAssert(input.encoding == NSUTF32BigEndianStringEncoding);
    input.encoding = 0;
    XCTAssert(input.encoding == NSUTF8StringEncoding);
    
    [input close];
}

- (void)testStreamCreation {
    // This isn't really sufficient, but good enough for now. Really, I probably want a small helper program that runs and reads what I write via a pipe, but the problem is, that wouldn't get us code coverage, because the code we want to see running would be in a child process.
    NSInputStream *input = [NSInputStream inputStreamWithStandardInput];
    [input open];
    XCTAssert(input.streamStatus == NSStreamStatusOpen);
}

@end
