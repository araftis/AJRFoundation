/*
AJRMemoryHandle.m
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

#import "AJRMemoryHandle.h"

#import "AJRFunctions.h"
#import "NSError+Extensions.h"
#import "NSFileHandle+Extensions.h"

@interface AJRMemoryHandle ()

@property (nonatomic,strong) NSData *data;
@property (nonatomic,assign) NSUInteger position;

@end

@implementation AJRMemoryHandle {
	// Technically, we don't "close" per se, but track that the user closed us, so that we respond in an expected fashion to various API calls.
	BOOL _closed;
	NSRecursiveLock *_accessLock;
}

#pragma mark - Creation

+ (instancetype)memoryHandleForReadingData:(NSData *)data {
	return [[self alloc] initWithData:data];
}

+ (instancetype)memoryHandleForReadingDataNoCopy:(NSData *)data {
	return [[self alloc] initWithDataNoCopy:data];
}

+ (instancetype)memoryHandleForUpdatingData:(NSMutableData *)data error:(out NSError * _Nullable * _Nullable)error {
	return [[self alloc] initWithMutableData:data seekToEnd:YES error:error];
}

+ (instancetype)memoryHandleForWriting {
	// The only failure, at least at the moment, is that data isn't mutable, and since we're definitely passing in mutable data, we can ignore any errors.
	return [[self alloc] initWithMutableData:[NSMutableData data] error:NULL];
}

+ (instancetype)memoryHandleWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)options error:(NSError * _Nullable * _Nullable)error {
	return [[self alloc] initWithContentsOfFile:path options:options error:error];
}

+ (instancetype)memoryHandleWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)options error:(NSError * _Nullable * _Nullable)error {
	return [[self alloc] initWithContentsOfURL:url options:options error:error];
}

- (void)_commonInternalInit {
	_accessLock = [[NSRecursiveLock alloc] init];
}

- (instancetype)init {
    return [self initWithMutableData:[NSMutableData data] error:NULL];
}

- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        _data = [data copy];
		[self _commonInternalInit];
    }
    return self;
}

- (instancetype)initWithDataNoCopy:(NSData *)data {
    if ((self = [super init])) {
        _data = data;
		[self _commonInternalInit];
    }
    return self;
}

- (instancetype)initWithMutableData:(NSMutableData *)data error:(out NSError * _Nullable * _Nullable)error {
	return [self initWithMutableData:data seekToEnd:NO error:error];
}

- (instancetype)initWithMutableData:(NSMutableData *)data seekToEnd:(BOOL)seekToEnd error:(out NSError * _Nullable * _Nullable)error {
	NSError *localError = nil;
	
	if (![data isKindOfClass:[NSMutableData class]]) {
		self = nil;
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain format:@"data passed into %S must be mutable.", _cmd];
	} else {
		if ((self = [super init])) {
			_data = data;
			if (seekToEnd) {
				_position = _data.length;
			}
			[self _commonInternalInit];
		}
	}
	
    return AJRAssertOrPropagateError(self, error, localError);
}

- (instancetype)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)options error:(NSError **)error {
	NSData *data = [[NSData alloc] initWithContentsOfFile:path options:options error:error];
	if (data != nil) {
		self = [self initWithData:data];
	} else {
		self = nil;
	}
    return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)options error:(NSError **)error {
	NSData *data = [[NSData alloc] initWithContentsOfURL:url options:options error:error];
	if (data != nil) {
		self = [self initWithData:data];
	} else {
		self = nil;
	}
    return self;
}

#pragma mark - Utilities

- (void)convertToWritable {
	[self _lockedAccess:^{
		if (![self canWrite]) {
			self->_data = [self->_data mutableCopy];
		}
	}];
}

- (void)accessData:(void (^)(NSData *data, NSUInteger *position))block {
	[self _lockedAccess:^{
		NSUInteger localPosition = self->_position;
		block(self->_data, &localPosition);
		self->_position = localPosition;
	}];
}

- (BOOL)accessMutableData:(void (^)(NSMutableData *data, NSUInteger *position))block {
	__block BOOL wasWritable = NO;
	[self _lockedAccess:^{
		if (self.canWrite) {
			NSUInteger localPosition = self->_position;
			wasWritable = YES;
			// _data is mutable if we're writable.
			block((NSMutableData *)self->_data, &localPosition);
			self->_position = localPosition;
		}
	}];
	return wasWritable;
}

#pragma mark - Properties

- (NSMutableData *)mutableData {
	__block NSMutableData *data = nil;
	
	[self _lockedAccess:^{
		if (self.canWrite) {
			data = (NSMutableData *)self->_data;
		}
	}];
	
	return data;
}

- (BOOL)canWrite {
    return [_data isKindOfClass:[NSMutableData class]];
}

#pragma mark - Thread Safety

- (void)_lockedAccess:(void (^)(void))block {
	[_accessLock lock];
	@try {
		block();
	} @finally {
		[_accessLock unlock];
	}
}

#pragma mark - Reading

// I'd eventually like to use this to help with making this code multithreaded safe.
- (void)readIfPossible:(void (^)(NSData *data, NSUInteger * _Nonnull position))readBlock {
	[self accessData:^(NSData * _Nonnull data, NSUInteger * _Nullable position) {
		if (self->_closed) {
			[NSException raise:NSInternalInconsistencyException format:@"Tried to read from a closed memory handle."];
		}
		if (data == nil) {
			[NSException raise:NSInternalInconsistencyException format:@"Tried to read from a memory handle with no data."];
		}
		readBlock(data, position);
	}];
}

- (BOOL)readBytes:(void *)buffer length:(size_t)length bytesRead:(out size_t *)bytesRead error:(out NSError **)error {
    __block NSInteger readLength = 0;
	NSError *localError = nil;

	@try {
		[self readIfPossible:^(NSData *data, NSUInteger *position) {
			if (*position + length < [data length]) {
				readLength = length;
			} else {
				readLength = [data length] - *position;
			}
			
			if (readLength > 0) {
				[data getBytes:buffer range:(NSRange){*position, readLength}];
				*position += readLength;
			}
		}];
	} @catch (NSException *exception) {
		readLength = 0;
		errno = EBADF;
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain format:@"Failed to read from memory handle: %@", [exception description]];
	}
	
	AJRSetOutParameter(bytesRead, readLength);
        
	return AJRAssertOrPropagateError(localError == nil, error, localError);
}

- (size_t)readBytes:(void *)buffer length:(unsigned long)length {
	size_t bytesRead = 0;
	
	if (![self readBytes:buffer length:length bytesRead:&bytesRead error:NULL]) {
		bytesRead = AJR_READ_ERROR;
		errno = EBADF;
	}

	return bytesRead;
}

- (NSData *)availableData {
    return [self readDataToEndOfFile];
}

- (NSData *)readDataToEndOfFile {
	return [self readDataToEndOfFileWithError:NULL];
}

- (NSData *)readDataToEndOfFileWithError:(NSError * _Nullable __autoreleasing *)error {
	return [self readDataOfLength:NSUIntegerMax error:error];
}

- (NSData *)readDataOfLength:(NSUInteger)length {
	return [self readDataOfLength:length error:NULL];
}

- (NSData *)readDataOfLength:(NSUInteger)length error:(NSError **)error {
	__block NSData *subdata = nil;
	NSError *localError = nil;

	@try {
		[self readIfPossible:^(NSData *data, NSUInteger * _Nonnull position) {
			NSInteger readLength;
			
			if (*position + length < data.length) {
				readLength = length;
			} else {
				readLength = data.length - *position;
			}
			
			if (readLength >= 0) {
				subdata = [data subdataWithRange:(NSRange){*position, readLength}];
				*position += readLength;
			}
		}];
	} @catch (NSError *exception) {
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain format:@"Unable to read from memory handle: %@", exception];
		errno = EBADF;
		subdata = nil;
	}
	
	return AJRAssertOrPropagateError(subdata, error, localError);
}

- (void)readInBackgroundAndNotify {
	[self readToEndOfFileInBackgroundAndNotify];
}

- (void)readInBackgroundAndNotifyForModes:(NSArray *)modes {
	[self readToEndOfFileInBackgroundAndNotifyForModes:modes];
}

- (void)readToEndOfFileInBackgroundAndNotify {
	[self readToEndOfFileInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode]];
}

- (void)readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes {
	// Just post immediately, since all data will be in memory.
	[NSNotificationCenter.defaultCenter postNotificationName:NSFileHandleReadCompletionNotification object:self];
}

#pragma mark - Primitive Writing

/*! Called by internal methods to write to our data. This method throws an exception if the data is not writable. */
- (void)writeIfPossible:(void (^)(NSMutableData *data))writeBlock {
	[self _lockedAccess:^{
		if (![self canWrite]) {
			[NSException raise:NSInternalInconsistencyException format:@"Cannot write to locked memory."];
		}
		if (self->_closed) {
			[NSException raise:NSInternalInconsistencyException format:@"Tried to write to a closed memory handle."];
		}
		// If we get here, we have a mutable data, so we can write to it.
		writeBlock((NSMutableData *)self->_data);
	}];
}

- (BOOL)writeBytes:(const void *)bytes length:(size_t)length bytesWritten:(nullable out size_t *)written error:(out NSError **)error {
	NSError *localError = nil;
	size_t bytesWritten = 0;
	
	@try {
		[self writeIfPossible:^(NSMutableData *data) {
			[data replaceBytesInRange:(NSRange){self->_position, length} withBytes:bytes];
			self->_position += length;
		}];
		bytesWritten = length;
	} @catch (NSException *localException) {
		errno = EBADF;
		bytesWritten = AJR_WRITE_ERROR;
	}
	if (bytesWritten == AJR_WRITE_ERROR) {
		localError = [NSError errorWithDomain:NSPOSIXErrorDomain code:-1 message:@"Cannot write to immutable data."];
	} else {
		AJRSetOutParameter(written, bytesWritten);
	}
	return AJRAssertOrPropagateError(bytesWritten != AJR_WRITE_ERROR, error, localError);
}

#pragma mark - Writing

- (NSInteger)writeBytes:(const void *)buffer length:(unsigned long)length {
	NSUInteger bytesWritten;
	
	[self writeBytes:buffer length:length bytesWritten:&bytesWritten error:NULL];
	
	return bytesWritten;
}

- (void)writeData:(NSData *)someData {
    [self writeBytes:someData.bytes length:someData.length bytesWritten:NULL error:NULL];
}

- (void)truncateFileAtOffset:(unsigned long long)offset {
    [self writeIfPossible:^(NSMutableData *data) {
        [data setLength:(NSUInteger)offset];
        if (self->_position > offset) {
            self->_position = offset;
        }
    }];
}

- (void)synchronizeFile {
    /* Does nothing */
}

#pragma mark - Offset & Seeking

- (unsigned long long)offsetInFile {
	__block NSUInteger position;
	[self _lockedAccess:^{
		position = self->_position;
	}];
    return position;
}

- (unsigned long long)seekToEndOfFile {
	__block NSUInteger position;
	
	[self _lockedAccess:^{
		self->_position = self->_data.length;
		position = self->_position;
	}];
    
    return position;
}

- (void)seekToFileOffset:(unsigned long long)offset {
	[self _lockedAccess:^{
		self->_position = (NSUInteger)((offset > [self->_data length]) ? [self->_data length] : offset);
	}];
}

#pragma mark - Closing

- (void)closeFile {
	[self _lockedAccess:^{
		self->_closed = YES;
	}];
}

#pragma mark - Sockets

- (void)acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes {
    /* Does nothing */
}

- (void)acceptConnectionInBackgroundAndNotify {
    /* Does nothing */
}

- (void)waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes {
	if ([_data isKindOfClass:[NSMutableData class]]) {
		// We can actually sit around and wait for data to be appeneded to the data.
	} else {
		// The data is immutable, so just notify.
		[NSNotificationCenter.defaultCenter postNotificationName:NSFileHandleDataAvailableNotification object:self];
	}
}

- (void)waitForDataInBackgroundAndNotify {
	[self waitForDataInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode]];
}

#pragma mark - UNIX Files

- (NSInteger)fileDescriptor {
    // We don't have an underlying file.
    return -1;
}

@end
