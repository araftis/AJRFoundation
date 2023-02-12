/*
 NSFileHandle+Extensions.h
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

#import <AJRFoundation/AJRStreamUtilities.h>

NS_ASSUME_NONNULL_BEGIN

#define AJR_READ_ERROR ((size_t)(-1))
#define AJR_WRITE_ERROR ((size_t)(-1))
#define AJR_ICONV_ERROR ((iconv_t)(-1))

/*!
 Declares that NSFileHandle will implement the various read convenience methods. This will be added to NSFileHandle via AJRAddReaderConveniencesToReader().
 */
@interface NSFileHandle (AJRByteStreamExtensions) <AJRByteReaderMethods, AJRByteWriterMethods, AJRByteStreamMethods>

@end

@interface NSFileHandle (AJRExtensions) <AJRByteReader, AJRByteWriter>

#pragma mark - Opening and Creating Files

/*!
 Creates a file handle given the specified mode. This is the work horse method for creating a file handle, and i called by the other category methods below.
 */
+ (id)fileHandleWithPath:(NSString *)path mode:(NSInteger)mode create:(BOOL)createFlag permissions:(mode_t)permissions error:(out NSError * _Nullable * _Nullable)error;
+ (id)fileHandleForWritingAtPath:(NSString *)path createIfNecessary:(BOOL)flag withPermissions:(mode_t)permissions error:(out NSError * _Nullable * _Nullable)error;
+ (id)fileHandleForUpdatingAtPath:(NSString *)path createIfNecessary:(BOOL)flag withPermissions:(mode_t)permissions error:(out NSError * _Nullable * _Nullable)error;

#pragma mark - AJRByteWriter

/*!
 This is the primative write method for writing bytes into a file. On success, bytesWritten is initialized to the number of bytes written. On error, returns NO, and initializes error.

 @param bytes The buffer to write. The bytes are written as provided, with no transforms.
 @param length The number of bytes to write.
 @param bytesWritten On success, the number of bytes written. Usually equals length.
 @param error On failure, initialized with the error generated.
 
 @returns YES on success, otherwise NO.
 */
- (BOOL)writeBytes:(const void *)bytes length:(size_t)length bytesWritten:(nullable out size_t *)bytesWritten error:(out NSError * _Nullable * _Nullable)error;

#pragma mark - Reading

- (size_t)readBytes:(void *)buffer length:(size_t)length;
- (BOOL)readBytes:(void *)buffer length:(size_t)length bytesRead:(out nullable size_t *)readLength error:(out NSError * _Nullable * _Nullable)error;
/*!
 This method isn't currently correct. It basically assumes the file is ASCII (or ISO-Latin-1) encoded and can only terminate on character, if character is in the range of 0 to 255.
 */
- (NSString *)readToCharacter:(uint32_t)character error:(out NSError * _Nullable * _Nullable)error;
- (NSData *)readToByte:(uint8_t)aByte error:(out NSError * _Nullable * _Nullable)error;
// Requires that the file can seek.
- (NSString *)readCharactersInSet:(NSCharacterSet *)characters error:(out NSError **)error;
- (NSString *)readToCharacterFromSet:(NSCharacterSet *)characters error:(out NSError * _Nullable * _Nullable)error;
/*!
 Reads a C string until it encounters the null terminating character in the file.
 
 @param buffer The buffer into which to read the string. buffer should be at least maxLength bytes long.
 @param maxLength The maximum length of the buffer. Note that at most, the read string will be maxLength - 1, as room is always left for the null terminator.
 @param error A pointer to an NSError that will be initialized if an error occurs during the read.
 
 @returns YES on success, NO otherwise. When returning NO, error will be initialized if not null.
 */
- (BOOL)readCString:(char *)buffer maximumLength:(NSUInteger)maxLength error:(out NSError * _Nullable * _Nullable)error;

/* Warning! This only works on file handles that can seek! */
- (BOOL)isAtEndOfFile:(out BOOL * _Nullable)isAtEnd error:(out NSError * _Nullable * _Nullable)error;

#pragma mark - Changing File Size

- (BOOL)removeBytesInRange:(NSRange)range error:(out NSError * _Nullable * _Nullable)error;
- (BOOL)replaceDataInRange:(NSRange)range withData:(NSData *)data error:(out NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
