/*
 AJRZipFileBuffer.h
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
