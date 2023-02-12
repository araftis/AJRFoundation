/*
 AJRStreamUtilities.h
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

typedef NS_ENUM (uint8_t, AJREndianness) {
   AJREndiannessBig,
   AJREndiannessLittle,
};

extern AJREndianness AJRGetCurrentArchitectureEndianness(void);

@protocol AJRByteStreamMethods <NSObject>

@property (nonatomic,assign) AJREndianness endianness;
@property (nonatomic,assign) NSStringEncoding encoding;
@property (nonatomic,readonly,nullable) NSString *encodingName;

@end

@protocol AJRByteReader <NSObject, AJRByteStreamMethods>

- (BOOL)readBytes:(void *)buffer length:(size_t)length bytesRead:(out nullable size_t *)readLength error:(out NSError * _Nullable * _Nullable)error;

@end

@protocol AJRByteWriter <NSObject, AJRByteStreamMethods>

- (BOOL)writeBytes:(const void *)bytes length:(size_t)length bytesWritten:(nullable out size_t *)bytesWritten error:(out NSError * _Nullable * _Nullable)error;

@end

@interface Test : NSObject

- (BOOL)methodWithError:(NSError **)error;

@end

@protocol AJRByteReaderMethods <NSObject>

/*!
Reads one unicode character in the streams inputEncoding setting into `character`.

@param character A pointer to the unicode character read. This is expressed in UTF-32.
@param error A pointer to an NSError which will be initialized with any error that occurs. If no error occurs, the value is set to nil.

@returns The number of bytes read to read the character. If EOF is encountered, returns 0. If an error occurs, returns 0 and initializes `error` with the error that occurred.
*/
- (size_t)readCharacter:(out uint32_t *)character error:(out NSError **)error;
- (NSString *)readLineReturningError:(out NSError * _Nullable * _Nullable)error;

- (BOOL)readInt8:(out int8_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt8:(out uint8_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readInt16:(out int16_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readInt16:(out int16_t *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt16:(out uint16_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt16:(out uint16_t *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readInt32:(out int32_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readInt32:(out int32_t *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt32:(out uint32_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt32:(out uint32_t *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readInt64:(out int64_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readInt64:(out int64_t *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt64:(out uint64_t *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readUInt64:(out uint64_t *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readFloat:(out float *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)readDouble:(out double *)value error:(out NSError * _Nullable * _Nullable)error;

/*! Reads an integer into value. Note this always reads a 64 bit value. If the value read cannot fit in NSInteger, as can be the case on 32 bit architectures, an error will be returned. */
- (BOOL)readInteger:(out NSInteger *)value error:(out NSError * _Nullable * _Nullable)error;
/*! Reads an integer into value. Note this always reads a 64 bit value. If the value read cannot fit in NSInteger, as can be the case on 32 bit architectures, an error will be returned. */
- (BOOL)readInteger:(out NSInteger *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;
/*! Reads an unsigned integer into value. Note this always reads a 64 bit value. If the value read cannot fit in NSUInteger, as can be the case on 32 bit architectures, an error will be returned. */
- (BOOL)readUInteger:(out NSUInteger *)value error:(out NSError * _Nullable * _Nullable)error;
/*! Reads an unsigned integer into value. Note this always reads a 64 bit value. If the value read cannot fit in NSUInteger, as can be the case on 32 bit architectures, an error will be returned. */
- (BOOL)readUInteger:(out NSUInteger *)value endianness:(AJREndianness)endian error:(out NSError * _Nullable * _Nullable)error;

@end

/// Indicates that indents should be written using the tab character.
extern const NSInteger AJRWidthTab;

@protocol AJRByteWriterMethods

- (BOOL)writeBytes:(const void *)bytes length:(size_t)length error:(out NSError * _Nullable * _Nullable)error;

- (BOOL)writeCharacter:(uint32_t)character bytesWritten:(size_t *)bytesWritten error:(out NSError * _Nullable * _Nullable)error;

- (BOOL)writeInt8:(int8_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt8:(uint8_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeInt16:(int16_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeInt16:(int16_t)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt16:(uint16_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt16:(uint16_t)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeInt32:(int32_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeInt32:(int32_t)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt32:(uint32_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt32:(uint32_t)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeInt64:(int64_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeInt64:(int64_t)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt64:(uint64_t)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeUInt64:(uint64_t)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeFloat:(float)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeDouble:(double)value error:(out NSError * _Nullable * _Nullable)error;

- (BOOL)writeString:(NSString *)value error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeString:(NSString *)value bytesWritten:(nullable size_t *)bytesWritten error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeIndent:(NSInteger)indent error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeIndent:(NSInteger)indent width:(NSInteger)width error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeCString:(nullable const char *)string error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)writeCString:(nullable const char *)string bytesWritten:(nullable size_t *)bytesWritten error:(out NSError * _Nullable * _Nullable)error;

/*! Writes integer to the output stream. Note that the integer is always written as a 64 bit value. Use writeInt32:error: if you'd like to write a 32 bit value. */
- (BOOL)writeInteger:(NSInteger)value error:(out NSError * _Nullable * _Nullable)error;
/*! Writes integer to the output stream. Note that the integer is always written as a 64 bit value. Use writeInt32:error: if you'd like to write a 32 bit value. */
- (BOOL)writeInteger:(NSInteger)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;
/*! Writes unsigned integer to the output stream. Note that the integer is always written as a 64 bit value. Use writeUInt32:error: if you'd like to write a 32 bit value. */
- (BOOL)writeUInteger:(NSUInteger)value error:(out NSError * _Nullable * _Nullable)error;
/*! Writes unsigned integer to the output stream. Note that the integer is always written as a 64 bit value. Use writeUInt32:error: if you'd like to write a 32 bit value. */
- (BOOL)writeUInteger:(NSUInteger)value endianness:(AJREndianness)endianness error:(out NSError * _Nullable * _Nullable)error;

@end

/*
This is basically an internal method that attempts to detemine if an encoding is 8 bit. When it is, some string reading methods can be optimized for better performance. The basic check is that if we're basically a UTF encoding greater than 8, then we need more than one byte to encode the character in the output. Otherwise, we're one of the more basic encodings, which (as far as I know) leave the bottom 32 characters alone, which means we can assume things like 0 is a null terminator and that characters like '\n' and '\r' will retain their meaning.

As a final note, this above assertion probably isn't true of EBSIDIC (sp?) encoding, but Foundation doesn't support that, so we're not going to worry about it.

Note: UTF-8 is considered 8-bit, because even though it encodes characters over multiple bytes at times, it never does so for \r or \n, which are really what we care about.
*/
extern BOOL AJREncodingIs8Bit(NSStringEncoding encoding);

#pragma mark - Read Function Primitives

extern void AJRAddReaderConveniencesToReader(Class class);

extern BOOL AJRReadCharacter(id <AJRByteReader> reader, uint32_t *character, size_t *bytesRead, NSError *_Nullable *_Nullable error);
extern NSString *AJRReadLine(NSObject<AJRByteReader> *reader, NSError *_Nullable *_Nullable error);

extern BOOL AJRReadInt8(id <AJRByteReader> reader, int8_t *value, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadUInt8(id <AJRByteReader> reader, uint8_t *value, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadInt16(id <AJRByteReader> reader, int16_t *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadUInt16(id <AJRByteReader> reader, uint16_t *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadInt32(id <AJRByteReader> reader, int32_t *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadUInt32(id <AJRByteReader> reader, uint32_t *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadInt64(id <AJRByteReader> reader, int64_t *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadUInt64(id <AJRByteReader> reader, uint64_t *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadFloat(id <AJRByteReader> reader, float *value, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadDouble(id <AJRByteReader> reader, double *value, NSError *_Nullable *_Nullable error);

extern BOOL AJRReadInteger(id <AJRByteReader> reader, NSInteger *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRReadUInteger(id <AJRByteReader> reader, NSUInteger *value, AJREndianness endianness, NSError *_Nullable *_Nullable error);

#pragma mark - Write Function Primitives

extern void AJRAddWriterConveniencesToWriter(Class class);

extern BOOL AJRWriteCharacter(id <AJRByteWriter> writer, uint32_t character, size_t *bytesWritten, NSError *_Nullable *_Nullable error);

extern BOOL AJRWriteInt8(id <AJRByteWriter> writer, int8_t value, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteUInt8(id <AJRByteWriter> writer, uint8_t value, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteInt16(id <AJRByteWriter> writer, int16_t value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteUInt16(id <AJRByteWriter> writer, uint16_t value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteInt32(id <AJRByteWriter> writer, int32_t value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteUInt32(id <AJRByteWriter> writer, uint32_t value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteInt64(id <AJRByteWriter> writer, int64_t value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteUInt64(id <AJRByteWriter> writer, uint64_t value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteFloat(id <AJRByteWriter> writer, float value, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteDouble(id <AJRByteWriter> writer, double value, NSError *_Nullable *_Nullable error);

extern BOOL AJRWriteInteger(id <AJRByteWriter> writer, NSInteger value, AJREndianness endianness, NSError *_Nullable *_Nullable error);
extern BOOL AJRWriteUInteger(id <AJRByteWriter> writer, NSUInteger value, AJREndianness endianness, NSError *_Nullable *_Nullable error);

extern BOOL AJRWriteString(id <AJRByteWriter> writer, NSString *string, size_t * _Nullable bytesWritten, NSError * _Nullable * _Nullable error);

/**
 Writes indentation out to stream. Note that this doesn't actually care if it's at the start of new line, it just writes the indent. The indent will normally be spaces of with `width`, where `indent` is the number of space to write. However, if `width == AJRWidthTab` then, the tab character is written `indent` times instead.
 
 @param writer The byte writer object.
 @param indent The number of indents to write.
 @param width The width of the tab. If equal to `AJRWidthTab`, then the tab character is used in lieu of spaces.
 @param error A pointer to an error that will be initialized if an error occurred. When calling from Swift, the error will be thrown instead.
 
 @returns `YES` on successfully writing to the stream, or `NO`, and `error` will be initialized with the error that caused the failure.
 */
extern BOOL AJRWriteIndent(id <AJRByteWriter> writer, NSInteger indent, NSInteger width, NSError **error);

/*!
 Writes a null terminate C string. Note that the string is written regardless of the file's encoding. This method litterally just writes the bytes in the C string out to the file. If you pass in NULL, just \0, the null terminator is written.
 
 @param string The null terminated  C string to write.
 @param error Any error, if one occurs. This will be unset if the method returns YES.
 
 @returns NO if an error occurs, or YES otherwise.
*/
extern BOOL AJRWriteCString(id <AJRByteWriter> writer, const char * _Nullable string, size_t * _Nullable bytesWritten, NSError * _Nullable * _Nullable error);

#pragma mark - AJRByteStreamMethods Support

extern void AJRAddByteStreamConveniencesToClass(Class class);

extern void AJRByteStreamSetEndianess(id <AJRByteStreamMethods> stream, AJREndianness endianness);
extern AJREndianness AJRByteStreamGetEndianness(id <AJRByteStreamMethods> stream);
extern void AJRByteStreamSetEncoding(id <AJRByteStreamMethods> stream, NSStringEncoding encoding);
extern NSStringEncoding AJRByteStreamGetEncoding(id <AJRByteStreamMethods> stream);
extern NSString *AJRByteStreamGetEncodingName(id <AJRByteStreamMethods> stream);

NS_ASSUME_NONNULL_END
