/*
NSString+ExtensionsTests.m
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
#import <wchar.h>

@interface NSString_ExtensionsTests : XCTestCase

@end

@implementation NSString_ExtensionsTests

- (void)testCharacterScanning {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFG"];
    NSString *output;
    
    output = [@"abcdefgABCDEFGabcdefg" stringContainingOnlyCharactersInSet:set];
    XCTAssert(output != nil && [output isEqualToString:@"ABCDEFG"]);
    
    output = [@"abcdefg" stringContainingOnlyCharactersInSet:set];
    XCTAssert(output != nil && [output isEqualToString:@""]);
    
    output = [@"" stringContainingOnlyCharactersInSet:set];
    XCTAssert(output != nil && [output isEqualToString:@""]);

    output = [@"ABCDEFGabcdefgABCDEFG" stringContainingOnlyCharactersInSet:set];
    XCTAssert(output != nil && [output isEqualToString:@"ABCDEFGABCDEFG"]);
    
    output = [@"ABCDEFG" stringContainingOnlyCharactersInSet:set];
    XCTAssert(output != nil && [output isEqualToString:@"ABCDEFG"]);

    output = [@"ABCDEFGabcdefgABCDEFG" ajr_stringByReplacingCharactersInSet:[set invertedSet] withCharacter:0x2370];
    XCTAssert(output != nil && [output isEqualToString:@"ABCDEFG⍰⍰⍰⍰⍰⍰⍰ABCDEFG"]);
}

- (void)testPaths {
    XCTAssert([[@"test.png" pathUTI] isEqualToString:@"public.png"]);
    XCTAssert([[@"test.png" pathMIMEType] isEqualToString:@"image/png"]);

    XCTAssert(@"".pathUTI == nil);
    XCTAssert(@"test".pathMIMEType == nil);
    
    NSString *savedCurrentPath = NSFileManager.defaultManager.currentDirectoryPath;
    [NSFileManager.defaultManager changeCurrentDirectoryPath:@"/tmp"];
    XCTAssert([@"test".canonicalizedPath isEqualToString:@"/private/tmp/test"]);
    [NSFileManager.defaultManager changeCurrentDirectoryPath:savedCurrentPath];
    
    XCTAssert([[@"test.tif" stringByReplacingPathExtension:@"tiff"] isEqualToString:@"test.tiff"]);
    
    XCTAssert([[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringWithPathRelativeTo:NSHomeDirectory()] isEqualToString:@"Library"]);
    XCTAssert([[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringWithPathRelativeTo:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]] isEqualToString:@"../Library"]);
}

- (void)testCapitalizedName {
    XCTAssert([[@"john" capitalizedName] isEqualToString:@"John"]);
    XCTAssert([[@"j" capitalizedName] isEqualToString:@"J"]);
    XCTAssert([[@"john smith" capitalizedName] isEqualToString:@"John smith"]);
}

- (void)testTitlecaseString {
    XCTAssert([[@"john" titlecaseString] isEqualToString:@"John"]);
    XCTAssert([[@"john smith" titlecaseString] isEqualToString:@"John Smith"]);
}

- (void)testWhitespaceDeletion {
    XCTAssert([[@"   john   \n" stringByDeletingLeadingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] isEqualToString:@"john   \n"]);
    XCTAssert([[@"john   \n" stringByDeletingLeadingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] isEqualToString:@"john   \n"]);
    XCTAssert([[@"   john   \n" stringByDeletingTrailingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] isEqualToString:@"   john"]);
}

- (void)testLongCharacters {
    NSString *input = @"😀😃😄😁😆😅😂áéíóú å äëïöü àèìòù ãõñ";
    NSData *data = [input dataUsingEncoding:NSUTF32LittleEndianStringEncoding];
    uint32_t *bytes = (uint32_t *)[data bytes];
    
    for (NSInteger x = 0, byteIndex = 0; x < [input length]; byteIndex++) {
        wchar_t character;
        NSInteger length;
        
        length = [input getLongCharacter:&character atIndex:x];
        XCTAssert(length != NSNotFound);
        XCTAssert(character == bytes[byteIndex], "bad character: %d: 0x%x != 0x%x", (int)x, (int)bytes[byteIndex], character);
        
        x += length;
    }
}

- (void)testNumberConversions {
    XCTAssert(AJRFormat(@"%d", INT_MAX).intValue == INT_MAX);
    XCTAssert(AJRFormat(@"%d", INT_MIN).intValue == INT_MIN);
    XCTAssert(AJRFormat(@"%u", UINT_MAX).unsignedIntValue == UINT_MAX);
    XCTAssert(AJRFormat(@"%ld", LONG_MAX).longValue == LONG_MAX);
    XCTAssert(AJRFormat(@"%ld", LONG_MIN).longValue == LONG_MIN);
    XCTAssert(AJRFormat(@"%lu", ULONG_MAX).unsignedLongValue == ULONG_MAX);
    XCTAssert(AJRFormat(@"%lld", LONG_LONG_MAX).longLongValue == LONG_LONG_MAX);
    XCTAssert(AJRFormat(@"%lld", LONG_LONG_MIN).longLongValue == LONG_LONG_MIN);
    XCTAssert(AJRFormat(@"%llu", ULONG_LONG_MAX).unsignedLongLongValue == ULONG_LONG_MAX);
    
    XCTAssert(@"1.234".timeIntervalValue == 1.234);
    XCTAssert(@"1s 234 ms".timeIntervalValue == 1.234);
    XCTAssert(@"12:01.234".timeIntervalValue == 721.234);
    XCTAssert(AJRApproximateEquals(@"01:12:01.234".timeIntervalValue, 4321.234, 5));
    XCTAssert(AJRApproximateEquals(@"2:01:12:01.234".timeIntervalValue, 177121.234, 5));
    XCTAssert(@"1234 ms".millisecondsValue == 1234);
    
    XCTAssert([[@"1" numberValue] isEqualToNumber:@(1)]);
    XCTAssert([[@"-1" numberValue] isEqualToNumber:@(-1)]);
    XCTAssert([AJRFormat(@"%d", INT8_MAX).numberValue isEqualToNumber:@(INT8_MAX)]);
    XCTAssert([AJRFormat(@"%d", INT8_MIN).numberValue isEqualToNumber:@(INT8_MIN)]);
    XCTAssert([AJRFormat(@"%d", INT16_MAX).numberValue isEqualToNumber:@(INT16_MAX)]);
    XCTAssert([AJRFormat(@"%d", INT16_MIN).numberValue isEqualToNumber:@(INT16_MIN)]);
    XCTAssert([AJRFormat(@"%lld", (long long)INT32_MAX).numberValue isEqualToNumber:@(INT32_MAX)]);
    XCTAssert([AJRFormat(@"%lld", (long long)INT32_MIN).numberValue isEqualToNumber:@(INT32_MIN)]);
    XCTAssert([AJRFormat(@"%lld", (long long)INT64_MAX).numberValue isEqualToNumber:@(INT64_MAX)]);
    XCTAssert([AJRFormat(@"%lld", (long long)INT64_MIN).numberValue isEqualToNumber:@(INT64_MIN)]);
    XCTAssert(AJRFormat(@"-%llu", (unsigned long long)UINT64_MAX).numberValue == nil); // Overflow!
    XCTAssert([@"1.234".numberValue isEqualToNumber:@(1.234)]);
    XCTAssert([@"-1.234".numberValue isEqualToNumber:@(-1.234)]);
    XCTAssert([@"1.234e3".numberValue isEqualToNumber:@(1.234e3)]);
    XCTAssert([@"-1.234e3".numberValue isEqualToNumber:@(-1.234e3)]);
    XCTAssert([@"1.234e-3".numberValue isEqualToNumber:@(1.234e-3)]);
    XCTAssert([@"-1.234e-3".numberValue isEqualToNumber:@(-1.234e-3)]);
    XCTAssert([@"1.2a".numberValue isEqualToNumber:@(1.2)]);
    XCTAssert([@"1.2.3".numberValue isEqualToNumber:@(1.2)]);
    XCTAssert([@".2".numberValue isEqualToNumber:@(.2)]);
    XCTAssert(@"--1".numberValue == nil);
    
    XCTAssert([@"10" int32ValueUsingBase:10] == 10);
    XCTAssert([@"10" int32ValueUsingBase:2] == 2);
    XCTAssert([@"10" int32ValueUsingBase:8] == 010);
    XCTAssert([@"10" int32ValueUsingBase:16] == 16);
    XCTAssert([@"1a" int32ValueUsingBase:16] == 0x1a);
    XCTAssert(@"1a".hexValue == 0x1a);
    XCTAssert(@"1a".longHexValue == 0x1a);
    XCTAssert(AJRFormat(@"%x", UINT32_MAX).unsignedLongHexValue == UINT32_MAX);
    XCTAssert(AJRFormat(@"%lx", INT64_MAX).longLongHexValue == INT64_MAX);
    XCTAssert(AJRFormat(@"%lx", UINT64_MAX).unsignedLongLongHexValue == UINT64_MAX);
    XCTAssert(@"Cherry 2000".trailingIntegerValue == 2000);
    NSRange found;
    XCTAssert([@"Cherry 2000" trailingIntegerValueFoundInRange:&found] == 2000 && found.location == 7 && found.length == 4);
    XCTAssert([@"Cherry" trailingIntegerValueFoundInRange:&found] == 0 && found.location == NSNotFound);
    
    XCTAssert(AJRFormat(@"%d", INT8_MIN).int8Value == INT8_MIN);
    XCTAssert(AJRFormat(@"%d", INT8_MAX).int8Value == INT8_MAX);
    XCTAssert(AJRFormat(@"%d", UINT8_MAX).unsignedInt8Value == UINT8_MAX);
    XCTAssert(AJRFormat(@"%d", INT8_MIN).charValue == INT8_MIN);
    XCTAssert(AJRFormat(@"%d", INT8_MAX).charValue == INT8_MAX);
    XCTAssert(AJRFormat(@"%d", UINT8_MAX).unsignedCharValue == UINT8_MAX);
    
    XCTAssert(AJRFormat(@"%d", INT16_MIN).int16Value == INT16_MIN);
    XCTAssert(AJRFormat(@"%d", INT16_MAX).int16Value == INT16_MAX);
    XCTAssert(AJRFormat(@"%d", UINT16_MAX).unsignedInt16Value == UINT16_MAX);
    XCTAssert(AJRFormat(@"%d", INT16_MIN).shortValue == INT16_MIN);
    XCTAssert(AJRFormat(@"%d", INT16_MAX).shortValue == INT16_MAX);
    XCTAssert(AJRFormat(@"%d", UINT16_MAX).unsignedShortValue == UINT16_MAX);
    
    XCTAssert(AJRFormat(@"%ld", INT32_MIN).int32Value == INT32_MIN);
    XCTAssert(AJRFormat(@"%ld", INT32_MAX).int32Value == INT32_MAX);
    XCTAssert(AJRFormat(@"%ld", UINT32_MAX).unsignedInt32Value == UINT32_MAX);
    XCTAssert(AJRFormat(@"%ld", UINT32_MAX).unsignedIntValue == UINT32_MAX);

    XCTAssert(AJRFormat(@"%ld", INT64_MIN).int64Value == INT64_MIN);
    XCTAssert(AJRFormat(@"%ld", INT64_MAX).int64Value == INT64_MAX);
    XCTAssert(AJRFormat(@"%ld", UINT64_MAX).unsignedInt64Value == UINT64_MAX);
    XCTAssert(AJRFormat(@"%lld", UINT64_MAX).unsignedIntegerValue == UINT64_MAX);

    XCTAssert(AJRApproximateEquals(AJRFormat(@"%lf", (long double)M_PI).longDoubleValue, M_PI, 5));
    
    XCTAssert([@"6/16/1971".dateValue isEqualToDate:[NSDate dateWithYear:1971 month:6 day:16 hour:0 minute:0 second:0 timeZone:nil]]);
    
    XCTAssert(@"123".isInteger);
    XCTAssert(!@"A123".isInteger);
    XCTAssert(!@"123A".isInteger);
    XCTAssert(!@"123.1".isInteger);
}

- (void)checkLineLength:(NSInteger)length in:(NSString *)output {
    [output enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        XCTAssert([line length] <= length);
    }];
}

- (void)checkString:(NSString *)input vs:(NSString *)output {
    NSMutableArray *array1 = [NSMutableArray array];
    NSMutableArray *array2 = [NSMutableArray array];
    [input enumerateSubstringsInRange:input.fullRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [array1 addObject:[substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }];
    [output enumerateSubstringsInRange:output.fullRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [array2 addObject:[substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }];
    XCTAssert([array1 isEqualToArray:array2]);
    if (![array1 isEqualToArray:array2]) {
        for (NSInteger x = 0; x < MAX(array1.count, array2.count); x++) {
            NSString *object1 = x < array1.count ? array1[x] : nil;
            NSString *object2 = x < array2.count ? array2[x] : nil;
            AJRPrintf(@"%4d: \"%@\" \"%@\"\n", (int)x, object1, object2);
        }
    }
}

static NSString *longString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut in semper dolor. Maecenas interdum est turpis, in gravida sem tincidunt ut. Nullam justo ante, mattis ut metus consectetur, consectetur vestibulum mi. Quisque efficitur elit ac consectetur varius. Nulla id erat odio. Etiam nulla quam, sagittis sit amet diam nec, efficitur ultricies ante. Suspendisse posuere lacus non nisl pretium, vitae congue odio laoreet. Nam eu arcu in nisl laoreet tempor vitae id felis. Donec fermentum erat quis sem venenatis ullamcorper. Praesent faucibus quam nec massa fermentum, finibus porta odio hendrerit. Etiam eget nisi pellentesque, tempus elit nec, commodo orci. Sed id nunc consectetur, scelerisque felis sed, laoreet ipsum. Curabitur et fermentum quam, sed posuere lacus. Donec eget felis ligula.\n\nProin in imperdiet tortor. Ut commodo arcu non dapibus convallis. Praesent vehicula leo vitae laoreet venenatis. Ut leo nibh, condimentum tempus aliquam et, rhoncus eu metus. Mauris bibendum condimentum arcu eget tincidunt. Nullam porttitor sollicitudin magna, in feugiat augue mollis at. Integer interdum ante vel libero maximus ultrices. Donec mollis ante mauris, quis tristique magna venenatis quis. Donec vel hendrerit velit, ut vehicula elit. Sed vestibulum nisi tellus, non aliquet ante blandit vel. Vestibulum suscipit, felis tempus vehicula eleifend, eros sapien blandit quam, ac luctus arcu massa eget nunc. Vestibulum ac accumsan ante, nec sollicitudin ex. Phasellus varius arcu eget tellus eleifend imperdiet. Etiam feugiat ullamcorper sem eu euismod.\n\nAenean est nisl, cursus ut iaculis non, eleifend at odio. Quisque et aliquet turpis. Fusce sed neque turpis. Aliquam gravida arcu vitae feugiat condimentum. Maecenas facilisis tempus dolor sollicitudin porttitor. Nulla et auctor dolor, at condimentum risus. Fusce nec ante sed lectus maximus dictum scelerisque vitae orci. Praesent id erat pharetra, fringilla erat eu, tristique arcu. Donec nec odio risus.\n";

- (void)testStringWrapping {
    NSString *input = longString;

    NSString *output = [input stringByWrappingToWidth:80];
    
    [self checkLineLength:80 in:output];
    [self checkString:input vs:output];

    //        00000000011111111112222222222333333333444444444445555555555666666666677777777778
    //        12345678901234567890123456789012345678901234567890123456789012345678901234567890
    input = @"0 1 2 3 4 5 6 7 8 9 a b c d e f g h j k l m n o p q r s t u v w x y z A B C D EE\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea <a href=\"http://www.apple.com\">commodo consequat. Duis aute</a> irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nhttp://this/is/a/really/long/url/that/we/want/to/see/if/it/gets/split/by/the/algorigthm with some more text.\n\nhttp://this/is/a/really/long/url/that/we/want/to/see/if/it/gets/split/by/the/algorigthm\n\nAenean est nisl, cursus ut iaculis non, eleifend at odio. Quisque et<testing_a_long_tag>aliquet turpis. Fusce sed neque turpis. Aliquam gravida arcu vitae feugiat condimentum. Maecenas facilisis tempus dolor sollicitudin porttitor. Nulla et auctor dolor, at condimentum risus. Fusce nec ante sed lectus maximus dictum scelerisque vitae orci. Praesent id erat pharetra, fringilla erat eu, tristique arcu. Donec nec odio risus.\n";
    output = [input stringByWrappingToWidth:80 withLineSeparator:@"\n" splitURLs:NO];
    [output enumerateSubstringsInRange:output.fullRange options:NSStringEnumerationByLines usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        AJRPrintf(@"%2d: %@\n", (int)substring.length, substring);
    }];
    [self checkString:input vs:output];
    output = [input stringByWrappingToWidth:80 withLineSeparator:@"\n" splitURLs:YES];
    [self checkLineLength:80 in:output];
}

- (void)testEscapingHTML {
    XCTAssert([[@"This is a string with < and > and & in it." stringByEscapingHTML] isEqualToString:@"This is a string with &lt; and &gt; and &amp; in it."]);
}

- (void)testWordAtIndex {
    NSString *input = @"Now is the time for all good men to come to the aid of their country.";
    
    [input enumerateSubstringsInRange:input.fullRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        for (NSInteger x = substringRange.location; x < NSMaxRange(substringRange); x++) {
            NSString *word = [input wordAtIndex:x];
            XCTAssert([word isEqualToString:substring], @"%@: %d: %@ vs. %@", NSStringFromRange(substringRange), (int)x, substring, word);
        }
    }];
}

- (void)testSearching {
    XCTAssert([@"Now is the time." hasCaseInsensitivePrefix:@"now"]);
    XCTAssert(![@"Now is the time." hasCaseInsensitivePrefix:@"now is the time for all..."]);
    XCTAssert([@"Now is the time." hasCaseInsensitivePrefix:@"nOw"]);
    XCTAssert([@"Now is the time." hasCaseInsensitiveSuffix:@"TIME."]);
    XCTAssert(![@"Now is the time." hasCaseInsensitiveSuffix:@"now is the time for all..."]);
    
    XCTAssert([@"Hi mom!" indexOfSubstring:@"mom"] == 3);
    XCTAssert([@"Hi mom!" indexOfSubstring:@"dad"] == NSNotFound);

    XCTAssert([[@"Hi mom!" substringUpToSubstring:@"mom"] isEqualToString:@"Hi "]);
    XCTAssert([@"Hi mom!" substringUpToSubstring:@"dad"] == nil);
}

- (void)testHTMLString {
    XCTAssert([@"This is\nan HTML string & I want to\ntest >it<!".htmlString isEqualToString:@"This is<br>an HTML string &amp; I want to<br>test &gt;it&lt;!"]);
    XCTAssert([@"".htmlString isEqualToString:@""]);
}

- (void)testUnicodeConveniences {
    unichar test1[] = { 'S', 't', 'r', 'i', 'n', 'g', 0 };
    unichar *test2;
    NSString *string = [NSString stringWithUnicodeString:test1];
    XCTAssert([string isEqualToString:@"String"]);

    test2 = [string unicodeString];
    XCTAssert(ustrcmp(test1, test2) == 0);
    
    wchar_t *test3 = L"String";
    wchar_t *test4;
    string = [NSString stringWithUnicode32String:test3];
    XCTAssert([string isEqualToString:@"String"]);
    test4 = [string unicode32String];
    XCTAssert(wcscmp(test3, test4) == 0);
    
    // Try the above test again, but slap on the UTF-32 BOM marker for explicit endianness.
    wchar_t test5[10] = L"_String";
    test5[0] = 0x0000FEFF;
    string = [NSString stringWithUnicode32String:test5];
    XCTAssert([string isEqualToString:@"String"]);
}

- (void)testRawBytes {
    uint8_t bytes[256];
    NSString *string;
    
    for (NSInteger x = 0; x < 256; x++) {
        bytes[x] = x;
    }
    
    string = [NSString stringWithRawBytes:bytes length:sizeof(bytes)];
    
    const uint8_t *bytesOut = [string rawBytes];
    for (NSInteger x = 0; x < sizeof(bytes); x++) {
        XCTAssert(bytes[x] == bytesOut[x]);
        if (bytes[x] != bytesOut[x]) {
            // Only really need one failure.
            break;
        }
    }
    
    NSError *localError;
    NSString *file = [NSFileManager.defaultManager temporaryFilename];
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    XCTAssert([data writeToFile:file atomically:YES]);
    string = [NSString stringWithRawContentsOfFile:file error:&localError];
    XCTAssert(string != nil);
    XCTAssert(localError == nil);
    bytesOut = [string rawBytes];
    for (NSInteger x = 0; x < sizeof(bytes); x++) {
        XCTAssert(bytes[x] == bytesOut[x]);
        if (bytes[x] != bytesOut[x]) {
            // Only really need one failure.
            break;
        }
    }
    [NSFileManager.defaultManager removeItemAtPath:file error:NULL];

    NSURL *url = [NSURL fileURLWithPath:file];
    XCTAssert([data writeToURL:url atomically:YES]);
    string = [NSString stringWithRawContentsOfURL:url error:&localError];
    XCTAssert(string != nil);
    XCTAssert(localError == nil);
    bytesOut = [string rawBytes];
    for (NSInteger x = 0; x < sizeof(bytes); x++) {
        XCTAssert(bytes[x] == bytesOut[x]);
        if (bytes[x] != bytesOut[x]) {
            // Only really need one failure.
            break;
        }
    }
    [NSFileManager.defaultManager removeItemAtPath:file error:NULL];
}

- (void)testErrorCodes {
    XCTAssert([[NSString stringWithErrorCode:EACCES] isEqualToString:@"Permission denied"]);
}

- (void)testRandomStrings {
    NSString *test;
    
    test = [NSString randomString];
    XCTAssert(test.length == 10);
    
    test = [NSString randomStringOfLength:20];
    XCTAssert(test.length == 20);
    
    NSMutableSet *check = [NSMutableSet set];
    for (NSInteger x = 0; x < 10; x++) {
        test = [NSString randomStringUsingPattern:@"$$$-$$-$$$"];
        XCTAssert(test.length == 10);
        XCTAssert(![check containsObject:test], @"Already generated %@", test);
        [check addObject:test];
    }
    [check removeAllObjects];

    for (NSInteger x = 0; x < 10; x++) {
        test = [NSString randomStringUsingPattern:@"\\AaA#@$Xx"];
        XCTAssert(test.length == 8);
        XCTAssert(![check containsObject:test], @"Already generated %@", test);
        [check addObject:test];
    }
    [check removeAllObjects];
}

- (void)testCommaDelimitedStrings {
    NSArray *result;
    
    result = [@"a,b,c,d" commaSeparatedComponents];
    XCTAssert([result[0] isEqualToString:@"a"]);
    XCTAssert([result[1] isEqualToString:@"b"]);
    XCTAssert([result[2] isEqualToString:@"c"]);
    XCTAssert([result[3] isEqualToString:@"d"]);
    result = [@"\"a, b\",\"c, d\",\"e, f\",\"g, h\"" commaSeparatedComponents];
    XCTAssert([result[0] isEqualToString:@"a, b"]);
    XCTAssert([result[1] isEqualToString:@"c, d"]);
    XCTAssert([result[2] isEqualToString:@"e, f"]);
    XCTAssert([result[3] isEqualToString:@"g, h"]);
    result = [@"\"John \"\"Johnny\"\" Smith\",\"c, d\",\"e, f\",\"g, h\"" commaSeparatedComponents];
    XCTAssert([result[0] isEqualToString:@"John \"Johnny\" Smith"]);
    XCTAssert([result[1] isEqualToString:@"c, d"]);
    XCTAssert([result[2] isEqualToString:@"e, f"]);
    XCTAssert([result[3] isEqualToString:@"g, h"]);
}

- (void)testDeleting {
    XCTAssert([[@"This is a test" stringByDeletingPrefix:@"This"] isEqualToString:@" is a test"]);
    XCTAssert([[@"This is a test" stringByDeletingPrefix:@"Goober"] isEqualToString:@"This is a test"]);
    XCTAssert([[@"This" stringByDeletingPrefix:@"This"] isEqualToString:@""]);
    XCTAssert([[@"Thi" stringByDeletingPrefix:@"This"] isEqualToString:@"Thi"]);
    XCTAssert([[@"This is a test" stringByDeletingSuffix:@"test"] isEqualToString:@"This is a "]);
    XCTAssert([[@"This is a test" stringByDeletingSuffix:@"Goober"] isEqualToString:@"This is a test"]);
    XCTAssert([[@"test" stringByDeletingSuffix:@"test"] isEqualToString:@""]);
    XCTAssert([[@"est" stringByDeletingSuffix:@"test"] isEqualToString:@"est"]);
    XCTAssert([[@"This is a test" stringByDeletingCharactersInRange:NSMakeRange(5, 5)] isEqualToString:@"This test"]);
}

- (void)testHexEncoding {
    NSData *data;
    const uint8_t *bytes;

    data = [@"0123456789abcdef" dataFromHexEncodedString];
    bytes = data.bytes;
    XCTAssert(data.length == 8);
    XCTAssert(bytes[0] == 0x01);
    XCTAssert(bytes[1] == 0x23);
    XCTAssert(bytes[2] == 0x45);
    XCTAssert(bytes[3] == 0x67);
    XCTAssert(bytes[4] == 0x89);
    XCTAssert(bytes[5] == 0xAB);
    XCTAssert(bytes[6] == 0xCD);
    XCTAssert(bytes[7] == 0xEF);

    data = [@"0123456789ABCDEF" dataFromHexEncodedString];
    bytes = data.bytes;
    XCTAssert(data.length == 8);
    XCTAssert(bytes[0] == 0x01);
    XCTAssert(bytes[1] == 0x23);
    XCTAssert(bytes[2] == 0x45);
    XCTAssert(bytes[3] == 0x67);
    XCTAssert(bytes[4] == 0x89);
    XCTAssert(bytes[5] == 0xAB);
    XCTAssert(bytes[6] == 0xCD);
    XCTAssert(bytes[7] == 0xEF);
    
    data = [@"12345" dataFromHexEncodedString];
    bytes = data.bytes;
    XCTAssert(data.length == 2);
    XCTAssert(bytes[0] == 0x12);
    XCTAssert(bytes[1] == 0x34);
    
    data = [@"hi mom" dataFromHexEncodedString];
    XCTAssert(data == nil);
    
    data = [@"1234 hi mom" dataFromHexEncodedString];
    bytes = data.bytes;
    XCTAssert(data.length == 2);
    XCTAssert(bytes[0] == 0x12);
    XCTAssert(bytes[1] == 0x34);
}

- (void)testWordCounts {
    XCTAssert(@"Now is the time for all good men to come to the aid of their country.".wordCount == 16);
    XCTAssert(@"Now! (is) the [time for] all good men/to come to-the aid of their country.".wordCount == 16);
}

static NSStringEncoding encodings[] = {
    NSASCIIStringEncoding,
    NSNEXTSTEPStringEncoding,
    NSJapaneseEUCStringEncoding,
    NSUTF8StringEncoding,
    NSISOLatin1StringEncoding,
    NSSymbolStringEncoding,
    NSShiftJISStringEncoding,
    NSISOLatin2StringEncoding,
    NSUnicodeStringEncoding,
    NSWindowsCP1251StringEncoding,
    NSWindowsCP1252StringEncoding,
    NSWindowsCP1253StringEncoding,
    NSWindowsCP1254StringEncoding,
    NSWindowsCP1250StringEncoding,
    NSISO2022JPStringEncoding,
    NSMacOSRomanStringEncoding,
    NSUTF16StringEncoding,
    NSUTF16BigEndianStringEncoding,
    NSUTF16LittleEndianStringEncoding,
    NSUTF32StringEncoding,
    NSUTF32BigEndianStringEncoding,
    NSUTF32LittleEndianStringEncoding,
};

- (void)testStringEncodingNames {
    NSMutableArray *names = [NSMutableArray array];
    
    for (NSInteger x = 0; x < AJRCountOf(encodings); x++) {
        NSString *characterSetName = AJRIANANameFromStringEncoding(encodings[x]);
        XCTAssert(characterSetName != nil);
        [names addObject:@{@"name":characterSetName, @"encoding":@(encodings[x])}];
    }
    
    for (NSDictionary *entry in names) {
        NSString *name = entry[@"name"];
        NSStringEncoding expected = ((NSNumber *)entry[@"encoding"]).integerValue;
        NSStringEncoding found = AJRStringEncodingFromIANAName(name);
        XCTAssert(expected == found);
    }
    
    // Finally make sure invalid is returned when appropriate...
    XCTAssert(AJRStringEncodingFromIANAName(@"invalid") == kCFStringEncodingInvalidId);
}

- (void)testStringCreation {
    XCTAssert([[NSString stringWithCString:"Raftis" length:6 encoding:NSUTF8StringEncoding] isEqualToString:@"Raftis"]);
}

- (void)testCryptography {
    XCTAssert([[@"Raftis" stringByCryptingWithSalt:@"AJ"] isEqualToString:@"AJfpQoRn4PhGs"]);
    // Even though deprecated, we still test.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    XCTAssert([@"Raftis".md5Hash isEqualToString:@"90913c9912aa305a48c00a7fecedb271"]);
    XCTAssert([longString.md5Hash isEqualToString:@"d66d580ba973f037112d18253b4e0e9e"]);
#pragma clang diagnostic pop
}

@end
