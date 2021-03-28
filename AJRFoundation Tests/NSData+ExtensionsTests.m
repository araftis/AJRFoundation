/*
NSData+ExtensionsTests.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

NSString *testString = @"Now is the time for all good men to come to the aid of their country";
NSString *resultFromUnixBase64 = @"Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBtZW4gdG8gY29tZSB0byB0aGUgYWlkIG9mIHRoZWlyIGNvdW50cnk=";
NSString *resultFromUnixBase64AndLineBreaks = @"Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBt\n"
                                              @"ZW4gdG8gY29tZSB0byB0aGUgYWlkIG9mIHRoZWly\n"
                                              @"IGNvdW50cnk=";
NSString *resultFromUnixUUEncode = @"begin 644 test\n"
                                   @"M3F]W(&ES('1H92!T:6UE(&9O<B!A;&P@9V]O9\"!M96X@=&\\@8V]M92!T;R!T\n"
                                   @"7:&4@86ED(&]F('1H96ER(&-O=6YT<GD`\n"
                                   @"`\n"
                                   @"end\n";

NSDictionary *uuTestSet = nil;

@interface NSDataTest : XCTestCase

@end

@implementation NSDataTest

- (void)setUp {
    [super setUp];
    // Produced with:
    // echo -n "aaaaaa" | uuencode test | sed -e 's/"/\\"/g' | awk -F\t 'BEGIN { printf("@\""); } {printf("%s\\n", $1)} END { printf("\"");}' | pbcopy
    uuTestSet = @{ @"a" : @"begin 644 test\n!80``\n`\nend\n",
                   @"aa" : @"begin 644 test\n\"86$`\n`\nend\n",
                   @"aaa" : @"begin 644 test\n#86%A\n`\nend\n",
                   @"aaaa" : @"begin 644 test\n$86%A80``\n`\nend\n",
                   @"aaaaa" : @"begin 644 test\n%86%A86$`\n`\nend\n",
                   @"aaaaaa" : @"begin 644 test\n&86%A86%A\n`\nend\n",
                   };
}

- (void)testEncoding {
    NSData        *someData = [@"applestore:apple123" dataUsingEncoding:NSUTF8StringEncoding];
    NSString    *string = [someData ajr_base64EncodedString];
    
    AJRPrintf(@"encoded string: %@\n", string);
    XCTAssertTrue([string isEqualToString:@"YXBwbGVzdG9yZTphcHBsZTEyMw="], @"Encoding string isn't what it should be.");
}

- (void)testBase64 {
    NSData *data = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *result = [data ajr_base64EncodedString];
    XCTAssert([result isEqualToString:resultFromUnixBase64], @"Our encoded string didn't equal the results from the unix base64 command:\ninput: %@\noutput: %@\n", result, resultFromUnixBase64);
    
    result = [data ajr_base64EncodedStringWithLineBreakAtPosition:10];
    XCTAssert([result isEqualToString:resultFromUnixBase64AndLineBreaks], @"Our encoded string didn't equal the results from the unix base64 command:\ninput:\n%@\noutput:\n%@\n", result, resultFromUnixBase64AndLineBreaks);
    
    result = [[NSString alloc] initWithData:[NSData ajr_dataWithBase64EncodedString:resultFromUnixBase64 error:NULL] encoding:NSUTF8StringEncoding];
    XCTAssert([result isEqualToString:testString], @"Decoded data didn't produce the correct string");
    
    result = [[NSString alloc] initWithData:[NSData ajr_dataWithBase64EncodedString:resultFromUnixBase64AndLineBreaks error:NULL] encoding:NSUTF8StringEncoding];
    XCTAssert([result isEqualToString:testString], @"Decoded data didn't produce the correct string");
    
    NSError *localError = nil;
    data = [NSData ajr_dataWithBase64EncodedString:@"a=" error:&localError];
    XCTAssert(data == nil);
    
    data = [NSData ajr_dataWithBase64EncodedString:@"aa=" error:&localError];
    XCTAssert(data != nil);
    const unsigned char *bytes = [data bytes];
    XCTAssert([data length] == 1 && bytes[0] == 0x69);
    
    data = [NSData ajr_dataWithBase64EncodedString:@"aaa=" error:&localError];
    XCTAssert(data != nil);
    bytes = [data bytes];
    XCTAssert([data length] == 2 && bytes[0] == 0x69 && bytes[1] == 0xa6);
    
    data = [NSData ajr_dataWithBase64EncodedString:@"aaaa=" error:&localError];
    XCTAssert(data != nil);
    bytes = [data bytes];
    XCTAssert([data length] == 3 && bytes[0] == 0x69 && bytes[1] == 0xa6 && bytes[2] == 0x9a);
    
    data = [NSData ajr_dataWithBase64EncodedString:@"aaaaa=" error:&localError];
    XCTAssert(data == nil);
    
    data = [NSData ajr_dataWithBase64EncodedString:@"aaaaaa=" error:&localError];
    XCTAssert(data != nil);
    bytes = [data bytes];
    XCTAssert([data length] == 4 && bytes[0] == 0x69 && bytes[1] == 0xa6 && bytes[2] == 0x9a && bytes[3] == 0x69);
}

- (void)testUUEncoding {
    NSData *data = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *result = [data ajr_uuEncodedStringWithFilename:@"test" andPosixFilePermissions:0644];
    XCTAssert([result isEqualToString:resultFromUnixUUEncode], @"Our encoded string didn't equal the results from the unix base64 command:\ninput:\n%@\noutput:\n%@\n", result, resultFromUnixUUEncode);
    
    NSString *filename;
    NSUInteger permissions;
    result = [[NSString alloc] initWithData:[NSData ajr_dataWithUUEncodedString:resultFromUnixUUEncode filename:&filename permissions:&permissions error:NULL] encoding:NSUTF8StringEncoding];
    XCTAssert([filename isEqualToString:@"test"]);
    XCTAssert(permissions == 0644);
    XCTAssert([result isEqualToString:testString], @"Decoded data didn't produce the correct string");
    
    [uuTestSet enumerateKeysAndObjectsUsingBlock:^(NSString *testString, NSString *unixResult, BOOL *stop) {
        NSString *result = [[testString dataUsingEncoding:NSASCIIStringEncoding] ajr_uuEncodedStringWithFilename:@"test" andPosixFilePermissions:0644];
        XCTAssert([result isEqualToString:unixResult], @"FAILED: output:\n%@\nexpected:\n%@\n", result, unixResult);
    }];
    
    [uuTestSet enumerateKeysAndObjectsUsingBlock:^(NSString *testString, NSString *unixResult, BOOL *stop) {
        NSString *result = [[testString dataUsingEncoding:NSASCIIStringEncoding] ajr_uuEncodedString];
        NSRange range = [unixResult rangeOfString:@" 644 test"];
        NSString *finalExpected = [unixResult stringByDeletingCharactersInRange:range];
        XCTAssert([result isEqualToString:finalExpected], @"FAILED: output:\n%@\nexpected:\n%@\n", result, finalExpected);
    }];
    
    [uuTestSet enumerateKeysAndObjectsUsingBlock:^(NSString *testString, NSString *unixResult, BOOL *stop) {
        NSString *result = [[testString dataUsingEncoding:NSASCIIStringEncoding] ajr_uuEncodedStringWithFilename:@"test"];
        XCTAssert([result isEqualToString:unixResult], @"FAILED: output:\n%@\nexpected:\n%@\n", result, unixResult);
    }];
    
    [uuTestSet enumerateKeysAndObjectsUsingBlock:^(NSString *testString, NSString *unixResult, BOOL *stop) {
        NSError *localError = nil;
        NSData *data = [NSData ajr_dataWithUUEncodedString:unixResult error:&localError];
        XCTAssert(data != nil && localError == nil, @"Didn't expect an error, but got one: %@", [localError localizedDescription]);
        if (data) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            XCTAssert([string isEqualToString:testString]);
        }
    }];
    
    NSString *sampleWithError = @"begin 644 test\nA\n`\nend\n";
    NSError *localError;
    data = [NSData ajr_dataWithUUEncodedString:sampleWithError error:&localError];
    XCTAssert(data == nil && localError != nil);

    localError = nil;
    sampleWithError = @"begin 644 test\nAa\n`\nend\n";
    data = [NSData ajr_dataWithUUEncodedString:sampleWithError error:&localError];
    XCTAssert(data == nil && localError != nil);

    localError = nil;
    sampleWithError = @"begin 644 test\r\n&86%A86%A\r\n`\r\nend\r\n";
    data = [NSData ajr_dataWithUUEncodedString:sampleWithError error:&localError];
    XCTAssert(data != nil && localError == nil);
    XCTAssert([[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] isEqualToString:@"aaaaaa"]);
}

- (NSData *)sampleData {
    uint8_t *bytes = malloc(sizeof(uint8_t) * 300);
    for (NSInteger x = 0; x < 300; x++) {
        bytes[x] = (unsigned char)x;
    }
    return [[NSData alloc] initWithBytesNoCopy:bytes length:300 freeWhenDone:YES];
}

/* Produced by copying the verified output and running:
pbpaste | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk -F\t 'BEGIN { printf("static NSString * const dumpedString = ")} { if (NR == 1) { printf("@\"%s\\n\"\n", $1); } else { printf("                                       @\"%s\\n\"\n", $1); } }' | pbcopy
 */
static NSString * const dumpedString = @"000000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F ................\n"
                                       @"000010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F ................\n"
                                       @"000020: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F  !\"#$%&'()*+,-./\n"
                                       @"000030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F 0123456789:;<=>?\n"
                                       @"000040: 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F @ABCDEFGHIJKLMNO\n"
                                       @"000050: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F PQRSTUVWXYZ[\\]^_\n"
                                       @"000060: 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F `abcdefghijklmno\n"
                                       @"000070: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F pqrstuvwxyz{|}~.\n"
                                       @"000080: 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F ................\n"
                                       @"000090: 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F ................\n"
                                       @"0000A0: A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF  !\"#$%&'()*+,-./\n"
                                       @"0000B0: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF 0123456789:;<=>?\n"
                                       @"0000C0: C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF @ABCDEFGHIJKLMNO\n"
                                       @"0000D0: D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF PQRSTUVWXYZ[\\]^_\n"
                                       @"0000E0: E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF `abcdefghijklmno\n"
                                       @"0000F0: F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC FD FE FF pqrstuvwxyz{|}~.\n"
                                       @"000100: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F ................\n"
                                       @"000110: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F ................\n"
                                       @"000120: 20 21 22 23 24 25 26 27 28 29 2A 2B              !\"#$%&'()*+\n";

- (void)testDump {
    NSData *data = [self sampleData];
    
    [data ajr_dump]; // Just to get coverage.
    
    NSMutableData *mutableData = [NSMutableData data];
    AJRMemoryHandle *file = [[AJRMemoryHandle alloc] initWithMutableData:mutableData error:NULL];
    [data ajr_dumpToStream:file];
    
    NSString *string = [[NSString alloc] initWithData:mutableData encoding:NSUTF8StringEncoding];
    // Uncomment this line, verify the output, and then run the awk script above to regenerate dumpedString.
    //AJRPrintf(@"%@\n", string);
    XCTAssert([string isEqualToString:dumpedString]);
}

- (void)testXMLCoding {
    NSData *data = [self sampleData];
    NSData *archive = [AJRXMLArchiver archivedDataWithRootObject:data forKey:@"data"];
    NSError *localError;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:archive options:0 error:&localError];
    
    XCTAssert(document != nil);
    XCTAssert(localError == nil);
    
    const uint8_t bytes[] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
        0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,
        0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F,
        0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
                                                        0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
        0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
        0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
        0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F,
        0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F
    };
    NSString *encoded = AJRBase64EncodedString(bytes, sizeof(bytes) / sizeof(uint8_t), (NSRange){0, 72}, 0);
    XCTAssert([encoded isEqualToString:@"AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZH"]);
    AJRPrintf(@"test: %@\n", encoded);
    encoded = AJRBase64EncodedString(bytes, sizeof(bytes) / sizeof(uint8_t), (NSRange){72, 72}, 0);
    XCTAssert([encoded isEqualToString:@"SElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6P"]);
    AJRPrintf(@"test: %@\n", encoded);

    BOOL found = NO;
    for (NSXMLElement *element in [document children]) {
        if ([[element name] isEqualToString:@"data"]) {
            found = YES;
            NSMutableString *raw = [[element stringValue] mutableCopy];
            [raw replaceOccurrencesOfString:@" " withString:@"" options:0 range:(NSRange){0, [raw length]}];
            [raw replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:(NSRange){0, [raw length]}];
            
            localError = nil;
            NSData *decoded = [NSData ajr_dataWithBase64EncodedString:raw error:&localError];
            XCTAssert(decoded != nil);
            XCTAssert(localError == nil);
            XCTAssert([decoded isEqualToData:data]);
        }
    }
    XCTAssert(found);
}

- (void)testXMLCoding2 {
    NSError *localError = nil;
    NSData *data1 = [self sampleData];
    NSMutableData *data2 = [[self sampleData] mutableCopy];
    NSArray<NSData *> *containedData = @[data1, data1, data2];
    NSData *archivedData = [AJRXMLArchiver archivedDataWithRootObject:containedData];
    
    XCTAssert(data1 != nil);
    AJRPrintf(@"XML: %@\n", [[NSString alloc] initWithData:archivedData encoding:NSUTF8StringEncoding]);
    
    NSArray<NSData *> *decoded = [AJRXMLUnarchiver unarchivedObjectWithData:archivedData error:&localError];
    XCTAssert(decoded != nil);
    XCTAssert([decoded isKindOfClass:[NSArray class]]);
    XCTAssert([decoded[0] isKindOfClass:[NSData class]] && ![decoded[0] isKindOfClass:[NSMutableData class]]);
    XCTAssert([decoded[1] isKindOfClass:[NSData class]] && ![decoded[1] isKindOfClass:[NSMutableData class]]);
    XCTAssert(decoded[0] == decoded[1]);
    XCTAssert([decoded[2] isKindOfClass:[NSMutableData class]]);
 
    // Make sure class / name substitutions are working propertly
    archivedData = [AJRXMLArchiver archivedDataWithRootObject:data1 forKey:@"document"];
    AJRPrintf(@"XML: %@\n", [[NSString alloc] initWithData:archivedData encoding:NSUTF8StringEncoding]);
    XCTAssert(archivedData != nil);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:archivedData error:&localError];
    XCTAssert(decoded != nil);
    XCTAssert([decoded isEqual:data1]);
    
    // And with mutable data...
    archivedData = [AJRXMLArchiver archivedDataWithRootObject:[data1 mutableCopy] forKey:@"document"];
    AJRPrintf(@"XML: %@\n", [[NSString alloc] initWithData:archivedData encoding:NSUTF8StringEncoding]);
    XCTAssert(archivedData != nil);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:archivedData error:&localError];
    XCTAssert(decoded != nil);
    XCTAssert([decoded isEqual:data1]);
}

@end
