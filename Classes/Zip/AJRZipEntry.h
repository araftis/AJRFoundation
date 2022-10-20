/*
AJRZipEntry.h
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
//  AJRZipEntry.h
//  iWork
//
//  Created by Alex Raftis on 7/14/10.
//  Copyright (c) 2010 Apple, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AJRZipEntry : NSObject
{
    NSString        *name;
    NSString        *leadingPath;
    NSMutableArray  *childEntries;
    uint32_t        headerOffset;
    uint32_t        CRC;
    uint32_t        compressedSize;
    uint32_t        uncompressedSize;
    uint16_t        compressionType;
    BOOL            isLeaf;
}

+ (AJRZipEntry *)rootEntry;
- (id)initWithPath:(NSString *)path headerOffset:(uint32_t)headeridx CRC:(uint32_t)crcval compressedSize:(uint32_t)csize uncompressedSize:(uint32_t)usize compressionType:(uint16_t)compression;
- (BOOL)addChildEntry:(AJRZipEntry *)entry;
- (AJRZipEntry *)childDirectoryEntryWithName:(NSString *)str createIfNotPresent:(BOOL)flag;
- (BOOL)addToRootEntry:(AJRZipEntry *)rootEntry;

@property (readonly) NSString *name;
@property (readonly) NSString *path;
@property (readonly) NSArray *childEntries;
@property (readonly) uint32_t headerOffset;
@property (readonly) uint32_t CRC;
@property (readonly) uint32_t compressedSize;
@property (readonly) uint32_t uncompressedSize;
@property (readonly) uint16_t compressionType;
@property (readonly) BOOL isLeaf;

@end
