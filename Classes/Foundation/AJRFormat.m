/*
 AJRFormat.m
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

#import "AJRFormat.h"

#import "AJRLogging.h"
#import "AJRFoundationOS.h"

typedef NS_ENUM(uint8_t, AJRFormatStage) {
    AJRFormatStageAPriori,
    AJRFormatStageParameter,
    AJRFormatStageFlags,
    AJRFormatStageWidth,
    AJRFormatStagePrecision,
    AJRFormatStageType
};

#define _AJRExpandBufferIfNeeded(length) { \
while (outputBufferPosition + length >= outputBufferMaxLength) { \
outputBufferMaxLength += 1024; \
outputBuffer = (wchar_t *)NSZoneRealloc(NULL, outputBuffer, sizeof(wchar_t) * outputBufferMaxLength); \
} \
}

#define _AJRPad(count) { \
wchar_t pad = (flags & AJRZeroPadding) ? '0' : ' '; \
NSInteger rCount = (count); \
while (rCount) { \
outputBuffer[outputBufferPosition] = pad; \
outputBufferPosition++; \
rCount--; \
} \
}

#if defined(AJRFoundation_iOS)
static NSString *NSStringFromPoint(CGPoint point) {
    return AJRFormat(@"{%.f, %.f}, {%.f, %.f}", point.x, point.y);
}

static NSString *NSStringFromSize(CGSize size) {
    return AJRFormat(@"{%.f, %.f}, {%.f, %.f}", size.width, size.height);
}

static NSString *NSStringFromRect(CGRect rect) {
    return AJRFormat(@"{%@, %@}", NSStringFromPoint(rect.origin), NSStringFromSize(rect.size));
}
#endif

static char _ajrDecimalDigits[] = "0123456789";
static char _ajrHexidecimalDigits[] = "0123456789abcdef";
static char _ajrHEXIDECIMALDigits[] = "0123456789ABCDEF";
static char _ajrOctalDigits[] = "01234567";

#define AJRAlternateForm            1        // '#'
#define AJRZeroPadding              2        // '0'
#define AJRLeftJustified            4        // '-'
#define AJRSpaceForPlus             8        // ' '
#define AJRShowPlus                16        // '+'
//#define AJRGroupThousands        32        // ','
#define AJRShortType               64        // 'h'
#define AJRLongType               128        // 'l'
#define AJRLongLongType           256        // 'll' or 'L' or 'q'
#define AJRSizeTType              512        // 'z'

/** @todo There should now-a-days be a function defined in System.framework for this, but I couldn't readily find it - AJR */
static size_t ustrlen(const unichar *string) {
    int x = 0;
    while (string[x] != 0) x++;
    return x;
}

static NSInteger _integerBufferSize = 50;

char *_ajrIntegerToString(unsigned long long value, NSInteger base, char *digits, char buffer[_integerBufferSize]) {
    NSInteger x;
    
    if (value == 0LL) return "0";
    
    buffer[_integerBufferSize - 1] = '\0';
    
    for (x = _integerBufferSize - 2; (x > 0) && (value != 0); x--) {
        buffer[x] = digits[value % base];
        value /= base;
    }
    
    return buffer + x + 1;
}

NSString *AJRFormatv(NSString *format, va_list ap) {
    char integerBuffer[_integerBufferSize];
    wchar_t character;
    NSInteger position, x;
    NSUInteger length;
    wchar_t *outputBuffer;
    NSInteger outputBufferPosition = 0;
    NSInteger outputBufferMaxLength = 1024;
    NSRange range;
    AJRFormatStage stage = AJRFormatStageAPriori;
    NSUInteger flags = 0;
    NSUInteger width = NSNotFound, precision = NSNotFound;
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    char *stringValue = NULL;
    unichar *unicharStringValue = NULL;
    id objectValue = nil;
    NSDate *dateValue = nil;
    NSInteger numericBase = 0;
    char *prefix = NULL;
    BOOL isSigned = NO;
    char *displayDigits = _ajrDecimalDigits;
    BOOL doingFloat = NO;
    double floatValue = 0.0;
    long double longDoubleValue = 0.0;
    BOOL doingTimeInterval = NO;
    OSType osType = '    ';
    BOOL doingOSType = NO;
    BOOL booleanValue = NO;
    BOOL doingBooleanType = NO;
    BOOL useCapitals = NO;
    NSTimeZone *timeZoneForFormat = nil;
    NSTimeInterval timeIntervalValue = 0.0;
    NSRange parameterRange;
    wchar_t *inputBuffer;

    // format.length should always be sufficient, since we're converting to UTF-32, which, if anything will convert two character input characters to single characters.
    inputBuffer = (wchar_t *)NSZoneMalloc(NULL, sizeof(wchar_t) * format.length);
    [format getBytes:inputBuffer maxLength:sizeof(wchar_t) * format.length usedLength:&length encoding:NSUTF32LittleEndianStringEncoding options:0 range:(NSRange){0, [format length]} remainingRange:NULL];
    length /= sizeof(wchar_t); // Because the above returns the length in bytes, but wchar_t, which is what we really want.
    
    outputBuffer = (wchar_t *)NSZoneMalloc(NULL, sizeof(wchar_t) * outputBufferMaxLength);
    
    range.location = 0;
    range.length = 0;
    for (position = 0; position < length; position++) {
        character = CFSwapInt32LittleToHost(inputBuffer[position]);
        if (stage == AJRFormatStageAPriori) {
            if (character == '%') {
                range.length = position - range.location;
                _AJRExpandBufferIfNeeded(range.length);
                for (NSInteger x = 0; x <  range.length; x++) {
                    outputBuffer[outputBufferPosition + x] = inputBuffer[range.location + x];
                }
                range.location = position + 1;
                outputBufferPosition += range.length;
                stage = AJRFormatStageFlags;
                flags = 0;
                width = NSNotFound;
                precision = NSNotFound;
                stringValue = NULL;
                unicharStringValue = NULL;
                objectValue = nil;
                dateValue = nil;
                numericBase = 0;
                prefix = NULL;
                doingFloat = NO;
                parameterRange = (NSRange){NSNotFound, 0};
            }
        } else {
            if (stage == AJRFormatStageFlags) {
                switch (character) {
                    case '%':
                        stage = AJRFormatStageAPriori;
                        continue;
                    case '#':
                        flags |= AJRAlternateForm;
                        range.location++;
                        break;
                    case '0':
                        flags |= AJRZeroPadding;
                        range.location++;
                        break;
                    case '-':
                        flags |= AJRLeftJustified;
                        range.location++;
                        break;
                    case ' ':
                        flags |= AJRSpaceForPlus;
                        range.location++;
                        break;
                    case '+':
                        flags |= AJRShowPlus;
                        range.location++;
                        break;
                    case '!':
                        timeZoneForFormat = va_arg(ap, NSTimeZone *);
                        if (![timeZoneForFormat isKindOfClass:[NSTimeZone class]]) {
                            AJRLog(nil, AJRLogLevelWarning, @"Flag parameter to %s wasn't an NSTimeZone object.", __FUNCTION__);
                            timeZoneForFormat = nil;
                        }
                        range.location++;
                        break;
                        //                    case ',':
                        //                        flags |= AJRGroupThousands;
                        //                        range.location++;
                        //                        break;
                    case '(':
                        stage = AJRFormatStageParameter;
                        parameterRange.location = position;
                        parameterRange.length = 0;
                        break;
                    default:
                        stage = AJRFormatStageWidth;
                        break;
                }
            }
            if (stage == AJRFormatStageParameter) {
                if (character == ')') {
                    stage = AJRFormatStageFlags;
                    parameterRange.length = position - parameterRange.location + 1;
                }
                range.location++;
            }
            if (stage == AJRFormatStageWidth) {
                if (character == '*') {
                    width = va_arg(ap, int);
                    range.location++;
                } else if ([digits characterIsMember:character]) {
                    if (width == NSNotFound) {
                        width = character - '0';
                    } else {
                        width = (width * 10) + (character - '0');
                    }
                    range.location++;
                } else if (character == '.') {
                    stage = AJRFormatStagePrecision;
                    continue; // We don't want fall through in this case.
                } else {
                    stage = AJRFormatStageType;
                }
            }
            if (stage == AJRFormatStagePrecision) {
                if (character == '*') {
                    precision = va_arg(ap, int);
                    range.location++;
                } else if ([digits characterIsMember:character]) {
                    if (precision == NSNotFound) {
                        precision = character - '0';
                    } else {
                        precision = (precision * 10) + (character - '0');
                    }
                    range.location++;
                } else {
                    stage = AJRFormatStageType;
                    range.location++;
                }
            }
            if (stage == AJRFormatStageType) {
                switch (character) {
                    case 'h':
                        flags |= AJRShortType;
                        range.location++;
                        break;
                    case 'l':
                        if (flags & AJRLongType) {
                            flags &= (~AJRLongType);
                            flags |= AJRLongLongType;
                        } else {
                            flags |= AJRLongType;
                        }
                        range.location++;
                        break;
                    case 'L':
                        flags &= (~AJRLongType);
                        flags |= AJRLongLongType;
                        range.location++;
                        break;
                    case 'q':
                        flags |= AJRLongLongType;
                        range.location++;
                        break;
                    case 'z':
                        flags |= AJRSizeTType;
                        range.location++;
                        break;
                    case 'd':
                    case 'i':
                        numericBase = 10;
                        isSigned = YES;
                        displayDigits = _ajrDecimalDigits;
                        break;
                    case 'b':
                        numericBase = 2;
                        prefix = NULL;
                        isSigned = NO;
                        displayDigits = _ajrDecimalDigits;
                        break;
                    case 'o':
                        numericBase = 8;
                        prefix = flags & AJRAlternateForm ? "0" : NULL;
                        isSigned = YES;
                        displayDigits = _ajrOctalDigits;
                        break;
                    case 'u':
                        numericBase = 10;
                        prefix = NULL;
                        isSigned = NO;
                        displayDigits = _ajrDecimalDigits;
                        break;
                    case 'x':
                        numericBase = 16;
                        prefix = flags & AJRAlternateForm ? "0x" : NULL;
                        isSigned = NO;
                        displayDigits = useCapitals ? _ajrHEXIDECIMALDigits : _ajrHexidecimalDigits;
                        break;
                    case 'X':
                        numericBase = 16;
                        prefix = flags & AJRAlternateForm ? "0X" : NULL;
                        isSigned = NO;
                        displayDigits = _ajrHEXIDECIMALDigits;
                        break;
                    case 'A':
                    case 'E':
                    case 'F':
                    case 'G':
                        useCapitals = YES;
                    case 'a':
                    case 'e':
                    case 'f':
                    case 'g':
                        doingFloat = YES;
                        if ((flags & AJRLongType) || (flags & AJRLongLongType)) {
                            longDoubleValue = va_arg(ap, long double);
                        } else {
                            floatValue = va_arg(ap, double);
                        }
                        break;
                    case 'c':
                        _AJRExpandBufferIfNeeded(1);
                        if (flags & AJRLongType) {
                            outputBuffer[outputBufferPosition++] = va_arg(ap, unsigned int) & 0xFFFFFFFF;
                        } else {
                            outputBuffer[outputBufferPosition++] = va_arg(ap, unsigned int) & 0xFF;
                        }
                        stage = AJRFormatStageAPriori;
                        range.location++;
                        break;
                    case 's':
                        if (flags & AJRLongType) {
                            unicharStringValue = va_arg(ap, unichar *);
                            if (unicharStringValue == NULL) {
                                objectValue = @"(null)";
                            }
                        } else {
                            stringValue = va_arg(ap, char *);
                            if (stringValue == NULL) {
                                objectValue = @"(null)";
                            }
                        }
                        break;
                    case 'p':
                        numericBase = 16;
                        prefix = "0x";
                        isSigned = NO;
                        displayDigits = _ajrHexidecimalDigits;
                        if (sizeof(void *) == 8) {
                            flags |= AJRLongLongType;
                        }
                        break;
                    case 'n':
                    {
                        if (flags & AJRLongType) {
                            NSInteger *location = va_arg(ap, NSInteger *);
                            *location = outputBufferPosition;
                        } else if (flags & AJRLongLongType) {
                            long long *location = va_arg(ap, long long *);
                            *location = outputBufferPosition;
                        } else {
                            int *location = va_arg(ap, int *);
                            *location = (int)outputBufferPosition;
                        }
                        stage = AJRFormatStageAPriori;
                        range.location++;
                    }
                        break;
                    case '@':
                        objectValue = va_arg(ap, id);
                        if (!objectValue) {
                            objectValue = @"(null)";
                        }
                        break;
                        /* These are special, extended formats not normally supported by printf */
                    case 'S':
                        objectValue = NSStringFromSelector(va_arg(ap, SEL));
                        break;
                    case 'C': {
                        id object = va_arg(ap, id);
                        objectValue = object ? NSStringFromClass([object class]) : @"(Nil)";
                        break;
                    }
                    case 'R':
                        objectValue = NSStringFromRect(va_arg(ap, CGRect));
                        break;
                    case 'r':
                        objectValue = NSStringFromRange(va_arg(ap, NSRange));
                        break;
                    case 'Z':
                        objectValue = NSStringFromSize(va_arg(ap, CGSize));
                        break;
                    case 'P':
                        objectValue = NSStringFromPoint(va_arg(ap, CGPoint));
                        break;
                    case 'm':
                        objectValue = [NSByteCountFormatter stringFromByteCount:va_arg(ap, NSUInteger) countStyle:NSByteCountFormatterCountStyleMemory];
                        break;
                    case 'T':
                        doingTimeInterval = YES;
                        timeIntervalValue = va_arg(ap, NSTimeInterval);
                        break;
                    case 'O':
                        doingOSType = YES;
                        osType = va_arg(ap, OSType);
                        break;
                    case 'B':
                        doingBooleanType = YES;
                        booleanValue = va_arg(ap, int);
                        break;
                    case 'D':
                        dateValue = va_arg(ap, NSDate *);
                        if (![dateValue isKindOfClass:[NSDate class]]) {
                            AJRLog(nil, AJRLogLevelWarning, @"Parameter to %s wasn't an NSDate object.", __FUNCTION__);
                        }
                        break;
                    default:
                        _AJRExpandBufferIfNeeded(1);
                        outputBuffer[outputBufferPosition++] = character;
                        stage = AJRFormatStageAPriori;
                        range.location++;
                        break;
                }
                if (stringValue) {
                    NSInteger length = strlen(stringValue);
                    NSInteger vPos;
                    
                    if ((precision != NSNotFound) && (length > precision)) {
                        length = precision;
                    }
                    if (!(flags & AJRLeftJustified) && (width != NSNotFound) && (length < width)) {
                        _AJRExpandBufferIfNeeded(width - length);
                        _AJRPad(width - length);
                    }
                    for (vPos = 0; vPos < length; vPos++) {
                        _AJRExpandBufferIfNeeded(1);
                        outputBuffer[outputBufferPosition] = *(stringValue + vPos);
                        outputBufferPosition++;
                    }
                    if ((flags & AJRLeftJustified) && (width != NSNotFound) && (length < width)) {
                        _AJRExpandBufferIfNeeded(width - length);
                        _AJRPad(width - length);
                    }
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    stringValue = NULL;
                } else if (unicharStringValue) {
                    NSInteger length = ustrlen(unicharStringValue);
                    NSInteger vPos;
                    BOOL isLittleEndian = NO;
                    
                    if (length >= 1) {
                        if ((((unsigned char *)unicharStringValue)[0] == 0xFE) && (((unsigned char *)unicharStringValue)[1] == 0xFF)) {
                            isLittleEndian = YES;
                            length--;
                            unicharStringValue++;
                        } else if ((((unsigned char *)unicharStringValue)[0] == 0xFF) && (((unsigned char *)unicharStringValue)[1] == 0xFE)) {
                            isLittleEndian = NO;
                            length--;
                            unicharStringValue++;
                        }
                    }
                    
                    if ((precision != NSNotFound) && (length > precision)) {
                        length = precision;
                    }
                    if (!(flags & AJRLeftJustified) && (width != NSNotFound) && (length < width)) {
                        _AJRExpandBufferIfNeeded(width - length);
                        _AJRPad(width - length);
                    }
                    for (vPos = 0; vPos < length; vPos += 1) {
                        _AJRExpandBufferIfNeeded(1);
                        if (isLittleEndian) {
                            outputBuffer[outputBufferPosition] = NSSwapBigShortToHost(*(unicharStringValue + vPos));
                            outputBufferPosition++;
                        } else {
                            outputBuffer[outputBufferPosition] = NSSwapLittleShortToHost(*(unicharStringValue + vPos));
                            outputBufferPosition++;
                        }
                    }
                    if ((flags & AJRLeftJustified) && (width != NSNotFound) && (length < width)) {
                        _AJRExpandBufferIfNeeded(width - length);
                        _AJRPad(width - length);
                    }
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    unicharStringValue = NULL;
                } else if (objectValue || dateValue) {
                    NSString *value = nil;
                    
                    if (dateValue) {
                        NSString *formatString = @"yyyy/MM/dd HH:mm";
                        if (parameterRange.length > 2) {
                            parameterRange.location += 1;
                            parameterRange.length -= 2;
                            formatString = [format substringWithRange:parameterRange];
                        }
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:formatString];
                        if (timeZoneForFormat != nil) {
                            [formatter setTimeZone:timeZoneForFormat];
                        }
                        value = [formatter stringFromDate:dateValue];
                    } else {
                        value = [objectValue description];
                    }
                    // This may seem a little cumbersome, but if you ask for a string's length, and that string contains Unicode values greater than 0xFFFF, NSString will return 2 for each character. So, if instead, we ask for the length in bytes for our encoding, and divide by 4 (since we're looking at 32 bit values), then we'll get the actual length we want.
                    NSInteger length = [value lengthOfBytesUsingEncoding:NSUTF32LittleEndianStringEncoding] / sizeof(wchar_t);

                    if ((precision != NSNotFound) && (length > precision)) {
                        length = precision;
                    }
                    if (!(flags & AJRLeftJustified) && (width != NSNotFound) && (length < width)) {
                        _AJRExpandBufferIfNeeded(width - length);
                        _AJRPad(width - length);
                    }
                    _AJRExpandBufferIfNeeded(length);
                    [value getBytes:outputBuffer + outputBufferPosition maxLength:outputBufferMaxLength * sizeof(wchar_t) usedLength:NULL encoding:NSUTF32LittleEndianStringEncoding options:0 range:(NSRange){0, value.length} remainingRange:NULL];
                    outputBufferPosition += length;
                    if ((flags & AJRLeftJustified) && (width != NSNotFound) && (length < width)) {
                        _AJRExpandBufferIfNeeded(width - length);
                        _AJRPad(width - length);
                    }
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    objectValue = nil;
                } else if (numericBase) {
                    unichar signChar = 0;
                    long long tValue;
                    unsigned long long    value;
                    NSInteger length, trueLength;
                    
                    if (flags & AJRShortType) {
                        if (isSigned) {
                            tValue = va_arg(ap, int /* short */);
                            if (tValue < 0) signChar = '-';
                            value = llabs(tValue);
                        } else {
                            value = va_arg(ap, unsigned int /*unsigned short*/);
                        }
                    } else if (flags & AJRLongType) {
                        if (isSigned) {
                            tValue = va_arg(ap, long);
                            if (tValue < 0) signChar = '-';
                            value = llabs(tValue);
                        } else {
                            value = va_arg(ap, unsigned long);
                        }
                    } else if (flags & AJRLongLongType) {
                        if (isSigned) {
                            tValue = va_arg(ap, long long);
                            if (tValue < 0) signChar = '-';
                            value = llabs(tValue);
                        } else {
                            value = va_arg(ap, unsigned long long);
                        }
                    } else {
                        if (isSigned) {
                            tValue = va_arg(ap, int);
                            if (tValue < 0) signChar = '-';
                            value = llabs(tValue);
                        } else {
                            value = va_arg(ap, unsigned int);
                        }
                    }
                    
                    if (signChar == 0) {
                        if (flags & AJRSpaceForPlus) {
                            signChar = ' ';
                        } else if (flags & AJRShowPlus) {
                            signChar = '+';
                        }
                    }
                    
                    stringValue = _ajrIntegerToString(value, numericBase, displayDigits, integerBuffer);
                    length = trueLength = strlen(stringValue);
                    if (signChar != 0) length++;
                    if (prefix) length += strlen(prefix);
                    
                    if (precision != NSNotFound) {
                        width = precision;
                        flags |= AJRZeroPadding;
                    }
                    
                    if ((width != NSNotFound) && (length < width) && (!(flags & AJRLeftJustified) || (flags & AJRZeroPadding))) {
                        if (flags & AJRZeroPadding) {
                            if (signChar != 0) {
                                _AJRExpandBufferIfNeeded(1);
                                outputBuffer[outputBufferPosition++] = signChar;
                            }
                            if (prefix) {
                                for (x = 0; prefix[x]; x++) {
                                    _AJRExpandBufferIfNeeded(1);
                                    outputBuffer[outputBufferPosition++] = prefix[x];
                                }
                            }
                            for (x = 0; x < width - length; x++) {
                                _AJRExpandBufferIfNeeded(1);
                                outputBuffer[outputBufferPosition++] = '0';
                            }
                        } else {
                            for (x = 0; x < width - length; x++) {
                                _AJRExpandBufferIfNeeded(1);
                                outputBuffer[outputBufferPosition++] = ' ';
                            }
                            if (signChar != 0) {
                                _AJRExpandBufferIfNeeded(1);
                                outputBuffer[outputBufferPosition++] = signChar;
                            }
                            if (prefix) {
                                for (x = 0; prefix[x]; x++) {
                                    _AJRExpandBufferIfNeeded(1);
                                    outputBuffer[outputBufferPosition++] = prefix[x];
                                }
                            }
                        }
                    } else if (signChar != 0) {
                        _AJRExpandBufferIfNeeded(1);
                        outputBuffer[outputBufferPosition++] = signChar;
                        if (prefix) {
                            for (x = 0; prefix[x]; x++) {
                                _AJRExpandBufferIfNeeded(1);
                                outputBuffer[outputBufferPosition++] = prefix[x];
                            }
                        }
                    } else if (prefix) {
                        if (prefix) {
                            for (x = 0; prefix[x]; x++) {
                                _AJRExpandBufferIfNeeded(1);
                                outputBuffer[outputBufferPosition++] = prefix[x];
                            }
                        }
                    }
                    
                    for (x = 0; x < trueLength; x++) {
                        _AJRExpandBufferIfNeeded(1);
                        outputBuffer[outputBufferPosition++] = stringValue[x];
                    }
                    
                    if ((width != NSNotFound) && (length < width) && (flags & AJRLeftJustified) && !(flags & AJRZeroPadding)) {
                        for (x = 0; x < width - length; x++) {
                            _AJRExpandBufferIfNeeded(1);
                            outputBuffer[outputBufferPosition++] = ' ';
                        }
                    }
                    
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    stringValue = NULL;
                    numericBase = 0;
                } else if (doingFloat) {
                    char cFormat[20];
                    char cType[3] = { character, '\0', '\0' };
                    char tempBuffer[80];
                    
                    if ((flags & AJRLongType) || (flags & AJRLongLongType)) {
                        cType[1] = cType[0];
                        cType[0] = 'L';
                    }
                    
                    strcpy(cFormat, "%");
                    if (flags & AJRAlternateForm) strcat(cFormat, "#");
                    if (flags & AJRZeroPadding) strcat(cFormat, "0");
                    if (flags & AJRLeftJustified) strcat(cFormat, "-");
                    if (flags & AJRSpaceForPlus) strcat(cFormat, " ");
                    if (flags & AJRShowPlus) strcat(cFormat, "+");
                    //                    if (flags & AJRGroupThousands) strcat(cFormat, ",");
                    if ((width == NSNotFound) && (precision == NSNotFound)) {
                        strcat(cFormat, cType);
                        if ((flags & AJRLongType) || (flags & AJRLongLongType)) {
                            snprintf(tempBuffer, 80, cFormat, longDoubleValue);
                        } else {
                            snprintf(tempBuffer, 80, cFormat, floatValue);
                        }
                    } else if ((width != NSNotFound) && (precision == NSNotFound)) {
                        strcat(cFormat, "*");
                        strcat(cFormat, cType);
                        if ((flags & AJRLongType) || (flags & AJRLongLongType)) {
                            snprintf(tempBuffer, 80, cFormat, width, longDoubleValue);
                        } else {
                            snprintf(tempBuffer, 80, cFormat, width, floatValue);
                        }
                    } else if ((width == NSNotFound) && (precision != NSNotFound)) {
                        strcat(cFormat, ".*");
                        strcat(cFormat, cType);
                        if ((flags & AJRLongType) || (flags & AJRLongLongType)) {
                            snprintf(tempBuffer, 80, cFormat, precision, longDoubleValue);
                        } else {
                            snprintf(tempBuffer, 80, cFormat, precision, floatValue);
                        }
                    } else if ((width != NSNotFound) && (precision != NSNotFound)) {
                        strcat(cFormat, "*.*");
                        strcat(cFormat, cType);
                        if ((flags & AJRLongType) || (flags & AJRLongLongType)) {
                            snprintf(tempBuffer, 80, cFormat, width, precision, longDoubleValue);
                        } else {
                            snprintf(tempBuffer, 80, cFormat, width, precision, floatValue);
                        }
                    }
                    
                    _AJRExpandBufferIfNeeded(strlen(tempBuffer));
                    for (x = 0; tempBuffer[x]; x++) {
                        outputBuffer[outputBufferPosition++] = tempBuffer[x];
                    }
                    
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    floatValue = 0.0;
                    doingFloat = NO;
                } else if (doingTimeInterval) {
                    NSInteger hours, minutes, seconds;
                    NSInteger hourLength = 0;
                    NSInteger fraction = 0;
                    BOOL isNegative = timeIntervalValue < 0.0;
                    char *number;
                    NSInteger x;
                    NSInteger neededLength;
                    
                    timeIntervalValue = fabs(timeIntervalValue);
                    
                    hours = (int)floor(timeIntervalValue / (60.0 * 60.0));
                    minutes = ((int)floor(timeIntervalValue) / 60) % 60;
                    seconds = (int)floor(timeIntervalValue) % 60;
                    if (precision != NSNotFound) {
                        fraction = (int)rint((timeIntervalValue - floor(timeIntervalValue)) * pow(10.0, precision));
                    }
                    hourLength = hours == 0 ? 1 : ceil(log10(hours + 1));
                    
                    neededLength = hourLength < 2 ? 2 : hourLength;
                    neededLength += 6;
                    if (isNegative) neededLength++;
                    if (precision != NSNotFound) neededLength += precision + 1;
                    _AJRExpandBufferIfNeeded(neededLength);
                    //fprintf(stderr, "%d\n", neededLength);
                    
                    if (isNegative) {
                        outputBuffer[outputBufferPosition++] = '-';
                    }
                    number = _ajrIntegerToString(hours, 10, _ajrDecimalDigits, integerBuffer);
                    if (hourLength < 2) {
                        outputBuffer[outputBufferPosition++] = '0';
                    }
                    for (x = 0; x < strlen(number); x++) {
                        outputBuffer[outputBufferPosition++] = number[x];
                    }
                    outputBuffer[outputBufferPosition++] = ':';
                    if (minutes < 10) {
                        outputBuffer[outputBufferPosition++] = '0';
                    } else {
                        outputBuffer[outputBufferPosition++] = (wchar_t)('0' + (minutes / 10));
                    }
                    outputBuffer[outputBufferPosition++] = '0' + (minutes % 10);
                    outputBuffer[outputBufferPosition++] = ':';
                    if (seconds < 10) {
                        outputBuffer[outputBufferPosition++] = '0';
                    } else {
                        outputBuffer[outputBufferPosition++] = (wchar_t)('0' + (seconds / 10));
                    }
                    outputBuffer[outputBufferPosition++] = '0' + (seconds % 10);
                    if (precision != NSNotFound) {
                        NSInteger length;
                        
                        number = _ajrIntegerToString(fraction, 10, _ajrDecimalDigits, integerBuffer);
                        length = strlen(number);
                        //fprintf(stderr, "%d, %d, %s\n", precision, length, number);
                        outputBuffer[outputBufferPosition++] = '.';
                        if (length <= precision) {
                            for (x = 0; x < precision - length; x++) {
                                outputBuffer[outputBufferPosition++] = _ajrDecimalDigits[0];
                            }
                        }
                        for (x = length > precision ? 1 : 0; x < length; x++) {
                            outputBuffer[outputBufferPosition++] = number[x];
                        }
                    }
                    
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    timeIntervalValue = 0.0;
                    doingTimeInterval = NO;
                } else if (doingOSType) {
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    _AJRExpandBufferIfNeeded(4);
                    outputBuffer[outputBufferPosition++] = (osType >> 24) & 0x000000FF;
                    outputBuffer[outputBufferPosition++] = (osType >> 16) & 0x000000FF;
                    outputBuffer[outputBufferPosition++] = (osType >>  8) & 0x000000FF;
                    outputBuffer[outputBufferPosition++] = (osType >>  0) & 0x000000FF;
                    
                    osType = 0;
                    doingOSType = NO;
                } else if (doingBooleanType) {
                    stage = AJRFormatStageAPriori;
                    range.location++;
                    
                    if (booleanValue) {
                        _AJRExpandBufferIfNeeded(3);
                        outputBuffer[outputBufferPosition++] = 'Y';
                        outputBuffer[outputBufferPosition++] = 'E';
                        outputBuffer[outputBufferPosition++] = 'S';
                    } else {
                        _AJRExpandBufferIfNeeded(2);
                        outputBuffer[outputBufferPosition++] = 'N';
                        outputBuffer[outputBufferPosition++] = 'O';
                    }
                    
                    booleanValue = NO;
                    doingBooleanType = NO;
                }
            }
        }
    }
    
    if ((range.length = position - range.location) > 0) {
        while (outputBufferPosition + range.length >= outputBufferMaxLength) {
            outputBufferMaxLength += 1024;
            outputBuffer = (wchar_t *)NSZoneRealloc(NULL, outputBuffer, sizeof(wchar_t) * outputBufferMaxLength);
        }
        for (NSInteger x = 0; x < range.length; x++) {
            outputBuffer[outputBufferPosition + x] = inputBuffer[range.location + x];
        }
        outputBufferPosition += range.length;
    }
    
    return [[NSString alloc] initWithBytesNoCopy:outputBuffer length:outputBufferPosition * sizeof(wchar_t) encoding:NSUTF32LittleEndianStringEncoding freeWhenDone:YES];
}

NSString *AJRFormat(NSString *format, ...) {
    va_list ap;
    NSString *returnValue;
    
    va_start(ap, format);
    returnValue = AJRFormatv(format, ap);
    va_end(ap);
    
    return returnValue;
}
