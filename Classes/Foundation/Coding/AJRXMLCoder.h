/*
 AJRXMLCoder.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRXMLCodingException;
extern NSString * const AJRXMLCodingErrorDomain;
extern NSString * const AJRXMLCodingLogDomain;

typedef void (^AJRXMLUnarchiverFinalizer)(void);
typedef BOOL (^AJRXMLUnarchiverGenericSetter)(id _Nullable rawValue, NSError * _Nullable * _Nullable error);

@class AJRVariableType;

@interface NSObject (AJRXMLCoding)

@property (nonatomic,class,readonly) NSString *ajr_nameForXMLArchiving;
@property (nonatomic,readonly) NSString *ajr_nameForXMLArchiving;
@property (nonatomic,class,readonly) Class ajr_classForXMLArchiving;
@property (nonatomic,readonly) Class ajr_classForXMLArchiving;

@end

@interface AJRXMLCoder : NSObject

- (id)initWithStream:(NSStream *)stream;

@property (nonatomic,readonly) NSStream *stream;

- (void)encodeRootObject:(id)object forKey:(nullable NSString *)key;

- (void)encodeObject:(id)object;
- (void)encodeObject:(nullable id)object forKey:(NSString *)key;
- (void)encodeObjectReference:(id)object;
- (void)encodeObjectReference:(nullable id)object forKey:(NSString *)key;
- (void)encodeBool:(BOOL)number forKey:(NSString *)key;
- (void)encodeInteger:(NSInteger)number forKey:(NSString *)key;
- (void)encodeInt:(int)number forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)number forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)number forKey:(NSString *)key;
- (void)encodeUInteger:(NSUInteger)number forKey:(NSString *)key;
- (void)encodeUInt:(unsigned int)number forKey:(NSString *)key;
- (void)encodeUInt32:(uint32_t)number forKey:(NSString *)key;
- (void)encodeUInt64:(uint64_t)number forKey:(NSString *)key;
- (void)encodeFloat:(float)number forKey:(NSString *)key;
- (void)encodeDouble:(double)number forKey:(NSString *)key;
- (void)encodeCGFloat:(CGFloat)number forKey:(NSString *)key;
- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length;
- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length forKey:(NSString *)key;
- (void)encodeRange:(NSRange)range forKey:(NSString *)key;
// Additional conveniences that produce slightly nicer results than the default implementations
- (void)encodeObjectIfNotNil:(nullable id)object forKey:(NSString *)key;
- (void)encodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block;
- (void)encodeString:(NSString *)value forKey:(NSString *)key;
- (void)encodeCString:(const char *)value forKey:(NSString *)key;
- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format arguments:(va_list)args;
- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format, ...;
- (void)encodeText:(NSString *)text;
- (void)encodeText:(NSString *)text forKey:(NSString *)key;
- (void)encodeComment:(NSString *)text;
- (void)encodeURL:(NSURL *)url forKey:(NSString *)key;
- (void)encodeURLBookmark:(NSURL *)url forKey:(NSString *)key;
- (void)encodeVariableType:(AJRVariableType *)type forKey:(NSString *)key;

/// The name of the element being encoded. Not normaly needed, but some advanced usages might want access to this.
@property (nullable,nonatomic,strong) NSString *encodingName;

- (void)finalizeDecodeWithBlock:(AJRXMLUnarchiverFinalizer)finalizer;
- (void)decodeObjectForKey:(NSString *)key setter:(nullable void (^)(id _Nullable object))setter;
- (void)decodeObjectUsingSetter:(nullable void (^)(id object))setter;
- (void)decodeStringForKey:(NSString *)key setter:(nullable void (^)(NSString *string))setter;
- (void)decodeCStringForKey:(NSString *)key setter:(nullable void (^)(const char *string))setter;
- (void)decodeBoolForKey:(NSString *)key setter:(nullable void (^)(BOOL value))setter;
- (void)decodeIntegerForKey:(NSString *)key setter:(nullable void (^)(NSInteger value))setter;
- (void)decodeIntForKey:(NSString *)key setter:(nullable void (^)(int value))setter;
- (void)decodeInt32ForKey:(NSString *)key setter:(nullable void (^)(int32_t value))setter;
- (void)decodeInt64ForKey:(NSString *)key setter:(nullable void (^)(int64_t value))setter;
- (void)decodeUIntegerForKey:(NSString *)key setter:(nullable void (^)(NSUInteger value))setter;
- (void)decodeUIntForKey:(NSString *)key setter:(nullable void (^)(unsigned int value))setter;
- (void)decodeUInt32ForKey:(NSString *)key setter:(nullable void (^)(uint32_t value))setter;
- (void)decodeUInt64ForKey:(NSString *)key setter:(nullable void (^)(uint64_t value))setter;
- (void)decodeFloatForKey:(NSString *)key setter:(nullable void (^)(float value))setter;
- (void)decodeDoubleForKey:(NSString *)key setter:(nullable void (^)(double value))setter;
- (void)decodeCGFloatForKey:(NSString *)key setter:(nullable void (^)(CGFloat value))setter;
- (void)decodeBytesForKey:(NSString *)key setter:(nullable void (^)(uint8_t *, NSUInteger length))setter;
- (void)decodeBytesUsingSetter:(nullable void (^)(uint8_t *, NSUInteger length))setter;
- (void)decodeRangeForKey:(NSString *)key setter:(void (^)(NSRange range))setter;
// Additional conveniences that produce slightly nicer results than the default implementations
- (void)decodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block setter:(nullable void (^)(void))setter;
- (void)decodeTextUsingSetter:(void (^)(NSString *))setter;
- (void)decodeURLForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter;
- (void)decodeURLBookmarkForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter;
- (void)decodeVariableTypeForKey:(NSString *)key setter:(nullable void (^)(AJRVariableType * _Nullable))setter;

/// The name of the element being decoding. Not normaly needed, but some advanced usages might want access to this.
@property (nullable,nonatomic,strong) NSString *decodingName;

/**
 If called, the current group will attempt to decode greedily, which means that as soon as a key's setted value is know, the setter will be called. We normally decode lazily, which is preferred.

 This only applies to the currently active group, so current the `-[NSCoding decodeWithXMLCoder:]` implementation.
 */
- (void)decodeGreedily;

@end

extern NSNumberFormatter *AJRXMLCoderGetDoubleFormatter(void); // Formatter with 10 places after decimal.
extern NSNumberFormatter *AJRXMLCoderGetFloatFormatter(void); // Formatter with 5 places after decimal.

NS_ASSUME_NONNULL_END
