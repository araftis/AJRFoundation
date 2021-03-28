/*
NSData+Base64.m
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

#import <AJRFoundation/NSData+Base64.h>

#import "AJRFunctions.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"

//static NSArray        *magic = nil;

NSString * const AJRDataErrorDomain = @"AJRDataErrorDomain";

@implementation NSData (Base64)

//                             0000000000111111111122222222223333333333444444444455555555556666
//                             0123456789012345678901234567890123456789012345678901234567890123
//                             ----------------------------------------------------------------
//                             0000000000000000111111111111111122222222222222223333333333333333
//                             0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
const static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
const static char decodeAlphabet[] = {
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3e,0x00,0x00,0x00,0x3f,
    0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,
    0x0f,0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x00,0x00,0x00,0x00,0x00,
    0x00,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,
    0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,0x30,0x31,0x32,0x33,0x00,0x00,0x00,0x00,0x00
};

- (NSString *)ajr_base64EncodedString {
	return [self ajr_base64EncodedStringInRange:(NSRange){0, [self length]}];
}

- (NSString *)ajr_base64EncodedStringInRange:(NSRange)range {
	return [self ajr_base64EncodedStringInRange:range withLineBreakAtPosition:0];
}

- (NSString *)ajr_base64EncodedStringWithLineBreakAtPosition:(NSInteger)position {
	return [self ajr_base64EncodedStringInRange:(NSRange){0, [self length]} withLineBreakAtPosition:position];
}

- (NSString *)ajr_base64EncodedStringInRange:(NSRange)range withLineBreakAtPosition:(NSInteger)position {
	return AJRBase64EncodedString([self bytes], [self length], range, position);
}

+ (instancetype)ajr_dataWithBase64EncodedString:(NSString *)string error:(NSError **)error {
    return [[self alloc] ajr_initWithBase64EncodedString:string error:error];
}

- (instancetype)ajr_initWithBase64EncodedString:(NSString *)string error:(NSError **)error {
	uint8_t *bytes;
	NSInteger length;
	NSError *localError = AJRBase64DecodedBytes(string, &bytes, &length);
	NSData *data = nil;
	
	if (localError == nil) {
		data = [[[self class] alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
	}
	
	return AJRAssertOrPropagateError(data, error, localError);
}

@end

const NSInteger AJRBase64NoLineBreak = 0;

NSString *AJRBase64EncodedString(const uint8_t *bytes, NSInteger length, NSRange subrange, NSInteger lineBreakPosition) {
    NSInteger x, y;
    unsigned char *coded;
    NSInteger count = 0;
    
    coded = (unsigned char *)NSZoneCalloc(NSDefaultMallocZone(), length * 2, sizeof(char));
    
    for (x = subrange.location, y = 0; x < NSMaxRange(subrange) && x < length; x += 3) {
        coded[y++] = alphabet[bytes[x] >> 2];
        if (x + 1 < length) {
            coded[y++] = alphabet[((bytes[x] & 0x03) << 4) | (bytes[x + 1] >> 4)];
            if (x + 2 < length) {
                // 12-15-98 AJR (none) This had an additional if that prevented the last byte from being encoded when the length of the original bytes was a multiple of 3.
                coded[y++] = alphabet[((bytes[x + 1] & 0x0F) << 2) | (bytes[x + 2] >> 6)];
                coded[y++] = alphabet[(bytes[x + 2] & 0x3F)];
            } else {
                coded[y++] = alphabet[(bytes[x + 1] & 0x0F) << 2];
                coded[y++] = '=';
            }
        } else {
            coded[y++] = alphabet[(bytes[x] & 0x03) << 4];
            coded[y++] = '=';
        }
        if (lineBreakPosition != AJRBase64NoLineBreak) {
            count = (count + 1) % lineBreakPosition;
            if (count == 0) {
                coded[y++] = '\n';
            }
        }
    }
    
    return [[NSString alloc] initWithBytesNoCopy:(char *)coded length:y encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

NSError *AJRBase64DecodedBytes(NSString *string, uint8_t **bytesOut, NSInteger *lengthOut) {
    const char *characters = [string UTF8String];
    NSInteger x, y;
    uint8_t *decoded;
    NSInteger length = strlen(characters);
    char c1, c2, c3, c4;
    NSError *localError = nil;
    
    static NSCharacterSet *alphabetSet = nil;
    static BOOL (*isMemberFunction)(id, SEL, unichar);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alphabetSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCString:alphabet encoding:NSASCIIStringEncoding]];
        isMemberFunction = (BOOL (*)(id, SEL, unichar))[alphabetSet methodForSelector:@selector(characterIsMember:)];
    });

    decoded = (uint8_t *)NSZoneCalloc(nil, length, sizeof(char));
    for (x = 0, y = 0; x < length; ) {
        while ((x < length) && !isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            x++;
        }
        if (x != length) {
            c1 = characters[x++];
        } else {
            c1 = -1;
        }
        
        while ((x < length) && !isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            x++;
        }
        if (x != length) {
            c2 = characters[x++];
        } else {
            c2 = -1;
        }
        
        while ((x < length) && !isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            x++;
        }
        if (x != length) {
            c3 = characters[x++];
        } else {
            c3 = -1;
        }
        
        while ((x < length) && !isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            x++;
        }
        if (x != length) {
            c4 = characters[x++];
        } else {
            c4 = -1;
        }
        
        if ((c1 != -1) && (c2 != -1)) {
            decoded[y++] = (decodeAlphabet[(NSInteger)c1] << 2) | (decodeAlphabet[(NSInteger)c2] >> 4);
        } else {
            if (!(c1 == -1 && c2 == -1 && c3 == -1 && c4 == -1)) {
                localError = [NSError errorWithDomain:AJRDataErrorDomain message:@"Warning: B64 data stream is truncated."];
            }
        }
        if (c2 != -1 && c3 != -1) {
            decoded[y++] = (((NSInteger)decodeAlphabet[c2]) << 4) | ((NSInteger)decodeAlphabet[c3] >> 2);
        }
        if (c3 != -1 && c4 != -1) {
            decoded[y++] = (((NSInteger)decodeAlphabet[c3]) << 6) | (NSInteger)decodeAlphabet[c4];
        }
    }
    
    if (!localError) {
		AJRSetOutParameter(bytesOut, decoded);
		AJRSetOutParameter(lengthOut, y);
    }
    
    return localError;
}

