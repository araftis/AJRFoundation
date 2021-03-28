/*
NSOutputStream+Extensions.m
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

#import "NSOutputStream+Extensions.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSError+Extensions.h"
#import "NSString+Extensions.h"

#import <objc/runtime.h>

@implementation NSOutputStream (AJRFoundationExtensions)

#pragma mark - Accessing Underlying Data

- (NSData *)ajr_data {
    return [self propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

- (NSString *)ajr_dataAsStringUsingEncoding:(NSStringEncoding)encoding {
    NSData *data = [self ajr_data];
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

#pragma mark - Writing

- (BOOL)writeBytes:(nonnull const void *)bytes length:(size_t)length bytesWritten:(out nullable size_t *)bytesWrittenOut error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError = nil;
    NSInteger bytesWritten = [self write:bytes maxLength:length];
    BOOL success = bytesWritten >= 0;
    
    if (success) {
        AJRSetOutParameter(bytesWrittenOut, bytesWritten);
    } else {
        localError = [self streamError];
        if (localError == nil && self.streamStatus != NSStreamStatusOpen) {
            localError = [NSError errorWithDomain:NSCocoaErrorDomain message:@"Stream not open"];
        }
    }
    return AJRAssertOrPropagateError(success, error, localError);
}

- (NSInteger)writeUnicodeBOM {
    NSStringEncoding encoding = [self encoding];
    NSData *data = nil;
    if (encoding == NSUTF16LittleEndianStringEncoding) {
        static uint8_t bytes[] = { 0xFF, 0xFE };
        data = [[NSData alloc] initWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];
    } else if (encoding == NSUTF16BigEndianStringEncoding) {
        static uint8_t bytes[] = { 0xFE, 0xFF };
        data = [[NSData alloc] initWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];
    } else if (encoding == NSUTF32LittleEndianStringEncoding) {
        static uint8_t bytes[] = { 0xFF, 0xFE, 0x00, 0x00 };
        data = [[NSData alloc] initWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];
    } else if (encoding == NSUTF32BigEndianStringEncoding) {
        static uint8_t bytes[] = { 0x00, 0x00, 0xFE, 0xFF };
        data = [[NSData alloc] initWithBytesNoCopy:bytes length:sizeof(bytes) freeWhenDone:NO];
    } else {
        data = [@"" dataUsingEncoding:[self encoding]];
    }
    return [self writeData:data];
}

- (NSInteger)writeIndent:(NSInteger)indent width:(NSInteger)indentWidth {
    NSInteger written = 0;
    
    if (indent * indentWidth > 0) {
        written = [self writeString:AJRFormat(@"%*s", (int)(indent * indentWidth), "")];
    }
    
    return written;
}

- (NSInteger)writeCString:(const char *)cString {
    NSInteger cStringLength = strlen(cString);
    NSInteger written = 0;
    
    if (cStringLength > 0) {
        NSStringEncoding encoding = [self encoding];
        if (encoding == NSUTF8StringEncoding || encoding == NSASCIIStringEncoding) {
            written = [self write:(const uint8_t *)cString maxLength:cStringLength];
        } else {
            written = [self writeString:[[NSString alloc] initWithBytes:cString length:cStringLength encoding:NSUTF8StringEncoding]];
        }
    }
    
    return written;
}

- (NSInteger)writeCFormat:(const char *)cFormat arguments:(va_list)args {
    char buffer[1024];
    
    vsnprintf(buffer, sizeof(buffer), cFormat, args);
    return [self writeCString:buffer];
}

- (NSInteger)writeCFormat:(const char *)cFormat, ... {
    va_list ap;
    va_start(ap, cFormat);
    NSInteger written = [self writeCFormat:cFormat arguments:ap];
    va_end(ap);
    return written;
}

- (NSInteger)writeData:(NSData *)data {
    NSInteger written = 0;
    if ([data length]) {
        written = [self write:[data bytes] maxLength:[data length]];
    }
    return written;
}

- (NSInteger)writeString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:[self encoding] allowLossyConversion:YES];
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
    return [self writeData:data];
}

- (NSInteger)writeFormat:(NSString *)format arguments:(va_list)args {
    return [self writeString:[[NSString alloc] initWithFormat:format arguments:args]];
}

- (NSInteger)writeFormat:(NSString *)format, ... {
    va_list    ap;
    
    va_start(ap, format);
    NSInteger written = [self writeFormat:format arguments:ap];
    va_end(ap);
    return written;
}

@end
