/*
 NSString+Extensions.m
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

#import "NSString+Extensions.h"

#import "AJRAutoreleasedMemory.h"
#import "AJRFunctions.h"
#import "AJRUnicode.h"
#import "NSDate+Extensions.h"
#import "NSMutableString+Extensions.h"
#import "NSNumber+Extensions.h"
#import "NSScanner+Extensions.h"

#import <stdlib.h>
#import <wchar.h>
#define COMMON_DIGEST_FOR_OPENSSL
#import <CommonCrypto/CommonDigest.h>
#define SHA1 CC_SHA1
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation NSString (AJRExtensions)

#pragma mark - Conveniences

- (NSRange)fullRange {
    return (NSRange){0, self.length};
}

#pragma mark - File Paths

- (NSString *)pathUTI {
    return AJRUTIForPathExtension([self pathExtension]);
}

- (NSString *)pathMIMEType {
    NSString *extension = [self pathExtension];
    NSString *mimeType = nil;
    if (extension) {
        UTType *type = [UTType typeWithFilenameExtension:self.pathExtension];
        if (type != nil) {
            mimeType = type.preferredMIMEType;
        }
    }
    return mimeType;
}

- (NSString *)canonicalizedPath {
    NSString *path = self;

    if (![path isAbsolutePath]) {
        path = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:path];
    }
    path = [path stringByStandardizingPath];

    return path;
}

- (NSString *)stringByReplacingPathExtension:(NSString *)newExtension {
    return [[self stringByDeletingPathExtension] stringByAppendingPathExtension:newExtension];
}

- (NSString *)stringWithPathRelativeTo:(NSString *)anchorPath {
    NSArray *pathComponents = [self pathComponents];
    NSArray *anchorComponents = [anchorPath pathComponents];

    NSInteger componentsInCommon = MIN([pathComponents count], [anchorComponents count]);
    for (NSInteger i = 0, n = componentsInCommon; i < n; i++) {
        if (![[pathComponents objectAtIndex:i] isEqualToString:[anchorComponents objectAtIndex:i]]) {
            componentsInCommon = i;
            break;
        }
    }

    NSUInteger numberOfParentComponents = [anchorComponents count] - componentsInCommon;
    NSUInteger numberOfPathComponents = [pathComponents count] - componentsInCommon;

    NSMutableArray *relativeComponents = [NSMutableArray arrayWithCapacity:numberOfParentComponents + numberOfPathComponents];
    for (NSInteger i = 0; i < numberOfParentComponents; i++) {
        [relativeComponents addObject:@".."];
    }
    [relativeComponents addObjectsFromArray:[pathComponents subarrayWithRange:NSMakeRange(componentsInCommon, numberOfPathComponents)]];

    return [NSString pathWithComponents:relativeComponents];
}

- (NSString *)stringByAppendingPathComponents:(NSArray<NSString *> *)components {
    NSString *result = self;
    for (NSString *component in components) {
        result = [result stringByAppendingPathComponent:component];
    }
    return result;
}

#pragma mark - Transformations

- (NSString *)capitalizedName {
    if ([self length] > 1) {
        return [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] capitalizedString], [self substringFromIndex:1]];
    }

    return [self capitalizedString];
}

- (NSString *)titlecaseString COMMON_DIGEST_FOR_OPENSSL {
    NSMutableString *newString = [self mutableCopy];

    [newString enumerateSubstringsInRange:(NSRange){0, [newString length]} options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        [newString replaceCharactersInRange:substringRange withString:[[substring lowercaseString] capitalizedString]];
    }];

    return newString;
}

- (NSString *)stringContainingOnlyCharactersInSet:(NSCharacterSet *)set {
    return [self ajr_stringByReplacingCharactersInSet:[set invertedSet] withCharacter:0];
}

- (NSString *)ajr_stringByReplacingCharactersInSet:(NSCharacterSet *)set withCharacter:(wchar_t)character {
    NSData *data = [self dataUsingEncoding:AJRUTF32StringEncodingMatchingArchitecture];
    const wchar_t *buffer = (wchar_t *)data.bytes;
    NSInteger length = data.length / 4;
    NSString *newString = nil;

    if (data != nil && data.length > 0) {
        wchar_t *outputBuffer = NSZoneMalloc(NULL, sizeof(wchar_t) * length);
        NSInteger y = 0;

        for (NSInteger x = 0; x < length; x++) {
            wchar_t c = buffer[x];
            if ([set longCharacterIsMember:c]) {
                if (character != 0) {
                    outputBuffer[y++] = character;
                }
            } else {
                outputBuffer[y++] = c;
            }
        }
        newString = [[NSString alloc] initWithBytes:outputBuffer length:y * sizeof(wchar_t) encoding:AJRUTF32StringEncodingMatchingArchitecture];
        NSZoneFree(NULL, outputBuffer);
    }

    return newString ?: @"";
}

- (NSString*)stringByDeletingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSString *substring = self;
    NSRange characterRange;

    while (1) {
        characterRange = [substring rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch];
        if (characterRange.length && characterRange.location + characterRange.length == [substring length]) {
            substring = [substring substringToIndex:characterRange.location];
        } else {
            break;
        }
    }

    return substring;
}

- (NSString *)stringByDeletingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];

    if ([scanner scanCharactersFromSet:characterSet intoString:NULL]) {
        return [self substringFromIndex:[scanner scanLocation]];
    } else {
        return self;
    }
}

- (NSString *)stringByDeletingPrefix:(NSString *)other {
    if ([self hasPrefix:other]) {
        return [self substringFromIndex:[other length]];
    }

    return self;
}

- (NSString *)stringByDeletingSuffix:(NSString *)other {
    if ([self hasSuffix:other]) {
        return [self substringToIndex:self.length - other.length];
    }

    return self;
}

- (NSString *)stringByDeletingCharactersInRange:(NSRange)range {
    return [[self substringToIndex:range.location] stringByAppendingString:[self substringFromIndex:range.location + range.length]];
}

#pragma mark - Word Wrapping

- (NSInteger)splitPointForLine:(NSString *)line width:(NSInteger)width splitURLs:(BOOL)flag {
    static NSCharacterSet *splitCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Should include '-', but I was having another issue that needed quick resolution.
        splitCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t"];
    });
    NSRange subrange = NSMakeRange(0, width);
    NSString *substring = [line substringWithRange:subrange];

    if (!flag && [line hasPrefix:@"http://"]) {
        subrange = [line rangeOfCharacterFromSet:splitCharacterSet];
        if (subrange.length) {
            if (subrange.location + subrange.length > width) {
                return subrange.location + subrange.length - 1;
            }
        } else {
            return [line length];
        }
    }

    subrange = [substring rangeOfCharacterFromSet:splitCharacterSet options:NSBackwardsSearch];
    if (subrange.location != NSNotFound) {
        width = subrange.location + subrange.length;

        if (!flag) {
            NSRange one = [substring rangeOfString:@"<" options:NSBackwardsSearch];
            if (one.location != NSNotFound && one.location > width) {
                NSRange two = [substring rangeOfString:@">" options:NSBackwardsSearch];
                if (two.location == NSNotFound) {
                    two = [line rangeOfString:@">" options:0 range:(NSRange){width, [line length] - width}];
                    if (two.location != NSNotFound) {
                        return two.location + two.length;
                    }
                }
            }
        }

        return width;
    } else {
        return width;
    }
}

- (NSString*)stringByWrappingToWidth:(NSInteger)width withLineSeparator:(NSString *)separator {
    return [self stringByWrappingToWidth:width withLineSeparator:separator splitURLs:YES];
}

- (NSString*)stringByWrappingToWidth:(NSInteger)width withLineSeparator:(NSString *)separator splitURLs:(BOOL)flag {
    NSMutableArray *lines = [[self componentsSeparatedByString:separator] mutableCopy];
    NSMutableString *newString = [NSMutableString string];
    NSInteger i;
    NSInteger count = [lines count];

    for (i = 0; i < count; i++) {
        NSString *line = [lines objectAtIndex:i];

        if (![line length] && i + 1 < count) {
            [newString appendString:separator];
        }
        while ([line length] > width) {
            NSInteger splitPoint = [self splitPointForLine:line width:width splitURLs:flag];

            [newString appendString:[[line substringToIndex:splitPoint] stringByDeletingTrailingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            line = [[line substringFromIndex:splitPoint] stringByDeletingLeadingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [newString appendString:separator];
        }
        if ([line length]) {
            [newString appendString:line];
            if (i + 1 < count) {
                [newString appendString:separator];
            }
        }
    }
    return newString;
}

- (NSString*)stringByWrappingToWidth:(NSInteger)width {
    return [self stringByWrappingToWidth:width withLineSeparator:@"\n"];
}

#pragma mark - Words

- (NSString *)wordAtIndex:(NSUInteger)index {
    return [self wordAtIndex:index range:NULL];
}

- (NSString *)wordAtIndex:(NSUInteger)index range:(NSRangePointer)returnRange {
    __block NSString *foundSubstring = nil;
    __block NSRange range;
    if (index == 0) {
        // We're at the beginning, so no reason to back up.
        range = self.fullRange;
    } else {
        // Back up to the first word break, so we can then search forward from that point.
        [self enumerateSubstringsInRange:(NSRange){0, index} options:NSStringEnumerationByWords | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL * stop) {
            *stop = YES;
            range.location = substringRange.location;
            range.length = self.length - range.location;
        }];
    }
    // Now enumerate forward.
    [self enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if (NSLocationInRange(index, substringRange)) {
            *stop = YES;
            AJRSetOutParameter(returnRange, substringRange);
            foundSubstring = substring;
        }
    }];
    return foundSubstring;
}

#pragma mark - Substring Searching

- (BOOL)hasCaseInsensitivePrefix:(NSString *)prefix {
    NSRange range = prefix.fullRange;

    return range.length <= self.length ? [self compare:prefix options:NSCaseInsensitiveSearch range:range] == NSOrderedSame : NO;
}

- (BOOL)hasCaseInsensitiveSuffix:(NSString *)suffix {
    NSRange range = suffix.fullRange;

    if (range.length > self.length) {
        return NO;
    } else {
        range.location = self.length - range.length;
    }

    return [self compare:suffix options:NSCaseInsensitiveSearch range:range] == NSOrderedSame;
}

- (NSUInteger)indexOfSubstring:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return range.location;
}

- (NSString *)substringUpToSubstring:(NSString *)string {
    NSUInteger index = [self indexOfSubstring:string];
    return index == NSNotFound ? nil : [self substringToIndex:index];
}

#pragma mark - HTML

- (NSString *)stringByEscapingHTML {
    NSMutableString *new = [self mutableCopy];
    [new replaceHTMLSpecialCharactersWithEntityNames];
    return new;
}

- (NSString *)htmlString {
    NSRange range;
    NSMutableString *work;
    NSInteger length;

    if ([self length] == 0) {
        return self;
    }

    work = [self mutableCopy];
    [work replaceHTMLSpecialCharactersWithEntityNames];
    length = work.length;
    range = (NSRange){0, length};
    while ((range = [work rangeOfString:@"\n" options:0 range:range]).length != 0) {
        [work replaceCharactersInRange:range withString:@"<br>"];
        range.location = range.location + 8;
        range.length = length - range.location;
    }

    return work;
}

#pragma mark - Unicode Conveniences

+ (id)stringWithUnicodeString:(unichar *)characters {
    return [[self alloc] initWithUnicodeString:characters];
}

- (id)initWithUnicodeString:(unichar *)characters {
    return [self initWithCharacters:characters length:ustrlen(characters)];
}

+ (id)stringWithUnicode32String:(wchar_t *)characters {
    return [[self alloc] initWithUnicode32String:characters];
}

- (id)initWithUnicode32String:(wchar_t *)characters {
    uint8_t *bytes = (uint8_t *)characters;
    size_t length = wcslen(characters);
    if ((bytes[0] == 0xFF && bytes[1] == 0xFE && bytes[2] == 0x00 && bytes[3] == 0x00)
        || (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0xFE && bytes[3] == 0xFF)) {
        return [self initWithBytes:bytes length:length * sizeof(wchar_t) encoding:NSUTF32StringEncoding];
    } else {
        return [self initWithBytes:bytes length:length * sizeof(wchar_t) encoding:AJRUTF32StringEncodingMatchingArchitecture];
    }
}

- (unichar *)unicodeString {
    unichar *characters = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:(self.length + 1) * sizeof(unichar)];
    [self getCharacters:characters];
    characters[self.length] = 0;
    return characters;
}

- (wchar_t *)unicode32String {
    NSData *data = [self dataUsingEncoding:AJRUTF32StringEncodingMatchingArchitecture];
    // Size is data length + 1 (4 bytes) for the null termination.
    wchar_t *characters = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:data.length + sizeof(wchar_t) alignment:sizeof(wchar_t)];

    memcpy(characters, data.bytes, data.length);
    characters[self.length] = 0;
    return characters;
}

#pragma mark - Raw Byte Handling

+ (id)stringWithRawBytes:(const uint8_t *)bytes length:(NSUInteger)length {
    return [[self alloc] initWithRawBytes:bytes length:length];
}

- (id)initWithRawBytes:(const uint8_t *)bytes length:(NSUInteger)length {
    unichar *buffer;
    NSInteger x;

    buffer = (unichar *)NSZoneMalloc(nil, sizeof(unichar) * length);
    for (x = 0; x < length; x++) {
        buffer[x] = bytes[x];
    }

    return [self initWithCharactersNoCopy:buffer length:length freeWhenDone:YES];
}

+ (id)stringWithRawContentsOfFile:(NSString *)path error:(out NSError **)error {
    return [[self alloc] initWithRawContentsOfFile:path error:error];
}

+ (id)stringWithRawContentsOfURL:(NSURL *)url error:(out NSError **)error {
    return [[self alloc] initWithRawContentsOfURL:url error:error];
}

- (id)initWithRawContentsOfFile:(NSString *)path error:(out NSError **)error {
    return [self initWithRawContentsOfURL:[NSURL fileURLWithPath:path] error:error];
}

- (id)initWithRawContentsOfURL:(NSURL *)url error:(out NSError **)error {
    NSError *localError;
    NSData *data = [[NSData alloc] initWithContentsOfURL:url options:0 error:&localError];
    NSString *returnValue = nil;

    if (data != nil) {
        returnValue = [self initWithRawBytes:[data bytes] length:[data length]];
    }

    return AJRAssertOrPropagateError(returnValue, error, localError);
}

- (NSData *)rawData {
    unsigned char *buffer;
    NSInteger x, max = [self length];

    buffer = (unsigned char *)NSZoneMalloc(nil, sizeof(unsigned char) * max);
    for (x = 0; x < max; x++) {
        buffer[x] = (unsigned char)[self characterAtIndex:x];
    }

    return [[NSData allocWithZone:nil] initWithBytesNoCopy:buffer length:max freeWhenDone:YES];
}

- (const unsigned char *)rawBytes {
    return [[self rawData] bytes];
}

#pragma mark - OS Error Messages

+ (NSString *)stringWithErrorCode:(int)errorCode {
#ifdef WIN32
    HMODULE module = NULL; // default to system source
    LPSTR messageBuffer;
    DWORD bufferLength;
    DWORD dwFormatFlags;
    NSString *errorMessage = nil;

    dwFormatFlags = FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM;

    // If errorCode is in the network range, load the message source.

    if ((errorCode >= NERR_BASE) && (errorCode <= MAX_NERR)) {
        module = LoadLibraryEx(TEXT("netmsg.dll"), NULL, LOAD_LIBRARY_AJR_DATAFILE);
        if (module != NULL) {
            dwFormatFlags |= FORMAT_MESSAGE_FROM_HMODULE;
        }
    }

    // Call FormatMessage() to allow for message text to be acquired from the system or from the supplied module handle.

    if ((bufferLength = FormatMessageA(dwFormatFlags,
                                       module, // module to get message from (NULL == system)
                                       errorCode,
                                       MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // default language
                                       (LPSTR) &messageBuffer,
                                       0,
                                       NULL))) {
        // Output message string on stderr.
        errorMessage = [NSString stringWithCString:messageBuffer length:bufferLength];

        // Free the buffer allocated by the system.
        LocalFree(messageBuffer);
    } else {
        errorMessage = [NSString stringWithCString:strerror(errorCode)];
    }

    // If we loaded a message source, unload it.
    if (module != NULL) {
        FreeLibrary(module);
    }

    return errorMessage;
#else
    return [NSString stringWithCString:(const char *)strerror(errorCode) encoding:NSUTF8StringEncoding];
#endif
}

typedef NS_ENUM(uint8_t, AJRCharacterType) {
    AJRCharacterTypeNumeric,
    AJRCharacterTypeUppercaseAlpha,
    AJRCharacterTypeLowercaseAlpha,
    AJRCharacterTypeAlpha,
    AJRCharacterTypeAlphanumeric,
    AJRCharacterTypeUppercaseAlphanumeric,
    AJRCharacterTypeLowercaseAlphanumeric,
};

static const unichar AJRRandomStringNumericCharacterSet[] = {
    '0','1','2','3','4','5','6','7','8','9'
};

static const unichar AJRRandomStringUppercaseAlphaCharacterSet[] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
};

static const unichar AJRRandomStringLowercaseAlphaCharacterSet[] = {
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
};

static const unichar AJRRandomStringAlphaCharacterSet[] = {
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
};

static const unichar AJRRandomStringAlphanumericCharacterSet[] = {
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    '0','1','2','3','4','5','6','7','8','9'
};

static const unichar AJRRandomStringUppercaseAlphanumericCharacterSet[] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    '0','1','2','3','4','5','6','7','8','9'
};

static const unichar AJRRandomStringLowercaseAlphanumericCharacterSet[] = {
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5','6','7','8','9'
};

static unichar _AJRRandomCharacterForType(AJRCharacterType type) {
    const unichar *set = NULL;
    NSInteger length = 0;

    switch (type) {
        case AJRCharacterTypeNumeric:
            set = AJRRandomStringNumericCharacterSet;
            length = AJRCountOf(AJRRandomStringNumericCharacterSet);
            break;
        case AJRCharacterTypeAlpha:
            set = AJRRandomStringAlphaCharacterSet;
            length = AJRCountOf(AJRRandomStringAlphaCharacterSet);
            break;
        case AJRCharacterTypeUppercaseAlpha:
            set = AJRRandomStringUppercaseAlphaCharacterSet;
            length = AJRCountOf(AJRRandomStringUppercaseAlphaCharacterSet);
            break;
        case AJRCharacterTypeLowercaseAlpha:
            set = AJRRandomStringLowercaseAlphaCharacterSet;
            length = AJRCountOf(AJRRandomStringLowercaseAlphaCharacterSet);
            break;
        case AJRCharacterTypeAlphanumeric:
            set = AJRRandomStringAlphanumericCharacterSet;
            length = AJRCountOf(AJRRandomStringAlphanumericCharacterSet);
            break;
        case AJRCharacterTypeUppercaseAlphanumeric:
            set = AJRRandomStringUppercaseAlphanumericCharacterSet;
            length = AJRCountOf(AJRRandomStringUppercaseAlphanumericCharacterSet);
            break;
        case AJRCharacterTypeLowercaseAlphanumeric:
            set = AJRRandomStringLowercaseAlphanumericCharacterSet;
            length = AJRCountOf(AJRRandomStringLowercaseAlphanumericCharacterSet);
            break;
    }

    return length > 0 ? set[random() % length] : 0;
}

+ (NSString *)randomStringOfLength:(NSInteger)length {
    unichar buffer[length];

    for (NSInteger x = 0; x < length; x++) {
        buffer[x] = _AJRRandomCharacterForType(AJRCharacterTypeAlphanumeric);
    }

    return [[NSString alloc] initWithCharacters:buffer length:length];
}

+ (NSString *)randomString {
    return [self randomStringOfLength:10];
}

+ (NSString *)randomStringUsingPattern:(NSString *)pattern {
    NSInteger length = pattern.length;
    unichar buffer[length];
    unichar outputBuffer[length]; // Will always be <= length
    NSInteger outputLength = 0;

    [pattern getCharacters:buffer];
    for (NSInteger x = 0; x < length; x++) {
        switch (buffer[x]) {
            case '#':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeNumeric);
                break;
            case 'A':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeUppercaseAlpha);
                break;
            case 'a':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeLowercaseAlpha);
                break;
            case 'X':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeUppercaseAlphanumeric);
                break;
            case 'x':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeLowercaseAlphanumeric);
                break;
            case '@':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeAlpha);
                break;
            case '$':
                outputBuffer[outputLength++] = _AJRRandomCharacterForType(AJRCharacterTypeAlphanumeric);
                break;
            case '\\': // Skip the next character.
                x++;
                if (x < length) {
                    outputBuffer[outputLength++] = buffer[x];
                }
                break;
            default:
                outputBuffer[outputLength++] = buffer[x];
                break;
        }
    }

    return [[NSString alloc] initWithCharacters:outputBuffer length:outputLength];
}

- (NSArray *)commaSeparatedComponents {
    NSMutableArray *array = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *field;

    while ([scanner scanCommaDelimitedString:&field]) {
        [array addObject:field];
    }

    return array;
}

#pragma mark - Hex Encoding

static inline NSInteger _AJRHexValueFromCharacter(unichar character) {
    NSInteger nibble = 0;

    if (character >= '0' && character <= '9') {
        nibble = character - '0';
    } else if (character >= 'A' && character <= 'F') {
        nibble = (character - 'A') + 10;
    } else if (character >= 'a' && character <= 'f') {
        nibble = (character - 'a') + 10;
    }

    return nibble;
}

static inline BOOL _AJRIsHexStringCharacter(unichar character) {
    return ((character >= '0' && character <= '9') ||
            (character >= 'A' && character <= 'F') ||
            (character >= 'a' && character <= 'f'));
}

- (NSData *)dataFromHexEncodedString {
    NSMutableData *returnValue = nil;
    NSInteger x, length = [self length];

    for (x = 0; x < length; x += 2) {
        unichar value1 = 0;
        unichar value2 = 0;

        if (x < length && _AJRIsHexStringCharacter(value1 = [self characterAtIndex:x])
            && x + 1 < length && _AJRIsHexStringCharacter(value2 = [self characterAtIndex:x + 1])) {
            uint8_t byte = _AJRHexValueFromCharacter(value1) << 4 | _AJRHexValueFromCharacter(value2);
            if (returnValue == nil) {
                returnValue = [[NSMutableData alloc] initWithCapacity:ceil(length / 2)];
            }
            [returnValue appendBytes:&byte length:1];
        } else {
            break;
        }
    }

    return returnValue;
}

#pragma mark - Word Counting

- (NSUInteger)wordCountInRange:(NSRange)range {
    __block NSInteger count = 0;

    [self enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        count++;
    }];

    return count;
}

- (NSUInteger)wordCount {
    return [self wordCountInRange:self.fullRange];
}

#pragma mark - Numeric Conversions

- (NSTimeInterval)timeIntervalValue {
    NSTimeInterval returnValue = 0.0;

    if ([self rangeOfString:@":"].location != NSNotFound) {
        NSArray *parts = [self componentsSeparatedByString:@":"];
        NSInteger count = parts.count;
        double seconds = [parts[parts.count - 1] doubleValue];
        double minutes = [parts[parts.count - 2] longLongValue];
        double hours   = count > 2 ? [parts[parts.count - 3] longLongValue] : 0.0;
        double days    = count > 3 ? [parts[parts.count - 4] longLongValue] : 0.0;
        return returnValue = ((seconds)
                              + (minutes * AJRSecondsPerMinute)
                              + (hours * AJRSecondsPerHour)
                              + (days * AJRSecondsPerDay));
    } else {
        returnValue = [NSDate timeIntervalForTimePeriodString:self defaultValue:0.0];
    }

    return returnValue;
}

- (long long)millisecondsValue {
    return [NSDate millisecondsForTimePeriodString:self defaultValue:0.0];
}

- (NSNumber *)ajr_numberFromValue:(unsigned long long)value negative:(BOOL)negative {
    if (negative) {
        if (value <= llabs(INT8_MIN)) {
            return [NSNumber numberWithChar:(int8_t)(-value)];
        } else if (value <= llabs(INT16_MIN)) {
            return [NSNumber numberWithShort:(int16_t)(-value)];
        } else if (value <= llabs(INT32_MIN)) {
            return [NSNumber numberWithInteger:(int32_t)(-value)];
        } else if (value <= llabs(INT64_MIN)) {
            return [NSNumber numberWithLongLong:(int64_t)(-value)];
        }
    } else {
        if (value <= UINT8_MAX) {
            return [NSNumber numberWithUnsignedChar:(uint8_t)value];
        } else if (value <= UINT16_MAX) {
            return [NSNumber numberWithUnsignedShort:(uint16_t)value];
        } else if (value <= UINT32_MAX) {
            return [NSNumber numberWithUnsignedInteger:(uint32_t)value];
        } else if (value <= UINT64_MAX) {
            return [NSNumber numberWithUnsignedLong:(uint64_t)value];
        }
    }

    return nil; // Probably an overflow
}

- (NSNumber *)numberValue {
    NSCharacterSet *set = [NSCharacterSet decimalDigitCharacterSet];
    unsigned long long value = 0LL;
    NSUInteger x, length = [self length];
    BOOL starting = YES;
    BOOL scanningFraction = NO;
    BOOL scanningExponent = NO;
    BOOL negative = NO;
    BOOL exponentNegative = NO;
    NSInteger exponent = 0;
    NSUInteger places = 0;

    for (x = 0; x < length; x++) {
        unichar digit = [self characterAtIndex:x];

        if (starting) {
            if (digit == '-') {
                if (negative) {
                    // No double negatives.
                    break;
                }
                negative = YES;
            } else if ([set characterIsMember:digit] || digit == '.') {
                starting = NO;
            }
        }

        if (!starting) {
            if (digit == '.') {
                if (scanningFraction || scanningExponent) {
                    // We're done. A number can only have one decimal point, and no decimal point
                    // in the exponent.
                    break;
                }
                scanningFraction = YES;
            } else if (scanningExponent && digit == '-') {
                exponentNegative = YES;
            } else if ([set characterIsMember:digit]) {
                if (scanningExponent) {
                    exponent = (exponent * 10) + (NSInteger)(digit - '0');
                } else {
                    value = (value * 10LL) + (unsigned long long)(digit - '0');
                    if (scanningFraction) {
                        places++;
                    }
                }
            } else if (digit == 'e' || digit == 'E') {
                scanningExponent = YES;
            }
        }
    }

    // If we never started, then we have no number.
    if (!starting) {
        if (exponent > 0 || places > 0) {
            double doubleValue = (double)value;
            doubleValue /= pow(10, places);
            if (negative) {
                doubleValue = -doubleValue;
            }
            if (exponent) {
                if (exponentNegative) {
                    exponent = -exponent;
                }
                doubleValue *= pow(10, exponent);
            }
            return [NSNumber numberWithDouble:doubleValue];
        } else {
            return [self ajr_numberFromValue:value negative:negative];
        }
    }

    // Let's see if we can be a boolean value
    if ([self caseInsensitiveCompare:@"true"] == NSOrderedSame
        || [self caseInsensitiveCompare:@"yes"] == NSOrderedSame) {
        return [NSNumber numberWithBool:YES];
    } else if ([self caseInsensitiveCompare:@"false"] == NSOrderedSame
               || [self caseInsensitiveCompare:@"no"] == NSOrderedSame) {
        return [NSNumber numberWithBool:NO];
    }

    return nil;
}

- (int32_t)int32ValueUsingBase:(NSInteger)base {
    return (int32_t)strtol([self UTF8String], NULL, (int)base);
}

- (uint32_t)unsignedInt32ValueUsingBase:(NSInteger)base {
    return (uint32_t)strtoul([self UTF8String], NULL, (int)base);
}

- (int64_t)int64ValueUsingBase:(NSInteger)base {
    return (int64_t)strtoll([self UTF8String], NULL, (int)base);
}

- (uint64_t)unsignedInt64ValueUsingBase:(NSInteger)base {
    return (uint64_t)strtoull([self UTF8String], NULL, (int)base);
}

- (NSUInteger)hexValue {
    return [self int64ValueUsingBase:16];
}

- (long)longHexValue {
    return [self int64ValueUsingBase:16];
}

- (unsigned long)unsignedLongHexValue {
    return [self unsignedInt64ValueUsingBase:16];
}

- (long long)longLongHexValue {
    return [self int64ValueUsingBase:16];
}

- (unsigned long long)unsignedLongLongHexValue {
    return [self unsignedInt64ValueUsingBase:16];
}

- (NSInteger)trailingIntegerValueFoundInRange:(nullable NSRangePointer)foundRange {
    NSCharacterSet *set = [NSCharacterSet decimalDigitCharacterSet];
    NSRange range = { [self length], 0 };
    NSInteger value = 0;

    while (range.location > 1) {
        if ([set characterIsMember:[self characterAtIndex:range.location - 1]]) {
            range.location -= 1;
            range.length += 1;
        } else {
            break;
        }
    }

    if (range.length > 0) {
        value = [[self substringWithRange:range] integerValue];
    } else {
        range.location = NSNotFound;
    }

    if (foundRange) {
        *foundRange = range;
    }

    return value;
}

- (NSInteger)trailingIntegerValue {
    return [self trailingIntegerValueFoundInRange:NULL];
}

- (int8_t)int8Value {
    return (int8_t)[self int32ValueUsingBase:10];
}

- (uint8_t)unsignedInt8Value {
    return (uint8_t)[self unsignedInt32ValueUsingBase:10];
}

- (int16_t)int16Value {
    return (int16_t)[self int32ValueUsingBase:10];
}

- (uint16_t)unsignedInt16Value {
    return (uint16_t)[self unsignedInt32ValueUsingBase:10];
}

- (int32_t)int32Value {
    return (int32_t)[self int32ValueUsingBase:10];
}

- (uint32_t)unsignedInt32Value {
    return (uint32_t)[self unsignedInt32ValueUsingBase:10];
}

- (int64_t)int64Value {
    return (int64_t)[self int64ValueUsingBase:10];
}

- (uint64_t)unsignedInt64Value {
    return (uint64_t)[self unsignedInt64ValueUsingBase:10];
}

- (char)charValue {
    return (char)[self int32ValueUsingBase:10];
}

- (unsigned char)unsignedCharValue {
    return (unsigned char)[self unsignedInt32ValueUsingBase:10];
}

- (short)shortValue {
    return (short)[self int32ValueUsingBase:10];
}

- (unsigned short)unsignedShortValue {
    return (unsigned short)[self unsignedInt32ValueUsingBase:10];
}

- (long)longValue {
    return [self unsignedInt64ValueUsingBase:10];
}

- (unsigned long)unsignedLongValue {
    return [self unsignedInt64ValueUsingBase:10];
}

- (unsigned int)unsignedIntValue {
    return [self unsignedInt32ValueUsingBase:10];
}

- (NSUInteger)unsignedIntegerValue {
    return [self unsignedInt64ValueUsingBase:10];
}

- (long long)longLongValue {
    return [self int64ValueUsingBase:10];
}

- (unsigned long long)unsignedLongLongValue {
    return [self unsignedInt64ValueUsingBase:10];
}

- (double)doubleValue {
    return strtod([self UTF8String], NULL);
}

- (long double)longDoubleValue {
    return strtold([self UTF8String], NULL);
}

- (NSDate *)dateValue {
    return [self dateValueWithError:nil];
}

- (NSDate *)dateValueWithError:(NSError **)error {
    return [self dateValueWithFormat:@"%m/%d/%Y" error:error];
}

- (NSDate *)dateValueWithFormat:(NSString *)format error:(NSError **)error {
    return AJRDateFromStringAndFormat(self, format, nil, error);
}

- (BOOL)isInteger {
    BOOL result = YES;
    NSCharacterSet *set = [NSCharacterSet decimalDigitCharacterSet];

    result = YES;
    for (NSInteger x = 0; x < self.length && result; x++) {
        if (![set characterIsMember:[self characterAtIndex:x]]) {
            result = NO;
        }
    }

    return result;
}

- (NSString *)stringByCryptingWithSalt:(NSString *)salt {
    return [NSString stringWithCString:crypt((char *)[self UTF8String], (char *)[salt UTF8String]) encoding:NSUTF8StringEncoding];
}

+ (id)stringWithCString:(const char *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding {
    return [[NSString alloc] initWithBytes:bytes length:length encoding:encoding];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
- (NSString *)md5Hash {
    const char *utf8String = [self UTF8String];
    unsigned char digest[16];
    char *output = (char *)malloc(33);
    CC_LONG length = (CC_LONG)strlen(utf8String);
    CC_MD5_CTX c;

    CC_MD5_Init(&c);
    while (length > 0) {
        if (length > 512) {
            CC_MD5_Update(&c, utf8String, 512);
        } else {
            CC_MD5_Update(&c, utf8String, length);
        }
        if (length >= 512) {
            length -= 512;
            utf8String += 512;
        } else {
            length = 0;
        }
    }
    CC_MD5_Final(digest, &c);

    for (int n = 0; n < 16; ++n) {
        snprintf(&(output[n*2]), 16*2, "%02x", (unsigned int)digest[n]);
    }

    return [NSString stringWithCString:output encoding:NSASCIIStringEncoding];
}
#pragma clang diagnostic pop

#pragma mark - UTF32 Character Handling

- (NSInteger)getLongCharacter:(wchar_t *)characterOut atIndex:(NSUInteger)index {
    char buffer[16];
    NSUInteger usedLength;
    NSRange inputRange = [self rangeOfComposedCharacterSequenceAtIndex:index];
    NSRange remainingRange;
    NSInteger charactersUsed = NSNotFound;

    if ([self getBytes:buffer maxLength:16 usedLength:&usedLength encoding:NSUTF32LittleEndianStringEncoding options:0 range:inputRange remainingRange:&remainingRange]) {
        if (usedLength == 4) {
            uint32_t *ints = (uint32_t *)buffer;
            AJRSetOutParameter(characterOut, ints[0]);
            charactersUsed = inputRange.length;
        }
    }

    return charactersUsed;
}

@end

#pragma mark - IANA Name Conversion

NSStringEncoding AJRStringEncodingFromIANAName(NSString *IANAName) {
    CFStringEncoding encoding = IANAName ? CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)IANAName) : kCFStringEncodingInvalidId;
    return CFStringConvertEncodingToNSStringEncoding(encoding);
}

NSString *AJRIANANameFromStringEncoding(NSStringEncoding encoding) {
    CFStringEncoding cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    return (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(cfStringEncoding);
}
