/*
 NSData+Base64.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRDataErrorDomain;

@interface NSData (Base64)

+ (nullable instancetype)ajr_dataWithBase64EncodedString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;
- (nullable instancetype)ajr_initWithBase64EncodedString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;

- (NSString *)ajr_base64EncodedString;
- (NSString *)ajr_base64EncodedStringInRange:(NSRange)range;
- (NSString *)ajr_base64EncodedStringWithLineBreakAtPosition:(NSInteger)position;
- (NSString *)ajr_base64EncodedStringInRange:(NSRange)range withLineBreakAtPosition:(NSInteger)position;

@end

extern const NSInteger AJRBase64NoLineBreak;
extern NSString *AJRBase64EncodedString(const uint8_t *bytes, NSInteger length, NSRange subrange, NSInteger lineBreakPosition);
extern NSError * _Nullable AJRBase64DecodedBytes(NSString * _Nonnull string, uint8_t * _Nonnull * _Nullable bytesOut, NSInteger * _Nonnull lengthOut);

NS_ASSUME_NONNULL_END
