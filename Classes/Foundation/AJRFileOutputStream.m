/*
AJRFileOutputStream.m
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

#import "AJRFileOutputStream.h"

#import "NSError+Extensions.h"

NSString * const AJRStreamErrorDomain = @"AJRStreamErrorDomain";

@implementation AJRFileOutputStream {
    int _fileDescriptor;
    FILE *_file;
    NSError *_error;
}

+ (instancetype)outputStreamWithFileDescriptor:(int)fileDescriptor {
    return [self outputStreamWithFileDescriptor:fileDescriptor closeOnDeallocate:NO];
}

+ (instancetype)outputStreamWithFileDescriptor:(int)fileDescriptor closeOnDeallocate:(BOOL)closeOnDeallocate {
    return [[self alloc] initWithFileDescriptor:fileDescriptor closeOnDeallocate:closeOnDeallocate];
}

- (instancetype)initWithFileDescriptor:(int)fileDescriptor closeOnDeallocate:(BOOL)closeOnDeallocate {
    if ((self = [super init])) {
        _fileDescriptor = fileDescriptor;
        _closeOnDeallocate = closeOnDeallocate;
    }
    return self;
}

+ (instancetype)outputStreamWithFile:(FILE *)file {
    return [self outputStreamWithFile:file closeOnDeallocate:NO];
}

+ (instancetype)outputStreamWithFile:(FILE *)file closeOnDeallocate:(BOOL)closeOnDeallocate {
    return [[self alloc] initWithFile:file closeOnDeallocate:closeOnDeallocate];
}

- (instancetype)initWithFile:(FILE *)file closeOnDeallocate:(BOOL)closeOnDeallocate {
    if ((self = [self initWithFileDescriptor:fileno(file) closeOnDeallocate:closeOnDeallocate])) {
        _file = file;
    }
    return self;
}

- (void)dealloc {
    if (_closeOnDeallocate) {
        [self close];
    }
}

- (BOOL)hasSpaceAvailable {
    return YES;
}

- (void)close {
    if (_file) {
        fclose(_file);
        _file = NULL;
        _fileDescriptor = -1;
    }
    if (_fileDescriptor >= 0) {
        close(_fileDescriptor);
        _fileDescriptor = -1;
    }
}

- (void)open {
    // We're ajrsumed to be open until we're closed.
    if (_fileDescriptor < 0 && _error == nil) {
        _error = [NSError errorWithDomain:AJRStreamErrorDomain message:@"File Descriptor has been closed and cannot be re-opened."];
    }
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)length {
    ssize_t bytesWritten = -1;
    
    if (_error == nil) {
        if (_fileDescriptor >= 0) {
            bytesWritten = write(_fileDescriptor, buffer, length);
            if (bytesWritten < 0) {
                _error = [NSError errorWithDomain:AJRStreamErrorDomain errorNumber:errno];
            }
        } else {
            _error = [NSError errorWithDomain:AJRStreamErrorDomain message:@"Attempted to write to a closed file."];
        }
    }
    
    return bytesWritten;
}

- (NSStreamStatus)streamStatus {
    if (_error) {
        return NSStreamStatusError;
    }
    return _fileDescriptor >= 0 ? NSStreamStatusOpen : NSStreamStatusClosed;
}

- (NSError *)streamError {
    return _error;
}

@end
