
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRMemoryHandleTests : XCTestCase

@end

// NOTE: Mostly cribbed from the NSFileHandleTests, since memory handle is a subclass of file handle.
@implementation AJRMemoryHandleTests

- (void)testPrimitiveReadingAndWriting {
    NSError *localError;
    AJRMemoryHandle *file;
    uint8_t buffer[20] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13 };
    
    file = [AJRMemoryHandle memoryHandleForWriting];
    XCTAssert(file != nil && localError == nil);
    
    size_t bytesWritten = 0;
    XCTAssert([file writeBytes:buffer length:sizeof(buffer) / sizeof(uint8_t) bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(bytesWritten == sizeof(buffer) / sizeof(uint8_t));
    XCTAssert(localError == nil);
    
    [file closeFile];
    
    // Make sure we generate an error.
    XCTAssert(![file writeBytes:buffer length:sizeof(buffer) / sizeof(uint8_t) bytesWritten:&bytesWritten error:&localError]);
    XCTAssert(localError != nil);
    
    NSData *data = [file data];
    file = [AJRMemoryHandle memoryHandleForReadingData:data];
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
}

- (void)testReadingCharacters {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingCharacters" ofType:@"utf8" inDirectory:@"Test Files"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *original = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    XCTAssert(data != nil);
    XCTAssert(path != nil);
    XCTAssert(original != nil);

    AJRPrintf(@"original: %@\n", original);

    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForReadingDataNoCopy:data];
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
    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForWriting];

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
    uint8_t byte = 0;
    
    NSMutableData *characterData = [NSMutableData data];
    for (NSInteger x = 0; x < 256; x++) {
        byte = x;
        [characterData appendBytes:&byte length:1];
    }

    AJRMemoryHandle *fileHandle = [AJRMemoryHandle memoryHandleForReadingData:characterData];
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

    // Now test a large file.
    characterData = [NSMutableData data];
    for (NSInteger x = 0; x < 32768; x++) {
        byte = (uint32_t)x % 192;
        [characterData appendBytes:&byte length:1];
    }
    byte = 0xFF;
    [characterData appendBytes:&byte length:1];

    fileHandle = [AJRMemoryHandle memoryHandleForReadingDataNoCopy:characterData];
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

    size_t readLength = 0;
    XCTAssert([fileHandle readBytes:&byte length:1 bytesRead:&readLength error:&localError]);
    XCTAssert(readLength == 1);
    XCTAssert(byte == 0xFF);

    XCTAssert([fileHandle readBytes:&byte length:1 bytesRead:&readLength error:&localError]);
    XCTAssert(readLength == 0);
    XCTAssert(localError == nil);

    [fileHandle closeFile];

    XCTAssert(![fileHandle readBytes:&byte length:1 bytesRead:&readLength error:&localError]);
    XCTAssert(readLength == 0);
    XCTAssert(localError != nil);
}

- (void)testReadingAndWritingDataTypes {
    float testFloatValue = 1234.5678;
    double testDoubleValue = 12345678.12345678;
    NSError *localError;
    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForWriting];

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
    NSData *data = file.data;
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

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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
}

- (void)testReadLineNon8BitEncoding {
    NSError *localError;
    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForWriting];
    XCTAssert(file != nil);

    file.encoding = NSUTF32LittleEndianStringEncoding;

    // Make sure nl line endings work.
    XCTAssert([file writeString:@"one\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"two\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"three\n" error:&localError] && localError == nil);

    // Because we need to test this somewhere, close the file, then re-open to test appending.
    [file closeFile];

    file = [AJRMemoryHandle memoryHandleForUpdatingData:[file.data mutableCopy] error:&localError];
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

    file = [AJRMemoryHandle memoryHandleForReadingDataNoCopy:file.data];
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
}

- (void)testReadLine8BitEncoding {
    NSError *localError;
    AJRMemoryHandle *file;

    file = [AJRMemoryHandle memoryHandleForWriting];
    XCTAssert(file != nil);

    file.encoding = NSUTF8StringEncoding;

    // Make sure nl line endings work.
    XCTAssert([file writeString:@"one\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"two\n" error:&localError] && localError == nil);
    XCTAssert([file writeString:@"three\n" error:&localError] && localError == nil);

    // Because we need to test this somewhere, close the file, then re-open to test appending.
    [file closeFile];

    file = [AJRMemoryHandle memoryHandleForUpdatingData:file.mutableData error:&localError];
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

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
    XCTAssert(file != nil);

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
}

- (void)testEncodings {
    // We test most encoding stuff above, but we still want to test resetting the encoding.
    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForWriting];

    XCTAssert(file != nil);

    file.encoding = NSUTF32BigEndianStringEncoding;
    XCTAssert(file.encoding == NSUTF32BigEndianStringEncoding);
    file.encoding = 0;
    XCTAssert(file.encoding == NSUTF8StringEncoding);

    [file closeFile];
}

- (void)testStringReadingAndWriting {
    NSError *localError;
    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForWriting];
    XCTAssert(file != nil);

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

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
    XCTAssert(file != nil);

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
}

- (NSData *)createFileOfIntegers:(NSInteger)count {
    NSError *localError;
    AJRMemoryHandle *file = [AJRMemoryHandle memoryHandleForWriting];

    XCTAssert(file != nil);

    for (NSInteger x = 0; x < count; x++) {
        XCTAssert([file writeUInt32:(uint32_t)x endianness:AJREndiannessLittle error:&localError]);
        XCTAssert(localError == nil);
    }
    [file closeFile];

    return file.data;
}

- (void)testRemovingBytes {
    NSInteger count = 32768;
    NSError *localError;
    NSData *data = [self createFileOfIntegers:count];
    NSRange rangeToRemove = { 0, 100 * sizeof(uint32_t) };
    AJRMemoryHandle *file;

    // Test remove from front of file.
    file = [AJRMemoryHandle memoryHandleForUpdatingData:[data mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError] && localError == nil);
    [file closeFile];

    XCTAssert(file.data.length == (count - 100) * sizeof(uint32_t));

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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

    // Test remove from end of file.
    data = [self createFileOfIntegers:count];
    rangeToRemove = (NSRange){ (count - 100) * sizeof(uint32_t), 100 * sizeof(uint32_t) };

    file = [AJRMemoryHandle memoryHandleForUpdatingData:[data mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError] && localError == nil);
    [file closeFile];

    XCTAssert(file.data.length == (count - 100) * sizeof(uint32_t));

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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

    // Test remove from middle-ish of file.
    data = [self createFileOfIntegers:count];
    rangeToRemove = (NSRange){ (count - 10000) * sizeof(uint32_t), 100 * sizeof(uint32_t) };

    file = [AJRMemoryHandle memoryHandleForUpdatingData:[data mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    XCTAssert([file removeBytesInRange:rangeToRemove error:&localError] && localError == nil);
    [file closeFile];

    XCTAssert(file.data.length == (count - 100) * sizeof(uint32_t));

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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
    file = [AJRMemoryHandle memoryHandleForReadingData:data];
    XCTAssert(file != nil);
    rangeToRemove = (NSRange){0, 100 * sizeof(uint32_t)};
    XCTAssert(![file removeBytesInRange:rangeToRemove error:&localError]);
    XCTAssert(localError != nil);
    [file closeFile];

    // Finally, just try an error by truncating a close file.
    XCTAssert(![file removeBytesInRange:rangeToRemove error:&localError]);
    XCTAssert(localError != nil);
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
    NSData *baseData = [self createFileOfIntegers:count];
    NSRange rangeToReplace;
    AJRMemoryHandle *file;
    NSData *sampleData = [self dataWithBigEndianInts:100];

    // Case 1: Call through to removeBytesInRange:error:. Note that we're not going to test this super-thoroughly, beacuse we do that above in testRemovingBytes.
    file = [AJRMemoryHandle memoryHandleForUpdatingData:[baseData mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 100 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:[NSData data] error:&localError] && localError == nil);

    // Case 2: Try to replace bytes past the end of the file.
    rangeToReplace = (NSRange){sizeof(uint32_t) * 10000, 10};
    XCTAssert(![file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError != nil);

    [file closeFile];

    // Case 3: Replacement bytes length == range length.
    baseData = [self createFileOfIntegers:count];
    localError = nil;
    file = [AJRMemoryHandle memoryHandleForUpdatingData:[baseData mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 100 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError == nil);
    [file closeFile];

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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

    // Case 4: Replace bytes length < range length.
    baseData = [self createFileOfIntegers:count];
    file = [AJRMemoryHandle memoryHandleForUpdatingData:[baseData mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 1000 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError == nil);
    [file closeFile];

    XCTAssert(file.data.length == (8192 - (1000 - 100)) * sizeof(uint32_t));

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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

    // Case 5: Replace bytes length > range length.
    baseData = [self createFileOfIntegers:count];
    file = [AJRMemoryHandle memoryHandleForUpdatingData:[baseData mutableCopy] error:&localError];
    XCTAssert(file != nil && localError == nil);
    rangeToReplace = (NSRange){ 0, 50 * sizeof(uint32_t) };
    XCTAssert([file replaceDataInRange:rangeToReplace withData:sampleData error:&localError] && localError == nil);
    [file closeFile];

    XCTAssert(file.data.length == (8192 - (50 - 100)) * sizeof(uint32_t));

    file = [AJRMemoryHandle memoryHandleForReadingData:file.data];
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
}

- (void)testCreation {
    NSError *localError = nil;
    AJRMemoryHandle *handle;
    NSInteger value = 0xDEADBEEF;
    NSMutableData *data = [NSMutableData dataWithBytes:&value length:sizeof(value)];
    
    handle = [AJRMemoryHandle memoryHandleForReadingDataNoCopy:data];
    XCTAssert(handle != nil);
    handle.endianness = AJRGetCurrentArchitectureEndianness();
    
    value = 0xFEEDBABE;
    [data replaceBytesInRange:(NSRange){0, sizeof(NSInteger)} withBytes:&value];
    
    XCTAssert([handle readInteger:&value error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(value == 0xFEEDBABE);
    
    handle = [[AJRMemoryHandle alloc] init];
    XCTAssert(handle != nil && handle.canWrite);
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingCharacters" ofType:@"utf8" inDirectory:@"Test Files"];
    handle = [AJRMemoryHandle memoryHandleWithContentsOfFile:path options:0 error:&localError];
    XCTAssert(handle != nil && localError == nil);
    data = [NSMutableData dataWithContentsOfFile:path];
    XCTAssert([handle.data isEqualToData:data]);
    
    handle = [AJRMemoryHandle memoryHandleWithContentsOfURL:[NSURL fileURLWithPath:path] options:0 error:&localError];
    XCTAssert(handle != nil && localError == nil);
    XCTAssert([handle.data isEqualToData:data]);
    
    // And some failures...
    handle = [AJRMemoryHandle memoryHandleForUpdatingData:(NSMutableData *)[NSData data] error:&localError];
    XCTAssert(handle == nil && localError != nil);
    localError = nil;
    
    handle = [AJRMemoryHandle memoryHandleWithContentsOfFile:@"/non-existant-path" options:0 error:&localError];
    XCTAssert(handle == nil && localError != nil);
    
    handle = [AJRMemoryHandle memoryHandleWithContentsOfURL:[NSURL fileURLWithPath:@"/non-existant-path"] options:0 error:&localError];
    XCTAssert(handle == nil && localError != nil);
}

- (void)testImmutableToMutable {
    NSError *localError = nil;
    NSInteger value = 0xDEADBEEF;
    NSData *data = [[NSData alloc] initWithBytes:&value length:sizeof(value)];
    AJRMemoryHandle *handle = [AJRMemoryHandle memoryHandleForReadingData:data];
    handle.endianness = AJRGetCurrentArchitectureEndianness();
    
    XCTAssert(handle != nil);
    
    XCTAssert([handle readInteger:&value error:&localError]);
    XCTAssert(value == 0xDEADBEEF);
    
    [handle seekToFileOffset:0];
    
    // Try to write (and fail).
    XCTAssert(![handle writeInteger:0xFEEDBABE error:&localError]);
    XCTAssert(localError != nil); localError = nil;
    
    // Make the file writeable...
    [handle convertToWritable];
    
    // And try to write again...
    XCTAssert([handle writeInteger:0xFEEDBABE error:&localError]);
    XCTAssert(localError == nil);
    
    // Finally, make sure we wrote our value.
    [handle seekToFileOffset:0];
    XCTAssert([handle readInteger:&value error:&localError]);
    XCTAssert(localError == nil);
    XCTAssert(value == 0xFEEDBABE);
    
    // And see if we can access our now mutable data...
    [handle accessMutableData:^(NSMutableData * _Nonnull data, NSUInteger * _Nullable position) {
        XCTAssert(data != nil);
        XCTAssert(*position == sizeof(NSInteger));
        XCTAssert(data.length == sizeof(NSInteger));
    }];
}

@end
