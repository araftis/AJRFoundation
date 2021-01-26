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
