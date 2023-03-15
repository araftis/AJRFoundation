/*
 AJRStreamUtilities.m
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

#import "AJRStreamUtilities.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "AJRRuntime.h"
#import "NSError+Extensions.h"

#import <iconv.h>
#import <objc/runtime.h>

const NSInteger AJRWidthTab = 0;

AJREndianness AJRGetCurrentArchitectureEndianness(void) {
    return AJR_IS_BIG_ENDIAN ? AJREndiannessBig : AJREndiannessLittle;
}

#define BUFFERSIZE    16384
#define BUFFERSIZE32  (BUFFERSIZE / sizeof(uint32_t))
#define AJR_ICONV_ERROR ((iconv_t)(-1))
#define AJR_READ_ERROR ((NSInteger)(-1))

@interface AJRStreamLoader : NSObject
@end

@implementation AJRStreamLoader

+ (void)load {
    AJRAddReaderConveniencesToReader(objc_getClass("NSInputStream"));
    AJRAddReaderConveniencesToReader(objc_getClass("NSFileHandle"));
    AJRAddWriterConveniencesToWriter(objc_getClass("NSOutputStream"));
    AJRAddWriterConveniencesToWriter(objc_getClass("NSFileHandle"));
    AJRAddByteStreamConveniencesToClass(objc_getClass("NSInputStream"));
    AJRAddByteStreamConveniencesToClass(objc_getClass("NSOutputStream"));
    AJRAddByteStreamConveniencesToClass(objc_getClass("NSFileHandle"));
}

@end

BOOL AJREncodingIs8Bit(NSStringEncoding encoding) {
    return (encoding != NSUTF16StringEncoding
            && encoding != NSUTF16BigEndianStringEncoding
            && encoding != NSUTF16LittleEndianStringEncoding
            && encoding != NSUTF32StringEncoding
            && encoding != NSUTF32BigEndianStringEncoding
            && encoding != NSUTF32LittleEndianStringEncoding);
}

#pragma mark - Method Utilities
// Basically fronts ends class_addMethod, but warns on debug builds when a method already exists on the class.
BOOL _AJRAddMethod(Class cls, SEL name, id block, const char *types) {
    BOOL result = class_addMethod(cls, name, imp_implementationWithBlock(block), types);
#if defined(AJR_DEBUG)
    if (!result) {
        AJRLog(NULL, AJRLogLevelWarning, @"Failed to install method %S on %C.", name, cls);
    }
#endif
    return result;
}

#pragma mark - Installing Reader Methods

void AJRAddReaderConveniencesToReader(Class class) {
    // readCharacter
    _AJRAddMethod(class, @selector(readCharacter:error:), ^(id <AJRByteReader> self, uint32_t *characterOut, NSError **error) {
        size_t bytesRead = 0;
        if (AJRReadCharacter(self, characterOut, &bytesRead, error)) {
            return bytesRead;
        }
        return (size_t)-1;
    }, AJRMethodSignature(@encode(BOOL), @encode(int8_t *), @encode(NSError * _Nullable __autoreleasing *)));
    
    // readLine
    _AJRAddMethod(class, @selector(readLineReturningError:), ^(NSObject<AJRByteReader> *self, NSError **error) {
        return AJRReadLine(self, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSError * _Nullable __autoreleasing *)));

    // int8_t & uint8_t
    _AJRAddMethod(class, @selector(readInt8:error:), ^(id <AJRByteReader> self, int8_t *value, NSError **error) {
        return AJRReadInt8(self, value, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int8_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt8:error:), ^(id <AJRByteReader> self, uint8_t *value, NSError **error) {
        return AJRReadUInt8(self, value, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint8_t *), @encode(NSError * _Nullable __autoreleasing *)));
    
    // int16_t & uint16_t
    _AJRAddMethod(class, @selector(readInt16:error:), ^(id <AJRByteReader> self, int16_t *value, NSError **error) {
        return AJRReadInt16(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int16_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readInt16:endianness:error:), ^(id <AJRByteReader> self, int16_t *value, AJREndianness endianness, NSError **error) {
        return AJRReadInt16(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int16_t *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt16:error:), ^(id <AJRByteReader> self, uint16_t *value, NSError **error) {
        return AJRReadUInt16(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint16_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt16:endianness:error:), ^(id <AJRByteReader> self, uint16_t *value, AJREndianness endianness, NSError **error) {
        return AJRReadUInt16(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint16_t *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    
    // int32_t & uint32_t
    _AJRAddMethod(class, @selector(readInt32:error:), ^(id <AJRByteReader> self, int32_t *value, NSError **error) {
        return AJRReadInt32(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int32_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readInt32:endianness:error:), ^(id <AJRByteReader> self, int32_t *value, AJREndianness endianness, NSError **error) {
        return AJRReadInt32(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int32_t *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt32:error:), ^(id <AJRByteReader> self, uint32_t *value, NSError **error) {
        return AJRReadUInt32(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint32_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt32:endianness:error:), ^(id <AJRByteReader> self, uint32_t *value, AJREndianness endianness, NSError **error) {
        return AJRReadUInt32(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint32_t *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    
    // int64_t & uint64_t
    _AJRAddMethod(class, @selector(readInt64:error:), ^(id <AJRByteReader> self, int64_t *value, NSError **error) {
        return AJRReadInt64(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int64_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readInt64:endianness:error:), ^(id <AJRByteReader> self, int64_t *value, AJREndianness endianness, NSError **error) {
        return AJRReadInt64(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int64_t *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt64:error:), ^(id <AJRByteReader> self, uint64_t *value, NSError **error) {
        return AJRReadUInt64(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint64_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInt64:endianness:error:), ^(id <AJRByteReader> self, uint64_t *value, AJREndianness endianness, NSError **error) {
        return AJRReadUInt64(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint64_t *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    
    // NSInteger & NSUInteger
    _AJRAddMethod(class, @selector(readInteger:error:), ^(id <AJRByteReader> self, NSInteger *value, NSError **error) {
        return AJRReadInteger(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSInteger *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readInteger:endianness:error:), ^(id <AJRByteReader> self, NSInteger *value, AJREndianness endianness, NSError **error) {
        return AJRReadInteger(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSInteger *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInteger:error:), ^(id <AJRByteReader> self, NSUInteger *value, NSError **error) {
        return AJRReadUInteger(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSUInteger *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readUInteger:endianness:error:), ^(id <AJRByteReader> self, NSUInteger *value, AJREndianness endianness, NSError **error) {
        return AJRReadUInteger(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSUInteger *), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));

    // float & double
    _AJRAddMethod(class, @selector(readFloat:error:), ^(id <AJRByteReader> self, float *value, NSError **error) {
        return AJRReadFloat(self, value, error);
    }, AJRMethodSignature(@encode(void), @encode(float *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(readDouble:error:), ^(id <AJRByteReader> self, double *value, NSError **error) {
        return AJRReadDouble(self, value, error);
    }, AJRMethodSignature(@encode(void), @encode(double *), @encode(NSError * _Nullable __autoreleasing *)));
}

#pragma mark - Read Function Primitives

BOOL AJRReadCharacter(id <AJRByteReader> reader, uint32_t *characterOut, size_t *bytesRead, NSError **error) {
    NSError *localError = nil;
    BOOL success = YES;
    uint32_t character = 0;
    const char *encodingNameString = [reader.encodingName ?: @"UTF-8" UTF8String];
    iconv_t cd = iconv_open("UTF-32LE", encodingNameString);
    
    AJRAssert(cd != AJR_ICONV_ERROR, @"Failed to open iconv_open. This should never fail.");
    
    size_t position = 0;
    
    // We're going to assume that we'll have a valid character after reading 16 bytes, or else we're in trouble.
    uint8_t inputBuffer[16];
    char *inputPointer = (char *)inputBuffer;
    uint8_t outputBuffer[16];
    char *outputPointer = (char *)outputBuffer;
    
    for (position = 0; position < 16; position++) {
        size_t readLength;
        success = [reader readBytes:&(inputBuffer[position]) length:1 bytesRead:&readLength error:&localError];
        if (!success) {
            // We've got an error.
            character = 0;
            position = AJR_READ_ERROR;
            break;
        } else if (readLength == 0) {
            // We hit end-of-file, so just return 0
            character = 0;
            break;
        } else {
            // We're good, see if we can convert to our character encoding.
            size_t bytesWritten = 16;
            size_t length = position + 1;
            size_t result = iconv(cd, &inputPointer, &length, &outputPointer, &bytesWritten);
            if (result == AJR_READ_ERROR) {
                // We don't care about 0 or nothing read, because as far as we're concerned, this just means we haven't read a valid character yet.
            } else {
                // Because we're decoding to UTF-32, we always expect bytes written to be 4.
                AJRAssert(16 - bytesWritten == 4, @"We always expect 1 and exactly one UTF-32 character, but we consumed %d bytes, not 4 as expected by UTF-32.", (int)(16 - bytesWritten));
                character = ((outputBuffer[0] <<  0) |
                             (outputBuffer[1] <<  8) |
                             (outputBuffer[2] << 16) |
                             (outputBuffer[3] << 24));
                position++; // Increment, because we consumed a character.
                break;
            }
        }
    }
    
    if (position == 16) {
        // We read 16 bytes and couldn't produce a valid unicode character, so produce an error instead
        character = 0;
        position = 0;
        localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:EILSEQ];
        success = NO;
    }
    
    iconv_close(cd);

    if (success) {
        AJRSetOutParameter(characterOut, character);
        AJRSetOutParameter(bytesRead, position);
    }

    return AJRAssertOrPropagateError(success, error, localError);
}

static NSInteger AJRCharacterKey = 0;
static void AJRPushCharacter(id object, uint32_t character) {
    objc_setAssociatedObject(object, &AJRCharacterKey, @(character), OBJC_ASSOCIATION_RETAIN);
}

static BOOL AJRPopCharacter(id object, uint32_t *character) {
    NSNumber *value = objc_getAssociatedObject(object, &AJRCharacterKey);
    if (value) {
        objc_setAssociatedObject(object, &AJRCharacterKey, nil, OBJC_ASSOCIATION_RETAIN);
        AJRSetOutParameter(character, (uint32_t)value.unsignedIntegerValue);
        return YES;
    }
    return NO;
}

NSString *AJRReadLine(NSObject<AJRByteReader> *reader, NSError **error) {
    if (AJREncodingIs8Bit(reader.encoding)) {
        NSError *localError = nil;
        char buffer[BUFFERSIZE];
        NSInteger pos;
        BOOL lastWasCR = NO;
        BOOL hitEOF = NO;
        
        // Mont - 9/21/99
        // Clear out the buffer.
        memset(buffer, 0, BUFFERSIZE);
        
        uint32_t lastCharacter;
        if (AJRPopCharacter(reader, &lastCharacter)) {
            buffer[0] = (char)lastCharacter;
            pos = 1;
        } else {
            pos = 0;
        }
        
        for (; pos < BUFFERSIZE; pos++) {
            size_t bytesRead = 0;
            BOOL success = [reader readBytes:&(buffer[pos]) length:1 bytesRead:&bytesRead error:&localError];
            if (!success) {
                // We hit an error, so we're going to return it.
                localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
                break;
            }
            if (bytesRead == 0) {
                // Hit EOF, so bail.
                hitEOF = YES;
                break;
            }
            
            // Mont - 9/21/99
            // Since pos can go to -1 only check for '\n' if '\r' was false.
            if (buffer[pos] == '\r') {
                pos--;
                lastWasCR = YES;
            } else if (buffer[pos] == '\n') {
                buffer[pos] = '\0';
                break;
            } else if (lastWasCR) {
                // This is necessary, because we need to distinguish between cr/nl endings and just cr endings, and the only way to determine that is to read one character past the \r. To do this, we "push" the character into private storage, and then we'll use it when called again. This is a little hacky, but generally when calling readLine, you'll do it over and over, not intersperced with other calls.
                AJRPushCharacter(reader, buffer[pos]);
                break;
            }
        }
        
        if (localError != nil) {
            AJRSetOutParameter(error, localError);
            return nil;
        }
        
        if (hitEOF && pos == 0) {
            return nil;
        }
        
        if (reader.encoding == NSASCIIStringEncoding) {
            // Treat this encoding as completely "raw", meaning all characters above 127 will just be passed through, as is, with no interpretation of the encoding.
            return [NSString stringWithRawBytes:(unsigned char *)buffer length:pos];
        }
        
        return [[NSString alloc] initWithBytes:buffer length:pos encoding:reader.encoding];
    } else {
        NSError *localError = nil;
        uint32_t buffer[BUFFERSIZE32];
        NSInteger pos;
        BOOL lastWasCR = NO;
        BOOL hitEOF = NO;
        
        // Mont - 9/21/99
        // Clear out the buffer.
        memset(buffer, 0, BUFFERSIZE32);
        
        if (AJRPopCharacter(reader, &buffer[0])) {
            pos = 1;
        } else {
            pos = 0;
        }
        
        for (; pos < BUFFERSIZE32; pos++) {
            size_t bytesRead = 0;
            BOOL success = AJRReadCharacter(reader, &(buffer[pos]), &bytesRead, &localError);
            
            if (!success) {
                // We hit an error, so we're going to return it.
                break;
            }
            if (bytesRead == 0) {
                // We hit EOF, so stop reading.
                hitEOF = YES;
                break;
            }
            // Otherwise we're good, so soldier on.
            
            // Mont - 9/21/99
            // Since pos can go to -1 only check for '\n' if '\r' was false.
            if (buffer[pos] == '\r') {
                pos--;
                lastWasCR = YES;
            } else if (buffer[pos] == '\n') {
                buffer[pos] = '\0';
                break;
            } else if (lastWasCR) {
                // This is necessary, because we need to distinguish between cr/nl endings and just cr endings, and the only way to determine that is to read one character past the \r. To do this, we "push" the character into private storage, and then we'll use it when called again. This is a little hacky, but generally when calling readLine, you'll do it over and over, not intersperced with other calls.
                AJRPushCharacter(reader, buffer[pos]);
                break;
            }
        }
        
        if (localError != nil) {
            AJRSetOutParameter(error, localError);
            return nil;
        }
        
        // On EOF, if we've not read anything yet, we return nil, because that makes for a nice loop structure, even though it's not strictly conformant to how NSError's generally work.
        // NOTE: We can't quite get 100% code coverage here, becuase we can only test for one arch type, either little or big endian, but not both.
        return (hitEOF && pos == 0) ? nil : [[NSString alloc] initWithBytes:buffer length:pos * sizeof(uint32_t) encoding:AJR_IS_BIG_ENDIAN ? NSUTF32BigEndianStringEncoding : NSUTF32LittleEndianStringEncoding];
    }
}

BOOL AJRReadInt8(id <AJRByteReader> reader, int8_t *value, NSError **error) {
    return [reader readBytes:value length:1 bytesRead:NULL error:error];
}

BOOL AJRReadUInt8(id <AJRByteReader> reader, uint8_t *value, NSError **error) {
    return [reader readBytes:value length:1 bytesRead:NULL error:error];
}

BOOL AJRReadInt16(id <AJRByteReader> reader, int16_t *value, AJREndianness endianness, NSError **error) {
    int16_t work = 0;
    if ([reader readBytes:&work length:sizeof(work) bytesRead:NULL error:error]) {
        work = endianness == AJREndiannessBig ? CFSwapInt16BigToHost(work) : CFSwapInt16LittleToHost(work);
        AJRSetOutParameter(value, work);
        return YES;
    }
    return NO;
}

BOOL AJRReadUInt16(id <AJRByteReader> reader, uint16_t *value, AJREndianness endianness, NSError **error) {
    int16_t work = 0;
    if ([reader readBytes:&work length:sizeof(work) bytesRead:NULL error:error]) {
        work = endianness == AJREndiannessBig ? CFSwapInt16BigToHost(work) : CFSwapInt16LittleToHost(work);
        AJRSetOutParameter(value, work);
        return YES;
    }
    return NO;
}

BOOL AJRReadInt32(id <AJRByteReader> reader, int32_t *value, AJREndianness endianness, NSError **error) {
    int32_t work = 0;
    if ([reader readBytes:&work length:sizeof(work) bytesRead:NULL error:error]) {
        work = endianness == AJREndiannessBig ? CFSwapInt32BigToHost(work) : CFSwapInt32LittleToHost(work);
        AJRSetOutParameter(value, work);
        return YES;
    }
    return NO;
}

BOOL AJRReadUInt32(id <AJRByteReader> reader, uint32_t *value, AJREndianness endianness, NSError **error) {
    int32_t work = 0;
    if ([reader readBytes:&work length:sizeof(work) bytesRead:NULL error:error]) {
        work = endianness == AJREndiannessBig ? CFSwapInt32BigToHost(work) : CFSwapInt32LittleToHost(work);
        AJRSetOutParameter(value, work);
        return YES;
    }
    return NO;
}

BOOL AJRReadInt64(id <AJRByteReader> reader, int64_t *value, AJREndianness endianness, NSError **error) {
    int64_t work = 0;
    if ([reader readBytes:&work length:sizeof(work) bytesRead:NULL error:error]) {
        work = endianness == AJREndiannessBig ? CFSwapInt64BigToHost(work) : CFSwapInt64LittleToHost(work);
        AJRSetOutParameter(value, work);
        return YES;
    }
    return NO;
}

BOOL AJRReadUInt64(id <AJRByteReader> reader, uint64_t *value, AJREndianness endianness, NSError **error) {
    int64_t work = 0;
    if ([reader readBytes:&work length:sizeof(work) bytesRead:NULL error:error]) {
        work = endianness == AJREndiannessBig ? CFSwapInt64BigToHost(work) : CFSwapInt64LittleToHost(work);
        AJRSetOutParameter(value, work);
        return YES;
    }
    return NO;
}

BOOL AJRReadFloat(id <AJRByteReader> reader, float *value, NSError **error) {
    CFSwappedFloat32 swapped;
    if ([reader readBytes:&swapped length:sizeof(swapped) bytesRead:NULL error:error]) {
        AJRSetOutParameter(value, CFConvertFloat32SwappedToHost(swapped));
        return YES;
    }
    return NO;
}

BOOL AJRReadDouble(id <AJRByteReader> reader, double *value, NSError **error) {
    CFSwappedFloat64 swapped;
    if ([reader readBytes:&swapped length:sizeof(swapped) bytesRead:NULL error:error]) {
        AJRSetOutParameter(value, CFConvertFloat64SwappedToHost(swapped));
        return YES;
    }
    return NO;
}

BOOL AJRReadInteger(id <AJRByteReader> reader, NSInteger *value, AJREndianness endianness, NSError *_Nullable *_Nullable error) {
    int64_t intermediateValue;
    NSError *localError = nil;
    BOOL success;
    
    success = AJRReadInt64(reader, &intermediateValue, endianness, &localError);
    if (success) {
        if (sizeof(NSInteger) == 4 && (intermediateValue > INT32_MAX || intermediateValue < INT32_MIN)) {
            // We're bad, because we're on 32 bit architecture, and the value read is greater than would fit in our output value.
            success = NO;
            localError = [NSError errorWithDomain:NSPOSIXErrorDomain format:@"Value read from file would overflow NSInteger on 32 bit architecture."];
        } else {
            // We're good.
            AJRSetOutParameter(value, intermediateValue);
        }
    }
    
    return AJRAssertOrPropagateError(success, error, localError);
}

BOOL AJRReadUInteger(id <AJRByteReader> reader, NSUInteger *value, AJREndianness endianness, NSError *_Nullable *_Nullable error) {
    uint64_t intermediateValue;
    NSError *localError = nil;
    BOOL success;
    
    success = AJRReadUInt64(reader, &intermediateValue, endianness, &localError);
    if (success) {
        if (sizeof(NSUInteger) == 4 && intermediateValue > UINT32_MAX) {
            // We're bad, because we're on 32 bit architecture, and the value read is greater than would fit in our output value.
            success = NO;
            localError = [NSError errorWithDomain:NSPOSIXErrorDomain format:@"Value read from file would overflow NSUInteger on 32 bit architecture."];
        } else {
            // We're good.
            AJRSetOutParameter(value, intermediateValue);
        }
    }
    
    return AJRAssertOrPropagateError(success, error, localError);
}

#pragma mark - Write Function Primitives

void AJRAddWriterConveniencesToWriter(Class class) {
    // int8_t & uint8_t
    _AJRAddMethod(class, @selector(writeInt8:error:), ^(id <AJRByteWriter> self, int8_t value, NSError **error) {
        return AJRWriteInt8(self, value, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int8_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt8:error:), ^(id <AJRByteWriter> self, uint8_t value, NSError **error) {
        return AJRWriteUInt8(self, value, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint8_t), @encode(NSError * _Nullable __autoreleasing *)));
    
    // int16_t & uint16_t
    _AJRAddMethod(class, @selector(writeInt16:error:), ^(id <AJRByteWriter> self, int16_t value, NSError **error) {
        return AJRWriteInt16(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int16_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeInt16:endianness:error:), ^(id <AJRByteWriter> self, int16_t value, AJREndianness endianness, NSError **error) {
        return AJRWriteInt16(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int16_t), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt16:error:), ^(id <AJRByteWriter> self, uint16_t value, NSError **error) {
        return AJRWriteUInt16(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint16_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt16:endianness:error:), ^(id <AJRByteWriter> self, uint16_t value, AJREndianness endianness, NSError **error) {
        return AJRWriteUInt16(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint16_t), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    
    // int32_t & uint32_t
    _AJRAddMethod(class, @selector(writeInt32:error:), ^(id <AJRByteWriter> self, int32_t value, NSError **error) {
        return AJRWriteInt32(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int32_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeInt32:endianness:error:), ^(id <AJRByteWriter> self, int32_t value, AJREndianness endianness, NSError **error) {
        return AJRWriteInt32(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int32_t), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt32:error:), ^(id <AJRByteWriter> self, uint32_t value, NSError **error) {
        return AJRWriteUInt32(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint32_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt32:endianness:error:), ^(id <AJRByteWriter> self, uint32_t value, AJREndianness endianness, NSError **error) {
        return AJRWriteUInt32(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint32_t), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    
    // int64_t & uint64_t
    _AJRAddMethod(class, @selector(writeInt64:error:), ^(id <AJRByteWriter> self, int64_t value, NSError **error) {
        return AJRWriteInt64(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int64_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeInt64:endianness:error:), ^(id <AJRByteWriter> self, int64_t value, AJREndianness endianness, NSError **error) {
        return AJRWriteInt64(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(int64_t), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt64:error:), ^(id <AJRByteWriter> self, uint64_t value, NSError **error) {
        return AJRWriteUInt64(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint64_t), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInt64:endianness:error:), ^(id <AJRByteWriter> self, uint64_t value, AJREndianness endianness, NSError **error) {
        return AJRWriteUInt64(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint64_t), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    
    // NSInteger & NSUInteger
    _AJRAddMethod(class, @selector(writeInteger:error:), ^(id <AJRByteWriter> self, NSInteger value, NSError **error) {
        return AJRWriteInteger(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSInteger), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeInteger:endianness:error:), ^(id <AJRByteWriter> self, NSInteger value, AJREndianness endianness, NSError **error) {
        return AJRWriteInteger(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSInteger), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInteger:error:), ^(id <AJRByteWriter> self, NSUInteger value, NSError **error) {
        return AJRWriteUInteger(self, value, self.endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSUInteger), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeUInteger:endianness:error:), ^(id <AJRByteWriter> self, NSUInteger value, AJREndianness endianness, NSError **error) {
        return AJRWriteUInteger(self, value, endianness, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSUInteger), @encode(AJREndianness), @encode(NSError * _Nullable __autoreleasing *)));

    // float & double
    _AJRAddMethod(class, @selector(writeFloat:error:), ^(id <AJRByteWriter> self, float value, NSError **error) {
        return AJRWriteFloat(self, value, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(float), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeDouble:error:), ^(id <AJRByteWriter> self, double value, NSError **error) {
        return AJRWriteDouble(self, value, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(double), @encode(NSError * _Nullable __autoreleasing *)));
    
    // bytes
    _AJRAddMethod(class, @selector(writeBytes:length:error:), ^(id <AJRByteWriter> self, void *bytes, size_t length, NSError **error) {
        return [self writeBytes:bytes length:length bytesWritten:NULL error:error];
    }, AJRMethodSignature(@encode(BOOL), @encode(void *), @encode(size_t), @encode(NSError * _Nullable __autoreleasing *)));
    
    // strings
    _AJRAddMethod(class, @selector(writeCharacter:bytesWritten:error:), ^(id <AJRByteWriter> self, uint32_t character, size_t *bytesWritten, NSError **error) {
        return AJRWriteCharacter(self, character, bytesWritten, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(uint32_t), @encode(size_t *), @encode(NSError * _Nullable __autoreleasing)));
    _AJRAddMethod(class, @selector(writeString:bytesWritten:error:), ^(id <AJRByteWriter> self, NSString *string, size_t *bytesWritten, NSError **error) {
        return AJRWriteString(self, string, bytesWritten, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSString *), @encode(size_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeString:error:), ^(id <AJRByteWriter> self, NSString *string, NSError **error) {
        return AJRWriteString(self, string, NULL, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSString *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeCString:bytesWritten:error:), ^(id <AJRByteWriter> self, const char *string, size_t *bytesWritten, NSError **error) {
        return AJRWriteCString(self, string, bytesWritten, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(const char *), @encode(size_t *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeCString:error:), ^(id <AJRByteWriter> self, const char *string, NSError **error) {
        return AJRWriteCString(self, string, NULL, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(const char *), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeIndent:error:), ^(id <AJRByteWriter> self, NSInteger indent, NSError **error) {
        return AJRWriteIndent(self, indent, 4, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSInteger), @encode(NSError * _Nullable __autoreleasing *)));
    _AJRAddMethod(class, @selector(writeIndent:width:error:), ^(id <AJRByteWriter> self, NSInteger indent, NSInteger width, NSError **error) {
        return AJRWriteIndent(self, indent, width, error);
    }, AJRMethodSignature(@encode(BOOL), @encode(NSInteger), @encode(NSInteger), @encode(NSError * _Nullable __autoreleasing *)));
}

BOOL AJRWriteCharacter(id <AJRByteWriter> writer, uint32_t characterIn, size_t *bytesWrittenOut, NSError **error) {
    NSError *localError = nil;
    BOOL success = YES;
    uint32_t character = CFSwapInt32HostToLittle(characterIn);
    const char *sourceEncodingName = "UTF-32LE";
    const char *destinationEncodingName = [writer.encodingName ?: @"UTF-8" UTF8String];
    iconv_t cd = iconv_open(destinationEncodingName, sourceEncodingName);
    
    AJRAssert(cd != AJR_ICONV_ERROR, @"Failed to open iconv_open. This should never fail.");
    
    uint8_t outputBuffer[16];
    char *outputPointer = (char *)outputBuffer;
    char *inputPointer = (char *)&character;
    size_t bytesRemaining = 16;
    size_t length = 4;
    size_t result = iconv(cd, &inputPointer, &length, &outputPointer, &bytesRemaining);
    
    if (result == 0) {
        size_t bytesWritten = 0;
        success = [writer writeBytes:&outputBuffer length:16 - bytesRemaining bytesWritten:&bytesWritten error:&localError];
        if (success) {
            AJRSetOutParameter(bytesWrittenOut, bytesWritten);
        }
    } else {
        success = NO;
        localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
    }
    
    iconv_close(cd);
    
    return AJRAssertOrPropagateError(success, error, localError);
}

BOOL AJRWriteInt8(id <AJRByteWriter> writer, int8_t value, NSError **error) {
    return [writer writeBytes:&value length:1 bytesWritten:NULL error:error];
}

BOOL AJRWriteUInt8(id <AJRByteWriter> writer, uint8_t value, NSError **error) {
    return [writer writeBytes:&value length:1 bytesWritten:NULL error:error];
}

BOOL AJRWriteInt16(id <AJRByteWriter> writer, int16_t value, AJREndianness endianness, NSError **error) {
    int16_t swapped = endianness == AJREndiannessBig ? CFSwapInt16HostToBig(value) : CFSwapInt16HostToLittle(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteUInt16(id <AJRByteWriter> writer, uint16_t value, AJREndianness endianness, NSError **error) {
    uint16_t swapped = endianness == AJREndiannessBig ? CFSwapInt16HostToBig(value) : CFSwapInt16HostToLittle(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteInt32(id <AJRByteWriter> writer, int32_t value, AJREndianness endianness, NSError **error) {
    int32_t swapped = endianness == AJREndiannessBig ? CFSwapInt32HostToBig(value) : CFSwapInt32HostToLittle(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteUInt32(id <AJRByteWriter> writer, uint32_t value, AJREndianness endianness, NSError **error) {
    uint32_t swapped = endianness == AJREndiannessBig ? CFSwapInt32HostToBig(value) : CFSwapInt32HostToLittle(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteInt64(id <AJRByteWriter> writer, int64_t value, AJREndianness endianness, NSError **error) {
    int64_t swapped = endianness == AJREndiannessBig ? CFSwapInt64HostToBig(value) : CFSwapInt64HostToLittle(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteUInt64(id <AJRByteWriter> writer, uint64_t value, AJREndianness endianness, NSError **error) {
    uint64_t swapped = endianness == AJREndiannessBig ? CFSwapInt64HostToBig(value) : CFSwapInt64HostToLittle(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteFloat(id <AJRByteWriter> writer, float value, NSError **error) {
    CFSwappedFloat32 swapped = CFConvertFloat32HostToSwapped(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteDouble(id <AJRByteWriter> writer, double value, NSError **error) {
    CFSwappedFloat64 swapped = CFConvertFloat64HostToSwapped(value);
    return [writer writeBytes:&swapped length:sizeof(swapped) bytesWritten:NULL error:error];
}

BOOL AJRWriteInteger(id <AJRByteWriter> writer, NSInteger value, AJREndianness endianness, NSError *_Nullable *_Nullable error) {
    return AJRWriteInt64(writer, value, endianness, error);
}

BOOL AJRWriteUInteger(id <AJRByteWriter> writer, NSUInteger value, AJREndianness endianness, NSError *_Nullable *_Nullable error) {
    return AJRWriteUInt64(writer, value, endianness, error);
}

BOOL AJRWriteString(id <AJRByteWriter> writer, NSString *string, size_t *bytesWritten, NSError **error) {
    // If the string is zero length, don't go through all the work of trying to write it.
    if (string.length > 0) {
        NSData *data = [string dataUsingEncoding:writer.encoding allowLossyConversion:YES];
        const uint8_t *bytes = [data bytes];
        if ([data length] >= 2
            && ((bytes[0] == 0xFF && bytes[1] == 0xFE)
                || (bytes[0] == 0xFE && bytes[1] == 0xFF))) {
            if ([data length] >= 4
                && bytes[2] == 0x00
                && bytes[3] == 0x00) {
                data = [data subdataWithRange:(NSRange){4, [data length] - 4}];
            } else {
                data = [data subdataWithRange:(NSRange){2, [data length] - 2}];
            }
        }
        return [writer writeBytes:data.bytes length:data.length bytesWritten:bytesWritten error:error];
    }
    return YES;
}

static char _spaces[] = "                                                                                                                                                                                                        ";
static char _tabs[] = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t";

BOOL AJRWriteIndent(id <AJRByteWriter> writer, NSInteger indent, NSInteger width, NSError **error) {
    BOOL written = YES;
    
    if (width == 0) {
        NSInteger tabsCount = AJRCountOf(_tabs);
        NSInteger blockSize = (indent / tabsCount) * tabsCount;
        NSInteger remainder = indent % tabsCount;

        for (NSInteger x = 0; x < indent; x += blockSize) {
            if (written) {
                written = AJRWriteString(writer, [[NSString alloc] initWithBytes:_tabs length:blockSize encoding:NSASCIIStringEncoding], NULL, error);
            }
        }
        if (written && remainder > 0) {
            written = AJRWriteString(writer, [[NSString alloc] initWithBytes:_tabs length:remainder encoding:NSASCIIStringEncoding], NULL, error);
        }
    } else {
        NSInteger spaces = indent * width;
        if (spaces > 0 && spaces < AJRCountOf(_spaces)) {
            // We'll almost always enter this loop, unless we're really, deeply indented.
            written = AJRWriteString(writer, [[NSString alloc] initWithBytes:_spaces length:spaces encoding:NSASCIIStringEncoding], NULL, error);
        } else {
            // But just in case...
            NSInteger blockSize = (spaces / AJRCountOf(_spaces)) * AJRCountOf(_spaces);
            NSInteger remainder = (spaces % AJRCountOf(_spaces));

            for (NSInteger x = 0; x < spaces; x += blockSize) {
                if (written) {
                    // Don't write if one write fails
                    written = AJRWriteString(writer, [[NSString alloc] initWithBytes:_spaces length:blockSize encoding:NSASCIIStringEncoding], NULL, error);
                }
            }
            if (written && remainder > 0) {
                written = AJRWriteString(writer, [[NSString alloc] initWithBytes:_spaces length:remainder encoding:NSASCIIStringEncoding], NULL, error);
            }
        }
    }
    
    return written;
}

BOOL AJRWriteCString(id <AJRByteWriter> writer, const char *string, size_t *bytesWritten, NSError **error) {
    if (string == NULL) {
        uint8_t null = 0;
        return [writer writeBytes:&null length:1 bytesWritten:bytesWritten error:error];
    } else {
        return [writer writeBytes:string length:strlen(string) + 1 bytesWritten:bytesWritten error:error];
    }
}

#pragma mark - Install AJRByteReader / AJRByteWriter Properties

void AJRAddByteStreamConveniencesToClass(Class class) {
    _AJRAddMethod(class, @selector(setEndianness:), ^(id <AJRByteReader> self, NSStringEncoding endianness) {
        AJRByteStreamSetEndianess(self, endianness);
    }, AJRMethodSignature(@encode(void), @encode(AJREndianness)));
    _AJRAddMethod(class, @selector(endianness), ^(id <AJRByteReader> self) {
        return AJRByteStreamGetEndianness(self);
    }, AJRMethodSignature(@encode(AJREndianness)));
    _AJRAddMethod(class, @selector(setEncoding:), ^(id <AJRByteReader> self, NSStringEncoding encoding) {
        AJRByteStreamSetEncoding(self, encoding);
    }, AJRMethodSignature(@encode(void), @encode(NSStringEncoding)));
    _AJRAddMethod(class, @selector(encoding), ^(id <AJRByteReader> self) {
        return AJRByteStreamGetEncoding(self);
    }, AJRMethodSignature(@encode(NSStringEncoding)));
    _AJRAddMethod(class, @selector(encodingName), ^(id <AJRByteReader> self) {
        return AJRByteStreamGetEncodingName(self);
    }, AJRMethodSignature(@encode(NSString *)));
}

void AJRByteStreamSetEndianess(id <AJRByteStreamMethods> stream, AJREndianness endianness) {
    objc_setAssociatedObject(stream, @selector(endianness), @(endianness), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

AJREndianness AJRByteStreamGetEndianness(id <AJRByteStreamMethods> stream) {
    NSNumber *value = objc_getAssociatedObject(stream, @selector(endianness));
    return value == nil ? AJREndiannessBig : (AJREndianness)[value integerValue];
}

void AJRByteStreamSetEncoding(id <AJRByteStreamMethods> stream, NSStringEncoding encoding) {
    if (encoding == 0) {
        objc_setAssociatedObject(stream, @selector(encoding), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(stream, @selector(encodingName), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(stream, @selector(encoding), @(encoding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(stream, @selector(encodingName), AJRIANANameFromStringEncoding(encoding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

NSStringEncoding AJRByteStreamGetEncoding(id <AJRByteStreamMethods> stream) {
    NSNumber *encoding = objc_getAssociatedObject(stream, @selector(encoding));
    return encoding == nil ? NSUTF8StringEncoding : (NSStringEncoding)encoding.integerValue;
}

NSString *AJRByteStreamGetEncodingName(id <AJRByteStreamMethods> stream) {
    NSString *encodingName = objc_getAssociatedObject(stream, @selector(encodingName));
    if (encodingName == nil) {
        // This can happen when setEncoding: hasn't been explicitly called, which is often.
        encodingName = AJRIANANameFromStringEncoding(stream.encoding);
        objc_setAssociatedObject(stream, @selector(encodingName), encodingName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return encodingName;
}
