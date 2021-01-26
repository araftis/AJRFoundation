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
