//
//  AJRFileOutputStream.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/4/18.
//

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
