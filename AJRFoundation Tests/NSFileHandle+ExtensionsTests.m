/*
 NSFileHandle+ExtensionsTests.m
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

@interface AJRTestWriterObject : NSObject <AJRByteWriter>

@end

@interface AJRTestWriterObject (AJRTest) <AJRByteWriterMethods>
@end

@implementation AJRTestWriterObject

@synthesize encoding;
@synthesize encodingName;
@synthesize endianness;

- (BOOL)writeBytes:(nonnull const void *)bytes length:(size_t)length bytesWritten:(out nullable size_t *)bytesWritten error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    return YES;
}

- (BOOL)writeInt8:(int8_t)value error:(out NSError * _Nullable __autoreleasing *)error {
    return NO;
}

@end

@interface NSFileHandle_ExtensionsTests : XCTestCase

@end

@implementation NSFileHandle_ExtensionsTests

- (void)testCreationFailures {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file;
    
    file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:NO withPermissions:0666 error:&localError];
    XCTAssert(file == nil);
    XCTAssert(localError != nil);
    
    path = @"/usr/share/terminfo/mom";
    file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file == nil);
    XCTAssert(localError != nil);
}

- (void)testPrimitiveReadingAndWriting {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file;
    uint8_t buffer[20] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13 };
    
    file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    
    size_t bytesWritten = 0;
    XCTAssert([file writeBytes:buffer length:sizeof(buffer) / sizeof(uint8_t) bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(bytesWritten == sizeof(buffer) / sizeof(uint8_t));
    XCTAssert(localError == nil);
    
    [file closeFile];
    
    // Make sure we generate an error.
    XCTAssert(![file writeBytes:buffer length:sizeof(buffer) / sizeof(uint8_t) bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(localError != nil);
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    
    uint8_t readBuffer[50];
    size_t bytesRead;
    XCTAssert([file readBytes:readBuffer length:10 bytesRead:&bytesRead error:&localError]);
    XCTAssert(bytesRead == 10);
    XCTAssert(localError == nil);
    
    for (NSInteger x = 0; x < 10; x++) {
        XCTAssert(buffer[x] == readBuffer[x], @"Value at index %d wasn't correct.", (int)x);
    }
    
    bytesRead = [file readBytes:readBuffer + 10 length:10];
    XCTAssert(bytesRead == 10);
    for (NSInteger x = 0; x < 20; x++) {
        XCTAssert(buffer[x] == readBuffer[x], @"Value at index %d wasn't correct.", (int)x);
    }
    
    [file closeFile];
    
    // Force an error.
    XCTAssert(![file readBytes:readBuffer length:10 bytesRead:&bytesRead error:&localError]);
    XCTAssert(localError != nil);
    
    bytesRead = [file readBytes:readBuffer length:10];
    XCTAssert(bytesRead == (size_t)-1);

    [NSFileManager.defaultManager removeItemAtPath:path error:&localError];
}

- (void)testReadingCharacters {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingCharacters" ofType:@"utf8" inDirectory:@"Test Files"];
    NSString *original = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    XCTAssert(path);
    XCTAssert(original);
    
    AJRPrintf(@"original: %@\n", original);
    
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    
    NSError *localError = nil;
    uint32_t character;
    NSData *originalData = [original dataUsingEncoding:NSUTF32LittleEndianStringEncoding];
    uint32_t *originalCharacters = (uint32_t *)[originalData bytes];
    
    NSInteger offset = 0;
    while ([file readCharacter:&character error:&localError] > 0) {
        XCTAssert(localError == nil, @"We got an error we didn't expect: %@", localError.localizedDescription);
        XCTAssert(originalCharacters[offset] == character, @"Character at position %d didn't match expected value. Got 0x%x, expected 0x%x", (int)offset, (int)character, (int)originalCharacters[offset]);
        AJRPrintf(@"%d: 0x%x == 0x%x, %lc\n", (int)[file offsetInFile], (int)originalCharacters[offset], (int)character, character);
        offset++;
    }
    
    [file closeFile];
    
    // Try to read one more character, which should produce an error, since we closed the file.
    XCTAssert([file readCharacter:&character error:&localError] == (size_t)-1);
    XCTAssert(localError != nil);
}

- (void)testReadCharacterError {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    
    XCTAssert(file != nil);
    XCTAssert(localError == nil);

    [file seekToFileOffset:0];
    
    XCTAssert([file writeUInt64:0xEEEEEEEEEEEEEEEE error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert([file writeUInt64:0xEEEEEEEEEEEEEEEE error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert([file writeUInt64:0xEEEEEEEEEEEEEEEE error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert([file writeUInt64:0xEEEEEEEEEEEEEEEE error:&localError]);
    XCTAssert(localError == nil);

    [file seekToFileOffset:0];
    uint32_t character;
    size_t bytesRead = [file readCharacter:&character error:&localError];
    XCTAssert(bytesRead == (size_t)-1);
    XCTAssert(localError != nil);
    
    [file closeFile];
    
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (void)testReadToCharacter {
    NSError *localError;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingCharacters" ofType:@"utf8" inDirectory:@"Test Files"];
    NSString *original = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];

    XCTAssert(path);

    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);

    NSString *string = [file readToCharacter:0x1F436 error:&localError];
    XCTAssert([original hasPrefix:string]);

    // Make sure we get back an empty string...
    string = [file readToCharacter:0x1F436 error:&localError];
    XCTAssert(string != nil);
    XCTAssert(string.length == 0);
    
    // Now read to a character we know doesn't exist, just to hit EOF.
    string = [file readToCharacter:0x1FFFFF error:&localError];
    XCTAssert([original hasSuffix:string]);
    
    // Make sure we get back an empty string, now that we're at EOF.
    XCTAssert([file readToCharacter:0x1FFFFF error:&localError] == nil);
    XCTAssert(localError == nil);
    
    // Close the file, and make sure we generate an error.
    [file closeFile];
    
    string = [file readToCharacter:0x1FFFFF error:&localError];
    XCTAssert(string == nil);
    XCTAssert(localError != nil);

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingToCharacterLarges" ofType:@"utf8" inDirectory:@"Test Files"];
    original = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    XCTAssert(path);
    XCTAssert(original);

    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    
    string = [file readToCharacter:0x1F991 error:&localError];
    XCTAssert(string != nil);
    XCTAssert(localError == nil);
    XCTAssert([original hasPrefix:string]);
    
    [file closeFile];
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    string = [file readToCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ñ"] error:&localError];
    XCTAssert(string != nil);
    XCTAssert(localError == nil);
    XCTAssert([string isEqualToString:@"áéíóú å äëïöü àèìòù ãõ"]);

    [file closeFile];
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    string = [file readCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"áéíóú"] error:&localError];
    XCTAssert(string != nil);
    XCTAssert(localError == nil);
    XCTAssert([string isEqualToString:@"áéíóú"]);

    [file closeFile];
}

- (void)testReadToByte {
    NSError *localError;
    NSString *path = [[NSFileManager defaultManager] temporaryFilename];
    
    FILE *file = fopen([path UTF8String], "w");
    XCTAssert(file >= 0);
    for (NSInteger x = 0; x < 256; x++) {
        fputc((unsigned int)x, file);
    }
    fflush(file);
    fclose(file);
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(fileHandle != nil);
    
    NSData *data = [fileHandle readToByte:0x80 error:&localError];
    XCTAssert(data != nil);
    XCTAssert(data.length == 128, @"Expected 128 bytes, got %d bytes", (int)data.length);
    const uint8_t *bytes = [data bytes];
    for (NSInteger x = 0; x < data.length; x++) {
        XCTAssert(x == bytes[x], @"byte %d wasn't correct", (int)x);
    }
    
    // Read to the end.
    data = [fileHandle readToByte:0 error:&localError];
    XCTAssert(data != nil);
    XCTAssert(data.length == 128, @"Expected 128 bytes, got %d bytes", (int)data.length);
    bytes = [data bytes];
    for (NSInteger x = 0; x < data.length; x++) {
        XCTAssert(x + 128 == bytes[x], @"byte %d wasn't correct", (int)x);
    }
    
    // Read nothing, because we're at EOF
    data = [fileHandle readToByte:0 error:&localError];
    XCTAssert(data == nil);
    XCTAssert(localError == nil);
    
    [fileHandle closeFile];
    
    // Force an error
    data = [fileHandle readToByte:0 error:&localError];
    XCTAssert(data == nil);
    XCTAssert(localError != nil);

    // Remove the file.
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

    // Now test a large file.
    file = fopen([path UTF8String], "w");
    XCTAssert(file >= 0);
    for (NSInteger x = 0; x < 32768; x++) {
        fputc((unsigned int)x % 192, file);
    }
    fputc((unsigned int)0xFF, file);
    fflush(file);
    fclose(file);

    fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(fileHandle != nil);
    
    data = [fileHandle readToByte:0x80 error:&localError];
    XCTAssert(data != nil);
    XCTAssert(data.length == 128, @"Expected 128 bytes, got %d bytes", (int)data.length);
    bytes = [data bytes];
    for (NSInteger x = 0; x < data.length; x++) {
        XCTAssert(x == bytes[x], @"byte %d wasn't correct", (int)x);
    }
    
    // Make sure we get empty data if we read to the same byte again.
    data = [fileHandle readToByte:0x80 error:&localError];
    XCTAssert(data != nil);
    XCTAssert(data.length == 0, @"Expected 0 bytes, got %d bytes", (int)data.length);

    // Make sure we're still reading.
    data = [fileHandle readToByte:0xFF error:&localError];
    XCTAssert(data != nil);
    XCTAssert(data.length == 32640, @"Expected 128 bytes, got %d bytes", (int)data.length);
    bytes = [data bytes];
    for (NSInteger x = 0; x < data.length; x++) {
        XCTAssert((x + 128) % 192 == bytes[x], @"byte %d wasn't correct", (int)x);
    }
    
    uint8_t byte;
    size_t readLength = 0;
    XCTAssert([fileHandle readBytes:&byte length:1 bytesRead:&readLength error:&localError]);
    XCTAssert(readLength == 1);
    XCTAssert(byte == 0xFF);
    
    XCTAssert([fileHandle readBytes:&byte length:1 bytesRead:&readLength error:&localError]);
    XCTAssert(readLength == 0);
    XCTAssert(localError == nil);
    
    close(fileHandle.fileDescriptor);
    
    XCTAssert(![fileHandle readBytes:&byte length:1 bytesRead:&readLength error:&localError]);
    XCTAssert(readLength == 0);
    XCTAssert(localError != nil);
    
    // Remove the file.
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)testReadingAndWritingDataTypes {
    float testFloatValue = 1234.5678;
    double testDoubleValue = 12345678.12345678;
    NSError *localError;
    NSString *path = [[NSFileManager defaultManager] temporaryFilename];
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    
    XCTAssert(file != nil);
    XCTAssert(localError == nil);
    
    // Files are big endian by default.
    XCTAssert(file.endianness == AJREndiannessBig);
    
    file.endianness = AJREndiannessLittle;
    XCTAssert([file writeInt8:0x11 error:&localError] && localError == nil);
    XCTAssert([file writeUInt8:0x22 error:&localError] && localError == nil);
    XCTAssert([file writeInt16:0x1122 error:&localError] && localError == nil);
    XCTAssert([file writeUInt16:0x3344 error:&localError] && localError == nil);
    XCTAssert([file writeInt32:0x11223344 error:&localError] && localError == nil);
    XCTAssert([file writeUInt32:0x55667788 error:&localError] && localError == nil);
    XCTAssert([file writeInt64:0x1122334455667788 error:&localError] && localError == nil);
    XCTAssert([file writeUInt64:0x99AABBCCDDEEFF00 error:&localError] && localError == nil);
    
    NSUInteger bigEndianOffset = [file offsetInFile];
    file.endianness = AJREndiannessBig;
    XCTAssert([file writeInt8:0x11 error:&localError] && localError == nil);
    XCTAssert([file writeUInt8:0x22 error:&localError] && localError == nil);
    XCTAssert([file writeInt16:0x1122 error:&localError] && localError == nil);
    XCTAssert([file writeUInt16:0x3344 error:&localError] && localError == nil);
    XCTAssert([file writeInt32:0x11223344 error:&localError] && localError == nil);
    XCTAssert([file writeUInt32:0x55667788 error:&localError] && localError == nil);
    XCTAssert([file writeInt64:0x1122334455667788 error:&localError] && localError == nil);
    XCTAssert([file writeUInt64:0x99AABBCCDDEEFF00 error:&localError] && localError == nil);
    XCTAssert([file writeInt16:0x1122 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([file writeUInt16:0x3344 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([file writeInt32:0x11223344 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([file writeUInt32:0x55667788 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([file writeInt64:0x1122334455667788 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert([file writeUInt64:0x99AABBCCDDEEFF00 endianness:AJREndiannessBig error:&localError] && localError == nil);

    // And write some floating point. These ignore endianness, as floating point numbers have their own machine independent format.
    XCTAssert([file writeFloat:testFloatValue error:&localError] && localError == nil);
    XCTAssert([file writeDouble:testDoubleValue error:&localError] && localError == nil);

    [file closeFile];
    
    // Now lets see if the bytes are in the file, and in the order we expect.
    NSData *data = [NSData dataWithContentsOfFile:path];
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

    file = [NSFileHandle fileHandleForReadingAtPath:path];
    file.endianness = AJREndiannessLittle;
    // int8_t
    XCTAssert([file readInt8:&int8 error:&localError] && localError == nil);
    XCTAssert(int8 == 0x11);
    XCTAssert([file readUInt8:&uint8 error:&localError] && localError == nil);
    XCTAssert(uint8 == 0x22);
    // int16_t
    XCTAssert([file readInt16:&int16 error:&localError] && localError == nil);
    XCTAssert(int16 == 0x1122);
    XCTAssert([file readUInt16:&uint16 error:&localError] && localError == nil);
    XCTAssert(uint16 == 0x3344);
    // int32_t
    XCTAssert([file readInt32:&int32 error:&localError] && localError == nil);
    XCTAssert(int32 == 0x11223344);
    XCTAssert([file readUInt32:&uint32 error:&localError] && localError == nil);
    XCTAssert(uint32 == 0x55667788);
    // int64_t
    XCTAssert([file readInt64:&int64 error:&localError] && localError == nil);
    XCTAssert(int64 == 0x1122334455667788);
    XCTAssert([file readUInt64:&uint64 error:&localError] && localError == nil);
    XCTAssert(uint64 == 0x99AABBCCDDEEFF00);
    // Quick test of isAtEndOfFileReturningError
    BOOL isAtEnd;
    XCTAssert([file isAtEndOfFile:&isAtEnd error:&localError] && !isAtEnd && localError == nil);
    // Now big-endian tests
    file.endianness = AJREndiannessBig;
    // int8_t
    XCTAssert([file readInt8:&int8 error:&localError] && localError == nil);
    XCTAssert(int8 == 0x11);
    XCTAssert([file readUInt8:&uint8 error:&localError] && localError == nil);
    XCTAssert(uint8 == 0x22);
    // int16_t
    XCTAssert([file readInt16:&int16 error:&localError] && localError == nil);
    XCTAssert(int16 == 0x1122);
    XCTAssert([file readUInt16:&uint16 error:&localError] && localError == nil);
    XCTAssert(uint16 == 0x3344);
    // int32_t
    XCTAssert([file readInt32:&int32 error:&localError] && localError == nil);
    XCTAssert(int32 == 0x11223344);
    XCTAssert([file readUInt32:&uint32 error:&localError] && localError == nil);
    XCTAssert(uint32 == 0x55667788);
    // int64_t
    XCTAssert([file readInt64:&int64 error:&localError] && localError == nil);
    XCTAssert(int64 == 0x1122334455667788);
    XCTAssert([file readUInt64:&uint64 error:&localError] && localError == nil);
    XCTAssert(uint64 == 0x99AABBCCDDEEFF00);
    // int16_t
    XCTAssert([file readInt16:&int16 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(int16 == 0x1122);
    XCTAssert([file readUInt16:&uint16 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(uint16 == 0x3344);
    // int32_t
    XCTAssert([file readInt32:&int32 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(int32 == 0x11223344);
    XCTAssert([file readUInt32:&uint32 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(uint32 == 0x55667788);
    // int64_t
    XCTAssert([file readInt64:&int64 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(int64 == 0x1122334455667788);
    XCTAssert([file readUInt64:&uint64 endianness:AJREndiannessBig error:&localError] && localError == nil);
    XCTAssert(uint64 == 0x99AABBCCDDEEFF00);
    // Floating points
    XCTAssert([file readFloat:&testFloat error:&localError] && localError == nil);
    XCTAssert(testFloat == testFloatValue);
    XCTAssert([file readDouble:&testDouble error:&localError] && localError == nil);
    XCTAssert(testDouble == testDoubleValue);
    // Quick test of isAtEndOfFileReturningError
    XCTAssert([file isAtEndOfFile:&isAtEnd error:&localError] && isAtEnd && localError == nil);

    [file closeFile];
    
    // Make sure error handling is working...
    XCTAssert(![file isAtEndOfFile:&isAtEnd error:&localError] && localError != nil);

    XCTAssert(![file readInt8:&int8 error:&localError] && localError != nil);
    XCTAssert(![file readUInt8:&uint8 error:&localError] && localError != nil);
    // int16_t
    XCTAssert(![file readInt16:&int16 endianness:AJREndiannessBig error:&localError] && localError != nil);
    XCTAssert(![file readUInt16:&uint16 endianness:AJREndiannessBig error:&localError] && localError != nil);
    // int32_t
    XCTAssert(![file readInt32:&int32 endianness:AJREndiannessBig error:&localError] && localError != nil);
    XCTAssert(![file readUInt32:&uint32 endianness:AJREndiannessBig error:&localError] && localError != nil);
    // int64_t
    XCTAssert(![file readInt64:&int64 endianness:AJREndiannessBig error:&localError] && localError != nil);
    XCTAssert(![file readUInt64:&uint64 endianness:AJREndiannessBig error:&localError] && localError != nil);
    // floating point
    XCTAssert(![file readFloat:&testFloat error:&localError] && localError != nil);
    XCTAssert(![file readDouble:&testDouble error:&localError] && localError != nil);

    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testReadLineNon8BitEncoding {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file;
    
    file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    
    file.encoding = NSUTF32LittleEndianStringEncoding;
    
    // Make sure nl line endings work.
    XCTAssert([file writeString:@"one\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"two\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"three\n" error:&localError] && localError == nil);
    
    // Because we need to test this somewhere, close the file, then re-open to test appending.
    [file closeFile];
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);

    file.encoding = NSUTF32LittleEndianStringEncoding;

    // Also make sure cr/nl line endings work.
    XCTAssert([file writeString:@"four\r\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"five\r\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"six\r\n" error:&localError] && localError == nil);

    // And that cr only line endings work.
    XCTAssert([file writeString:@"seven\r" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"eight\r" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"nine\r" error:&localError] && localError == nil);

    [file closeFile];
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil && localError == nil);
    
    file.encoding = NSUTF32LittleEndianStringEncoding;
    
    NSString *line;
    
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"one"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"two"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"three"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"four"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"five"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"six"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"seven"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"eight"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"nine"]);
    // Attempt to read past EOF
    line = [file readLineReturningError:&localError];
    XCTAssert(line == nil && localError == nil);
    
    [file closeFile];
    
    // Finally, make sure we fail gracefully on error.
    line = [file readLineReturningError:&localError];
    XCTAssert(line == nil && localError != nil);
    
    // Don't care if this fails, we're just trying to be nice by cleaning our temporary files.
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (void)testReadLine8BitEncoding {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file;
    
    file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    
    file.encoding = NSUTF8StringEncoding;
    
    // Make sure nl line endings work.
    XCTAssert([file writeString:@"one\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"two\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"three\n" error:&localError] && localError == nil);
    
    // Because we need to test this somewhere, close the file, then re-open to test appending.
    [file closeFile];
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);

    file.encoding = NSUTF8StringEncoding;

    // Also make sure cr/nl line endings work.
    XCTAssert([file writeString:@"four\r\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"five\r\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"six\r\n" error:&localError] && localError == nil);

    // And that cr only line endings work.
    XCTAssert([file writeString:@"seven\r" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"eight\r" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"nine\r" error:&localError] && localError == nil);

    [file closeFile];
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil && localError == nil);
    
    file.encoding = NSUTF8StringEncoding;
    
    NSString *line;
    
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"one"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"two"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"three"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"four"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"five"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"six"]);
    // Make sure ASCII encoding is working. This works, because while we wrote with UTF-8, we stayed with characters that fall within the ASCII range.
    file.encoding = NSASCIIStringEncoding;
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"seven"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"eight"]);
    line = [file readLineReturningError:&localError];
    XCTAssert(localError == nil && [line isEqualToString:@"nine"]);
    // Attempt to read past EOF
    line = [file readLineReturningError:&localError];
    XCTAssert(line == nil && localError == nil);
    
    [file closeFile];
    
    // Finally, make sure we fail gracefully on error.
    line = [file readLineReturningError:&localError];
    XCTAssert(line == nil && localError != nil);
    
    // Don't care if this fails, we're just trying to be nice by cleaning our temporary files.
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (void)testEncodings {
    // We test most encoding stuff above, but we still want to test resetting the encoding.
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    
    XCTAssert(file != nil && localError == nil);
    
    file.encoding = NSUTF32BigEndianStringEncoding;
    XCTAssert(file.encoding == NSUTF32BigEndianStringEncoding);
    file.encoding = 0;
    XCTAssert(file.encoding == NSUTF8StringEncoding);
    
    [file closeFile];
    
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (void)testStringReadingAndWriting {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file;
    
    file = [NSFileHandle fileHandleForWritingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil);
    XCTAssert(localError == nil);
    
    size_t bytesWritten;
    XCTAssert([file writeString:@"This is a test with some unicode: 𐎠𐎱𐏂𐏃𐏔𐏏𐏌𐏋𐎻" bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert([file writeUInt8:0 error:&localError]);
    XCTAssert(bytesWritten == 70);
    XCTAssert(localError == nil);
    XCTAssert([file writeCString:"This is a test without unicode." bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert([file writeCString:NULL error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(bytesWritten == 32);
    // And an unterminate C string.
    XCTAssert([file writeBytes:"Final test." length:11 error:&localError]);
    XCTAssert(localError == nil);

    [file closeFile];
    
    // Try some error conditions...
    XCTAssert(![file writeString:@"This is a test with some unicode: 𐎠𐎱𐏂𐏃𐏔𐏏𐏌𐏋𐎻" error:&localError]);
    XCTAssert(localError != nil);
    XCTAssert(![file writeCString:"This is a test without unicode." error:&localError]);
    XCTAssert(localError != nil);
    XCTAssert(![file writeCString:NULL error:&localError]);
    XCTAssert(localError != nil);
    
    file = [NSFileHandle fileHandleWithPath:path mode:O_RDONLY create:NO permissions:0 error:&localError];
    XCTAssert(file != nil);
    XCTAssert(localError == nil);
    
    NSString *string;
    uint8_t byte;
    
    string = [file readToCharacter:0 error:&localError];
    XCTAssert(string != nil);
    XCTAssert([string isEqualToString:@"This is a test with some unicode: 𐎠𐎱𐏂𐏃𐏔𐏏𐏌𐏋𐎻"]);
    XCTAssert(localError == nil);
    XCTAssert([file readUInt8:&byte error:&localError]);
    XCTAssert(byte == 0);
    XCTAssert(localError == nil);
    
    char buffer[100];
    XCTAssert([file readCString:buffer maximumLength:100 error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(strcmp(buffer, "This is a test without unicode.") == 0);
    XCTAssert([file readCString:buffer maximumLength:100 error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(strlen(buffer) == 0);
    XCTAssert([file readCString:buffer maximumLength:6 error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(strcmp(buffer, "Final") == 0);
    XCTAssert([file readCString:buffer maximumLength:100 error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(strcmp(buffer, " test.") == 0);

    [file closeFile];
    
    // Try for a final error condition.
    XCTAssert(![file readCString:buffer maximumLength:100 error:&localError]);
    XCTAssert(localError != nil);
    
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (NSString *)createFileOfIntegers:(NSInteger)count {
    NSError *localError;
    NSString *path = [NSFileManager.defaultManager temporaryFilename];
    NSFileHandle *file;
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    
    for (NSInteger x = 0; x < count; x++) {
        XCTAssert([file writeUInt32:(uint32_t)x endianness:AJREndiannessLittle error:&localError]);
        XCTAssert(localError == nil);
    }
    [file closeFile];
    
    return path;
}

- (void)testRemovingBytes {
    NSInteger count = 32768;
    NSError *localError;
    NSString *path = [self createFileOfIntegers:count];
    NSRange rangeToRemove = { 0, 100 * sizeof(uint32_t) };
    NSFileHandle *file;
    
    // Test remove from front of file.
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil);
    XCTAssert(localError == nil);
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError] && localError == nil);
    [file closeFile];
    
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&localError];
    XCTAssert([attributes fileSize] == (count - 100) * sizeof(uint32_t));
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    for (NSInteger x = 100; x < count; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    [file closeFile];
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
    
    // Test remove from end of file.
    path = [self createFileOfIntegers:count];
    rangeToRemove = (NSRange){ (count - 100) * sizeof(uint32_t), 100 * sizeof(uint32_t) };
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil);
    XCTAssert(localError == nil);
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError] && localError == nil);
    [file closeFile];
    
    attributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&localError];
    XCTAssert([attributes fileSize] == (count - 100) * sizeof(uint32_t));
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    for (NSInteger x = 0; x < count - 100; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    [file closeFile];
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];

    // Test remove from middle-ish of file.
    path = [self createFileOfIntegers:count];
    rangeToRemove = (NSRange){ (count - 10000) * sizeof(uint32_t), 100 * sizeof(uint32_t) };
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:YES withPermissions:0666 error:&localError];
    XCTAssert(file != nil);
    XCTAssert(localError == nil);
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError] && localError == nil);
    [file closeFile];
    
    attributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&localError];
    XCTAssert([attributes fileSize] == (count - 100) * sizeof(uint32_t));
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    for (NSInteger x = 0; x < count - 10000; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    for (NSInteger x = count - 10000 + 100; x < count - 100; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    
    // And a quick test to remove past EOF.
    rangeToRemove = (NSRange){count * sizeof(uint32_t), 100};
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError]);
    XCTAssert(localError == nil);
    
    [file closeFile];
    
    // Before we remove the file, let's try to force an error by writing to a readonly file.
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    rangeToRemove = (NSRange){0, 100 * sizeof(uint32_t)};
    XCTAssert(![file removeBytesInRange:rangeToRemove error:&localError]);
    XCTAssert(localError != nil);
    [file closeFile];
    
    // Finally, just try an error by truncating a close file.
    XCTAssert(![file removeBytesInRange:rangeToRemove error:&localError]);
    XCTAssert(localError != nil);

    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (NSData *)dataWithBigEndianInts:(NSInteger)count {
    uint32_t *buffer = (uint32_t *)malloc(sizeof(uint32_t) * count);
    for (uint32_t x = 0; x < count; x++) {
        buffer[x] = CFSwapInt32HostToBig(x);
    }
    return [[NSData alloc] initWithBytesNoCopy:buffer length:sizeof(uint32_t) * count freeWhenDone:YES];
}

- (void)testReplacingBytes {
    NSInteger count = 8192;
    NSError *localError;
    NSString *path = [self createFileOfIntegers:count];
    NSRange rangeToReplace;
    NSFileHandle *file;
    NSData *sampleData = [self dataWithBigEndianInts:100];
    
    // Case 1: Call through to removeBytesInRange:error:. Note that we're not going to test this super-thoroughly, beacuse we do that above in testRemovingBytes.
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:NO withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 100 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:[NSData data] error:&localError] && localError == nil);

    // Case 2: Try to replace bytes past the end of the file.
    rangeToReplace = (NSRange){sizeof(uint32_t) * 10000, 10};
    XCTAssert(![file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError != nil);
    
    [file closeFile];
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
    
    // Case 3: Replacement bytes length == range length.
    path = [self createFileOfIntegers:count];
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:NO withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 100 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError == nil);
    [file closeFile];
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    for (NSInteger x = 0; x < 100; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessBig error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    for (NSInteger x = 100; x < count; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    [file closeFile];
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
    
    // Case 4: Replace bytes length < range length.
    path = [self createFileOfIntegers:count];
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:NO withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 1000 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError == nil);
    [file closeFile];
    
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&localError];
    XCTAssert([attributes fileSize] == (8192 - (1000 - 100)) * sizeof(uint32_t));
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    for (NSInteger x = 0; x < 100; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessBig error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    for (NSInteger x = 1000; x < count; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    [file closeFile];
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
    
    // Case 5: Replace bytes length > range length.
    path = [self createFileOfIntegers:count];
    file = [NSFileHandle fileHandleForUpdatingAtPath:path createIfNecessary:NO withPermissions:0666 error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 50 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError == nil);
    [file closeFile];
    
    attributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&localError];
    XCTAssert([attributes fileSize] == (8192 - (50 - 100)) * sizeof(uint32_t));
    
    file = [NSFileHandle fileHandleForReadingAtPath:path];
    XCTAssert(file != nil);
    for (NSInteger x = 0; x < 100; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessBig error:&localError] && localError == nil);
        XCTAssert(value == x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    for (NSInteger x = 50; x < count; x++) {
        uint32_t value;
        XCTAssert([file readUInt32:&value endianness:AJREndiannessLittle error:&localError] && localError == nil);
        XCTAssert(value == x, @"%d was wrong", (int)x);
        if (value != x) {
            // Because we don't need thousands of test failures.
            break;
        }
    }
    [file closeFile];
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

#if defined(AJR_DEBUG)
- (void)testRegisterErrors {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(outputStream, AJRLogLevelWarning);
    AJRAddWriterConveniencesToWriter([AJRTestWriterObject class]);
    XCTAssert([[outputStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] isEqualToString:@"<WARNING>: Failed to install method writeInt8:error: on AJRTestWriterObject.\n"]);
    AJRLogSetOutputStream(NULL, AJRLogLevelWarning);
}
#endif

@end
