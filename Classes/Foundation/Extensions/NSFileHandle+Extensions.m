/*
NSFileHandle+Extensions.m
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

#import "NSFileHandle+Extensions.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "NSError+Extensions.h"
#import "NSString+Extensions.h"
#import "NSObject+AJRUserInfo.h"

#import <iconv.h>
#include <sys/stat.h>

#define BUFFERSIZE    16384
#define BUFFERSIZE32  (BUFFERSIZE / sizeof(uint32_t))

typedef NS_ENUM(uint8_t, AJRUnicodeAction) {
	AJRUnicodeActionContinue,
	AJRUnicodeActionStop
};

/* For all the endian swapping stuff */
#import <CoreFoundation/CFByteOrder.h>
#import <objc/runtime.h>

typedef NSInteger (*AJRReadFunction)(id, SEL, void *, NSInteger);
typedef NSInteger (*AJRWriteFunction)(id, SEL, const void *, NSInteger);

static mode_t AJRGetUMask(void) {
	// Yeah! brain dead API. We have to call umask twice to get the value we want. Once to get the value, but said call requires us to change the value, and then once to restore the value. Obviously, this isn't thread safe, but generally probably OK, especially since we use NSFileManager to create files rather than open(), etc...
	mode_t current = umask(0);
	umask(current);
	return current;
}

@implementation NSFileHandle (AJRExtensions)

+ (id)fileHandleWithPath:(NSString *)path mode:(NSInteger)mode create:(BOOL)createFlag permissions:(mode_t)permissions error:(out NSError **)error {
    NSFileHandle *temp = nil;
	NSError *localError = nil;
    
    if (createFlag) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
			mode_t mask = AJRGetUMask();
			if (![[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data]
													   attributes:@{NSFilePosixPermissions:@(permissions & ~mask)}]) {
				localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
            }
        }
    }
    
	if (localError == nil) {
		if ((mode & O_ACCMODE) == O_RDONLY) {
			temp = [NSFileHandle fileHandleForReadingAtPath:path];
		} else if ((mode & O_ACCMODE) == O_WRONLY) {
			temp = [NSFileHandle fileHandleForWritingAtPath:path];
			[temp truncateFileAtOffset:0];
		} else if ((mode & O_ACCMODE) == O_RDWR) {
			temp = [NSFileHandle fileHandleForUpdatingAtPath:path];
			if (temp != nil) {
				if (![temp ajr_seekToEndReturningOffset:NULL error:&localError]) {
					[temp closeFile];
					temp = nil;
				}
			}
		}
		// If temp is nil at this point, we had a file creation error, so create an NSError to return to the caller.
		if (temp == nil && localError == nil) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
		}
	}
    
	return AJRAssertOrPropagateError(temp, error, localError);
}

+ (id)fileHandleForWritingAtPath:(NSString *)path createIfNecessary:(BOOL)flag withPermissions:(mode_t)permissions  error:(out NSError **)error {
    return [self fileHandleWithPath:path mode:O_WRONLY create:flag permissions:permissions error:error];
}

+ (id)fileHandleForUpdatingAtPath:(NSString *)path createIfNecessary:(BOOL)flag withPermissions:(mode_t)permissions error:(out NSError **)error {
	return [self fileHandleWithPath:path mode:O_RDWR create:flag permissions:permissions error:error];
}

// These methods were removed in favor of the above, because these, at least at one point in time, were causing memory leaks. This may no longer be an issue, but the above works fine, so I haven't tested the method below to see if they still cause a memory leak.
//- (id)_initWithPath:(NSString *)path mode:(int)mode create:(BOOL)flag {
//    int file = -1;
//
//    if (mode == O_WRONLY) {
//        mode |= O_TRUNC;
//    }
//    if (flag) {
//        mode |= O_CREAT;
//    }
//    if (flag) {
//        do {
//            file = open([path UTF8String], mode, 0666);
//        } while (file == 0);
//    } else {
//        do {
//            file = open([path UTF8String], mode);
//        } while (file == 0);
//    }
//    if (file > 0 && self == nil) {
//        self = [self initWithFileDescriptor:file closeOnDealloc:YES];
//    } else if (self == nil) {
//        NSLog(@"unable to open: %@: %s", path, strerror(errno));
//    }
//
//    return self;
//}
//
//- (id)initForReadingAtPath:(NSString *)path {
//    return [self _initWithPath:path mode:O_RDONLY create:NO];
//}
//
//- (id)initForWritingAtPath:(NSString *)path createIfNecessary:(BOOL)flag {
//    if (flag) {
//        return [self _initWithPath:path mode:O_WRONLY create:flag];
//    }
//    return [self _initWithPath:path mode:O_WRONLY create:flag];
//}
//
//- (id)initForUpdatingAtPath:(NSString *)path createIfNecessary:(BOOL)flag {
//    return [self _initWithPath:path mode:O_RDWR create:flag];
//}

#pragma mark - OS Version Workarounds

- (BOOL)ajr_truncateAtOffset:(unsigned long long)offset error:(out NSError **)error {
	if (@available(macOS 10.15, *)) {
		return [self truncateAtOffset:offset error:error];
	} else {
		NSError *localError = nil;
		@try {
			[self truncateFileAtOffset:offset];
		} @catch (NSException *localException) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno message:[localException description]];
		}
		return AJRAssertOrPropagateError(localError == nil, error, localError);
	}
}

- (BOOL)ajr_writeData:(NSData *)data error:(out NSError **)error {
	if (@available(macOS 10.15, *)) {
		return [self writeData:data error:error];
	} else {
		NSError *localError = nil;
		@try {
			[self writeData:data];
		} @catch (NSException *localException) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno message:[localException description]];
		}
		return AJRAssertOrPropagateError(localError == nil, error, localError);
	}
}

- (BOOL)ajr_seekToEndReturningOffset:(out unsigned long long *_Nullable)offsetInFile error:(out NSError **)error {
	if (@available(macOS 10.15, *)) {
		return [self seekToEndReturningOffset:offsetInFile error:error];
	} else {
		NSError *localError = nil;
		@try {
			unsigned long long length = [self seekToEndOfFile];
			AJRSetOutParameter(offsetInFile, length);
		} @catch (NSException *localException) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno message:[localException description]];
		}
		return AJRAssertOrPropagateError(localError == nil, error, localError);
	}
}

- (BOOL)ajr_seekToOffset:(unsigned long long)offset error:(out NSError **)error {
	if (@available(macOS 10.15, *)) {
		return [self seekToOffset:offset error:error];
	} else {
		NSError *localError = nil;
		@try {
			[self seekToFileOffset:offset];
		} @catch (NSException *localException) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno message:[localException description]];
		}
		return AJRAssertOrPropagateError(localError == nil, error, localError);
	}
}

#pragma mark - Primitive Writing

- (BOOL)writeBytes:(const void *)bytes length:(size_t)length bytesWritten:(nullable out size_t *)written error:(out NSError **)error {
	NSError *localError = nil;
	size_t bytesWritten = 0;
	
	@try {
		bytesWritten = write(self.fileDescriptor, bytes, length);
	} @catch (NSException *localException) {
		errno = EBADF;
		bytesWritten = AJR_WRITE_ERROR;
	}
	if (bytesWritten == AJR_WRITE_ERROR) {
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
	} else {
		AJRSetOutParameter(written, bytesWritten);
	}
	return AJRAssertOrPropagateError(bytesWritten != AJR_WRITE_ERROR, error, localError);
}

#pragma mark - Reading

- (size_t)readBytes:(void *)buffer length:(size_t)length {
	size_t bytesRead = AJR_READ_ERROR;
	@try {
		// Catching, because self.fileDescriptor throws an exception on a bad file descriptor.
		bytesRead = read(self.fileDescriptor, buffer, length);
	} @catch (NSException *localException) {
		errno = EBADF;
	}
	return bytesRead;
}

- (BOOL)readBytes:(void *)buffer length:(size_t)length bytesRead:(out size_t *)readLength error:(out NSError **)error {
	NSError *localError = nil;
	size_t bytesRead = AJR_READ_ERROR;
	@try {
		bytesRead = read(self.fileDescriptor, buffer, length);
		if (bytesRead == AJR_READ_ERROR) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
		}
	} @catch (NSException *localException) {
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain message:[localException description]];
	}
	if (bytesRead != AJR_READ_ERROR) {
		AJRSetOutParameter(readLength, bytesRead);
	} else {
		AJRSetOutParameter(readLength, 0);
	}
	return AJRAssertOrPropagateError(bytesRead != AJR_READ_ERROR, error, localError);
}

- (NSString *)readUsingUnicodeTestBlock:(AJRUnicodeAction (^)(uint32_t input))block error:(out NSError **)error {
	size_t bufferSize = BUFFERSIZE;
	uint32_t *buffer = (uint32_t *)malloc(bufferSize);
    NSInteger pos = 0;
	NSError *localError = nil;
	BOOL done = NO;
	NSString *string = nil;
    
    while (!done) {
		if (pos == bufferSize / sizeof(uint32_t)) {
			bufferSize += BUFFERSIZE;
			buffer = (uint32_t *)realloc(buffer, bufferSize);
		}
		uint32_t character;
		size_t bytesRead = [self readCharacter:&character error:&localError];
		if (bytesRead == 0) {
			if (pos > 0) {
				// We've read soemthing, so return what we've read to EOF.
				string = [[NSString alloc] initWithBytesNoCopy:buffer length:pos * sizeof(uint32_t) encoding:NSUTF32LittleEndianStringEncoding freeWhenDone:YES];
			}
			// If we read 0, then we're done, whether or not a character was read.
			done = YES;
		} else if (bytesRead == AJR_READ_ERROR) {
			// We hit an error, so we're bailing.
			string = nil; // Just in case, but should be nil already.
			done = YES;
		} else {
			switch (block(character)) {
				case AJRUnicodeActionContinue:
					buffer[pos++] = CFSwapInt32HostToLittle(character);
					break;
				case AJRUnicodeActionStop:
					if ([self ajr_seekToOffset:[self offsetInFile] - bytesRead error:&localError]) {
						if (pos == 0) {
							string = [NSString string];
						} else {
							string = [[NSString alloc] initWithBytesNoCopy:buffer length:pos * sizeof(uint32_t) encoding:NSUTF32LittleEndianStringEncoding freeWhenDone:YES];
						}
					}
					done = YES;
					break;
			}
		}
    }
	
	if (localError == nil) {
		return string;
	} else {
		AJRSetOutParameter(error, localError);
		return nil;
	}
}

- (NSString *)readToCharacter:(uint32_t)character error:(out NSError **)error {
	return [self readUsingUnicodeTestBlock:^AJRUnicodeAction(uint32_t input) {
		if (input == character) {
			return AJRUnicodeActionStop;
		}
		return AJRUnicodeActionContinue;
	} error:error];
}

- (BOOL)readToByte:(uint8_t)byte buffer:(out uint8_t **)outputBuffer length:(out size_t *)outputLength error:(out NSError **)error {
	NSError *localError;
	size_t bufferSize = BUFFERSIZE;
	uint8_t *buffer = (uint8_t *)malloc(bufferSize);
    NSInteger pos = 0;
    AJRReadFunction reader = (AJRReadFunction)[self methodForSelector:@selector(readBytes:length:)];
	BOOL done = NO;
	BOOL hitEOF = NO;
    
    while (!done) {
		if (pos == bufferSize / sizeof(uint8_t)) {
			bufferSize += BUFFERSIZE;
			buffer = (uint8_t *)realloc(buffer, bufferSize);
		}
		size_t bytesRead = reader(self, @selector(readBytes:length:), buffer + pos, 1);
		if (bytesRead == 0) {
			hitEOF = YES;
			done = YES;
		} else if (bytesRead == AJR_READ_ERROR) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
			done = YES;
		} else if (buffer[pos] == byte) {
			[self ajr_seekToOffset:[self offsetInFile] - 1 error:&localError];
			done = YES;
		} else {
			pos += 1;
		}
    }

	if (localError == nil) {
		if (pos == 0 && hitEOF) {
			// We read no data, but had no error, so initialize the output parameters accordingly. Also free the buffer, since we're not going to return it.
			AJRSetOutParameter(outputBuffer, NULL);
			AJRSetOutParameter(outputLength, 0);
			NSZoneFree(NULL, buffer);
		} else {
			// No errors, so initialize the output parameters.
			AJRSetOutParameter(outputBuffer, buffer);
			AJRSetOutParameter(outputLength, pos);
		}
	} else {
		// We had an error, so we have to free our own buffer.
		NSZoneFree(NULL, buffer);
	}

	return AJRAssertOrPropagateError(localError == nil, error, localError);
}

- (NSData *)readToByte:(uint8_t)byte error:(out NSError **)error {
	NSError *localError;
	uint8_t *buffer;
	size_t length;
	NSData *data;
	if ([self readToByte:byte buffer:&buffer length:&length error:&localError]) {
		data = (length == 0 && buffer == NULL) ? nil : [[NSData alloc] initWithBytesNoCopy:buffer length:length freeWhenDone:YES];
	} else {
		AJRSetOutParameter(error, localError);
	}
	return data;
}

- (NSString *)readToCharacterFromSet:(NSCharacterSet *)characters error:(out NSError **)error {
	return [self readUsingUnicodeTestBlock:^AJRUnicodeAction(uint32_t input) {
		if ([characters characterIsMember:input]) {
			return AJRUnicodeActionStop;
		}
		return AJRUnicodeActionContinue;
	} error:error];
}

- (NSString *)readCharactersInSet:(NSCharacterSet *)characters error:(out NSError **)error {
	return [self readUsingUnicodeTestBlock:^AJRUnicodeAction(uint32_t input) {
		if ([characters characterIsMember:input]) {
			return AJRUnicodeActionContinue;
		}
		return AJRUnicodeActionStop;
	} error:error];
}

- (BOOL)readCString:(char *)buffer maximumLength:(NSUInteger)maxLength error:(out NSError **)error {
	NSError *localError;
	char character;
	BOOL done = NO;
	BOOL hitEOF = NO;
	NSUInteger position = 0;
	int fileDescriptor;
	
	@try {
		fileDescriptor = self.fileDescriptor;
	} @catch (NSException *exception) {
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain format:@"Attempt to access the file descriptor of a %C that is either closed or not backed by a file descriptor.", self];
	}
	
	while (localError == nil && !done && position < maxLength - 1) {
		size_t bytesRead;
		@try {
			// Not all subclasses use file descriptors, but if they do, this optimizes access to the file. If the don't, we have to do the slightly more expensive route.
			if (fileDescriptor >= 0) {
				bytesRead = read(fileDescriptor, &character, 1);
			} else {
				if (![self readBytes:&character length:1 bytesRead:&bytesRead error:NULL]) {
					bytesRead = AJR_READ_ERROR;
				}
			}
		} @catch (NSException *localException) {
			errno = EBADF;
			bytesRead = AJR_READ_ERROR;
		}
		if (bytesRead == 0) {
			hitEOF = YES;
			done = YES;
		} else if (bytesRead == AJR_READ_ERROR) {
			localError = [NSError errorWithDomain:NSPOSIXErrorDomain errorNumber:errno];
			done = YES;
		} else if (character == 0) {
			buffer[position++] = '\0';
			done = YES;
		} else {
			buffer[position++] = character;
		}
	}
	
	if (localError != nil) {
		AJRSetOutParameter(error, localError);
	} else if (hitEOF || position == maxLength - 1) {
		// We always leave room for the null terminator.
		buffer[position] = '\0';
	}

	return localError == nil;
}

- (BOOL)isAtEndOfFile:(out BOOL *)isAtEnd error:(out NSError **)error {
	NSError *localError = nil;
	BOOL success = NO;
    char temp;
	size_t readLength;
    
	success = [self readBytes:&temp length:sizeof(temp) bytesRead:&readLength error:&localError];
	if (success) {
		success = [self ajr_seekToOffset:[self offsetInFile] - readLength error:&localError];
		if (success) {
			AJRSetOutParameter(isAtEnd, readLength == 0);
		}
	}
    
	return AJRAssertOrPropagateError(success, error, localError);
}

#pragma mark - Changing File Length

- (BOOL)removeBytesInRange:(NSRange)range error:(out NSError **)error {
    unsigned char buffer[BUFFERSIZE];
    NSUInteger readLength;
    NSUInteger position = range.location;
    unsigned long long fileLength;
	NSError *localError = nil;
	BOOL success = NO;
    
	success = [self ajr_seekToEndReturningOffset:&fileLength error:&localError];
    
	if (success) {
		if (range.location > fileLength) {
			success = YES;
		} else if (range.location + range.length == fileLength) {
			success = [self ajr_truncateAtOffset:range.location error:error];
		} else {
			do {
				success = [self ajr_seekToOffset:position + range.length error:&localError];
				if (success) {
					readLength = [self readBytes:buffer length:BUFFERSIZE];
					if (readLength > 0) {
						[self seekToFileOffset:position];
						if (![self writeBytes:buffer length:BUFFERSIZE error:&localError]) {
							success = NO;
						}
					}
					position += readLength;
				}
			} while (success && readLength == BUFFERSIZE);
			
			if (success) {
				success = [self ajr_truncateAtOffset:fileLength - range.length error:error];
			}
		}
	}
	
	return AJRAssertOrPropagateError(success, error, localError);
}

- (BOOL)replaceDataInRange:(NSRange)range withData:(NSData *)data error:(out NSError **)error {
	NSError *localError;
    size_t dataLength = data.length;
	BOOL success = NO;
	unsigned long long fileLength;
	success = [self ajr_seekToEndReturningOffset:&fileLength error:&localError];
	
	if (success) {
		if (dataLength == 0) {
			// Super easy case, because we just call removeBytesInRange...
			success = [self removeBytesInRange:range error:&localError];
		} else if (range.location + range.length > fileLength) {
			// Out of range.
			success = NO;
			localError = [NSError errorWithDomain:NSCocoaErrorDomain format:@"Range %r out of file's range of [0..%llu]", range, fileLength];
		} else if (range.length == dataLength) {
			// The easy case, in that the new data is the same length as the old data.
			success = ([self ajr_seekToOffset:range.location error:&localError]
					   && [self writeBytes:[data bytes] length:dataLength error:error]);
		} else if (dataLength < range.length) {
			// The next easy case, where the new length is less than the old length.
			success = ([self ajr_seekToOffset:range.location error:&localError]
					   && [self writeBytes:[data bytes] length:dataLength error:error]
					   && [self removeBytesInRange:(NSRange){ range.location + dataLength, range.length - dataLength } error:error]);
		} else {
			unsigned char buffer[BUFFERSIZE];
			long long shift = dataLength - range.length;
			long long position = fileLength - BUFFERSIZE;
			size_t tempLength;
			size_t readLength = BUFFERSIZE;
			do {
				if (position < range.location + dataLength) {
					readLength = (position + BUFFERSIZE) - (range.location + range.length);
					position = range.location + range.length;
				}
				success = ([self ajr_seekToOffset:position error:&localError]
						   && [self readBytes:buffer length:readLength bytesRead:&tempLength error:&localError]);
				if (success && tempLength > 0) {
					success = ([self ajr_seekToOffset:position + shift error:&localError]
							   && [self writeBytes:buffer length:tempLength error:error]);
				}
				position -= BUFFERSIZE;
			} while (success && tempLength == BUFFERSIZE);
			
			if (success) {
				success = ([self ajr_seekToOffset:range.location error:&localError]
						   && [self ajr_writeData:data error:error]);
			}
		}
	}
	
	return AJRAssertOrPropagateError(success, error, localError);
}

@end
