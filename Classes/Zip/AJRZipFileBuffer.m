/*
AJRZipFileBuffer.m
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
//
//  AJRZipFileBuffer.m
//  iWork
//
//  Created by Alex Raftis on 7/14/10.
//  Copyright (c) 2010 Apple, Inc. All rights reserved.
//

#import "AJRZipFileBuffer.h"

#define FILE_BUFFER_QUANTUM 512

@implementation AJRZipFileBuffer 

- (NSData *)readDataAtOffset:(unsigned long long)offset length:(NSUInteger)length
{
    NSData *data = nil;
    @try {
        [fileHandle seekToFileOffset:offset];
        data = [fileHandle readDataOfLength:length];
    } @catch (NSException *exception) {
        data = nil;
    }
    return data;
}

- (BOOL)getBytes:(void *)buffer length:(NSUInteger)length atOffset:(unsigned long long)offset 
{
    BOOL                retval = YES;
    NSUInteger          currentLength = [currentData length];
    unsigned long long  end = offset + length, currentEnd = currentOffset + currentLength, targetOffset;
    size_t              bytesMoved = (size_t)-1;
    while (retval && length > 0 && offset < fileLength) {
        if (offset >= currentOffset && offset < currentEnd && end > currentOffset) {
            bytesMoved = (end > currentEnd) ? currentEnd - offset : length;
            memmove(buffer, [currentData bytes] + offset - currentOffset, bytesMoved);
            buffer += bytesMoved;
            length -= bytesMoved;
            offset += bytesMoved;
        } else if (offset < currentOffset && end > currentOffset && end <= currentEnd) {
            bytesMoved = end - currentOffset;
            memmove(buffer + currentOffset - offset, [currentData bytes], bytesMoved);
            length -= bytesMoved;
            end -= bytesMoved;
        } else {
            if (bytesMoved == 0) retval = NO;
            bytesMoved = 0;
            targetOffset = FILE_BUFFER_QUANTUM * (offset / FILE_BUFFER_QUANTUM);
            currentData = [self readDataAtOffset:targetOffset length:2 * FILE_BUFFER_QUANTUM];
            currentOffset = targetOffset;
            currentLength = [currentData length];
            currentEnd = currentOffset + currentLength;
        }
    }
    return retval;
}

- (id)initWithURL:(NSURL *)url error:(NSError **)error 
{
    self = [super init];
    if (self) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:[url path]];
        if (fileHandle) {
            @try {
                fileLength = [fileHandle seekToEndOfFile];
            } @catch (NSException *exception) {
                [fileHandle closeFile];
                fileHandle = nil;
                fileLength = 0;
            }
            if (fileLength > 0) {
                uint8_t val;
                if (![self getBytes:&val length:1 atOffset:fileLength - 1]) {
                    [fileHandle closeFile];
                    fileHandle = nil;
                }
            }
        }
    }
    if (!fileHandle && error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:url, NSURLErrorKey, nil]];
    return fileHandle ? self : nil;
}

- (void)close
{
    [fileHandle closeFile];
    fileHandle = nil;
}

- (void)finalize
{
    [self close];
    [super finalize];
}

- (unsigned long long)fileLength
{
    return fileLength;
}

- (uint8_t)byteAtOffset:(unsigned long long)offset
{
    uint8_t val = 0;
    (void)[self getBytes:&val length:sizeof(val) atOffset:offset];
    return val;
}

- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset
{
    uint16_t val = 0;
    (void)[self getBytes:&val length:sizeof(val) atOffset:offset];
    return NSSwapLittleShortToHost(val);
}

- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset
{
    uint32_t val = 0;
    (void)[self getBytes:&val length:sizeof(val) atOffset:offset];
    return NSSwapLittleIntToHost(val);
}

- (NSData *)dataAtOffset:(unsigned long long)offset length:(NSUInteger)length
{
    NSData *data = nil;
    if (length <= FILE_BUFFER_QUANTUM) {
        uint8_t buffer[FILE_BUFFER_QUANTUM] = {0};
        (void)[self getBytes:buffer length:length atOffset:offset];
        data = [NSData dataWithBytes:buffer length:length];
    } else {
        data = [self readDataAtOffset:offset length:length];
    }
    return data;
}

@end
