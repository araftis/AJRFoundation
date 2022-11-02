/*
 NSData+Extensions.m
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

#import "NSData+Extensions.h"

#import "AJRFunctions.h"
#import "AJRXMLCoder.h"

@interface AJRXMLDataPlaceholder : NSObject <AJRXMLDecoding>
@property (nonatomic,readonly) BOOL isMutable;
@property (nonatomic,strong) NSData *value;
@end

@implementation AJRXMLDataPlaceholder

- (id)initWithMutableBytes:(BOOL)isMutable {
    if ((self = [super init])) {
        _isMutable = isMutable;
    }
    return self;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeBytesUsingSetter:^(uint8_t *bytes, NSUInteger length) {
        if (self->_isMutable) {
            self->_value = [[NSMutableData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
        } else {
            self->_value = [[NSData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
        }
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    return _value;
}

@end

@implementation NSData (Extensions)

- (void)ajr_dump {
    [self ajr_dumpToStream:AJRStdOut];
}

- (void)ajr_dumpToStream:(NSFileHandle *)stream {
    NSInteger x, y;
    unsigned char c;
    const unsigned char *bytes = [self bytes];
    NSInteger length = [self length];
    
    for (x = 0; x < length; x += 16) {
        AJRFPrintf(stream, @"%06X: ", x);
        for (y = x; y < x + 16; y++) {
            if (y >= length) {
                AJRFPrintf(stream, @"   ");
            } else {
                AJRFPrintf(stream, @"%02X ", bytes[y]);
            }
        }
        for (y = x; y < x + 16; y++) {
            if (y >= length) break;
            c = bytes[y];
            if (c >= 128) c-= 128;
            if (c < 32 || c > 126) c = '.'; 
            AJRFPrintf(stream, @"%c", c);
        }
        AJRFPrintf(stream, @"\n");
    }
}

#pragma mark - AJRXMLCoding

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLDataPlaceholder alloc] initWithMutableBytes:NO];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeBytes:[self bytes] length:[self length]];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"data";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSData class];
}

@end

@implementation NSMutableData (Extensions)

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLDataPlaceholder alloc] initWithMutableBytes:YES];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-data";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSMutableData class];
}

@end
