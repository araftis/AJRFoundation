/*
AJRXMLCoder.m
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

#import "AJRXMLCoder.h"

#import "AJRFormat.h"
#import "AJRXMLOutputStream.h"
#import "NSObject+Extensions.h"
#import "NSOutputStream+Extensions.h"

NSString * const AJRXMLCodingException = @"AJRXMLCodingException";
NSString * const AJRXMLCodingErrorDomain = @"AJRXMLCodingErrorDomain";
NSString * const AJRXMLCodingLogDomain = @"AJRXMLCodingLogDomain";

@implementation NSObject (AJRXMLCoding)

#pragma mark - XML Coding Support

+ (NSString *)ajr_nameForXMLArchiving {
    return NSStringFromClass(self);
}

- (NSString *)ajr_nameForXMLArchiving {
    return [[self class] ajr_nameForXMLArchiving];
}

+ (Class)ajr_classForXMLArchiving {
    return self;
}

- (Class)ajr_classForXMLArchiving {
    return [[self class] ajr_classForXMLArchiving];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[self alloc] init];
}

@end

@interface AJRXMLCoder ()

@end

@implementation AJRXMLCoder

#pragma mark - Creation

- (id)initWithStream:(NSStream *)stream {
    if ((self = [super init])) {
        _stream = stream;
    }
    return self;
}

#pragma mark - Encoding

- (void)encodeRootObject:(id)object forKey:(NSString *)key {
}

- (void)encodeObject:(id)object {
}

- (void)encodeObjectReference:(id)object {
}

- (void)encodeObject:(id)object forKey:(NSString *)key {
}

- (void)encodeObjectReference:(id)object forKey:(NSString *)key {
}

- (void)encodeBool:(BOOL)number forKey:(NSString *)key {
}

- (void)encodeInteger:(NSInteger)number forKey:(NSString *)key {
}

- (void)encodeInt:(int)number forKey:(NSString *)key {
}

- (void)encodeInt32:(int32_t)number forKey:(NSString *)key {
}

- (void)encodeInt64:(int64_t)number forKey:(NSString *)key {
}

- (void)encodeUInteger:(NSUInteger)number forKey:(NSString *)key {
}

- (void)encodeUInt:(unsigned int)number forKey:(NSString *)key {
}

- (void)encodeUInt32:(uint32_t)number forKey:(NSString *)key {
}

- (void)encodeUInt64:(uint64_t)number forKey:(NSString *)key {
}

- (void)encodeFloat:(float)number forKey:(NSString *)key {
}

- (void)encodeCGFloat:(CGFloat)number forKey:(NSString *)key {
}

- (void)encodeDouble:(double)number forKey:(NSString *)key {
}

- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length forKey:(NSString *)key {
}

- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length {
}

#pragma mark - Encoding conveniences

- (void)encodeObjectIfNotNil:(id)object forKey:(NSString *)key {
}

- (void)encodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block {
}

- (void)encodeString:(NSString *)value forKey:(NSString *)key {
}

- (void)encodeCString:(const char *)value forKey:(NSString *)key {
}

- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format arguments:(va_list)args {
}

- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format, ... {
}

- (void)encodeText:(NSString *)text {
}

- (void)encodeText:(NSString *)text forKey:(NSString *)key {
}

- (void)encodeComment:(NSString *)text {
}

- (void)encodeRange:(NSRange)range forKey:(NSString *)key {
}

- (void)encodeURL:(NSURL *)url forKey:(NSString *)key {
}

- (void)encodeURLBookmark:(NSURL *)url forKey:(NSString *)key {
}

//- (void)encodeArray:(NSArray *)array forKey:(NSString *)key objectEncoder:(void (^)(id object))objectEncoder {
//}
//
//- (void)encodeDictionary:(NSDictionary *)dictionary forKey:(NSString *)key objectEncoder:(void (^)(id key, id object))objectEncoder {
//}
//
//- (void)encodeSet:(NSSet *)set forKey:(NSString *)key objectEncoder:(void (^)(id object))objectEncoder {
//}

#pragma mark - Decoding

- (void)decodeObjectForKey:(NSString *)key setter:(void (^)(id object))setter {
}

- (void)decodeObjectUsingSetter:(void (^)(id object))setter {
}

- (void)decodeStringForKey:(NSString *)key setter:(void (^)(NSString *string))setter {
}

- (void)decodeCStringForKey:(NSString *)key setter:(nullable void (^)(const char *string))setter {
}

- (void)decodeBoolForKey:(NSString *)key setter:(void (^)(BOOL value))setter {
}

- (void)decodeIntegerForKey:(NSString *)key setter:(void (^)(NSInteger value))setter {
}

- (void)decodeIntForKey:(NSString *)key setter:(void (^)(int value))setter {
}

- (void)decodeInt32ForKey:(NSString *)key setter:(void (^)(int32_t value))setter {
}

- (void)decodeInt64ForKey:(NSString *)key setter:(void (^)(int64_t value))setter {
}

- (void)decodeUIntegerForKey:(NSString *)key setter:(void (^)(NSUInteger value))setter {
}

- (void)decodeUIntForKey:(NSString *)key setter:(void (^)(unsigned int value))setter {
}

- (void)decodeUInt32ForKey:(NSString *)key setter:(void (^)(uint32_t value))setter {
}

- (void)decodeUInt64ForKey:(NSString *)key setter:(void (^)(uint64_t value))setter {
}

- (void)decodeFloatForKey:(NSString *)key setter:(void (^)(float value))setter {
}

- (void)decodeDoubleForKey:(NSString *)key setter:(void (^)(double value))setter {
}

- (void)decodeCGFloatForKey:(NSString *)key setter:(void (^)(CGFloat value))setter {
}

- (void)decodeBytesForKey:(NSString *)key setter:(void (^)(uint8_t *, NSUInteger length))setter {
}

- (void)decodeBytesUsingSetter:(void (^)(uint8_t *, NSUInteger length))setter {
}

- (void)decodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block setter:(void (^)(void))setter {
}

- (void)decodeTextUsingSetter:(void (^)(NSString *))setter {
}

- (void)decodeRangeForKey:(NSString *)key setter:(void (^)(NSRange range))setter {
}

- (void)decodeURLForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter {
}

- (void)decodeURLBookmarkForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter {
}

- (void)finalizeDecodeWithBlock:(AJRXMLUnarchiverFinalizer)finalizer {
}

@end

NSNumberFormatter *AJRXMLCoderGetFloatFormatter(void) {
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.positiveFormat = @"0.#####";
        formatter.negativeFormat = @"-0.#####";
        formatter.locale = NSLocale.systemLocale;
    });
    return formatter;
}

NSNumberFormatter *AJRXMLCoderGetDoubleFormatter(void) {
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.positiveFormat = @"0.##########";
        formatter.negativeFormat = @"-0.##########";
        formatter.locale = NSLocale.systemLocale;
    });
    return formatter;
}
