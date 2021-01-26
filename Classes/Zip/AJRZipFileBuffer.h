//
//  AJRZipFileBuffer.h
//  iWork
//
//  Created by Alex Raftis on 7/14/10.
//  Copyright (c) 2010 Apple, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRZipFileBuffer : NSObject 
{
    NSFileHandle        *fileHandle;
    unsigned long long  fileLength;
    unsigned long long  currentOffset;
    NSData              *currentData;
}

- (id)initWithURL:(NSURL *)url error:(NSError **)error;
- (void)close;
- (unsigned long long)fileLength;
- (uint8_t)byteAtOffset:(unsigned long long)offset;
- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset;
- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset;
- (NSData *)dataAtOffset:(unsigned long long)offset length:(NSUInteger)length;

@end
