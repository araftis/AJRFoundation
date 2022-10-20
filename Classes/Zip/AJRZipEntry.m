/*
AJRZipEntry.m
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
//  AJRZipEntry.m
//  iWork
//
//  Created by Alex Raftis on 7/14/10.
//  Copyright (c) 2010 Apple, Inc. All rights reserved.
//

#import "AJRZipEntry.h"

@implementation AJRZipEntry

+ (AJRZipEntry *)rootEntry
{
    return [[self alloc] initWithPath:@"/" headerOffset:0 CRC:0 compressedSize:0 uncompressedSize:0 compressionType:0];
}

- (id)initWithPath:(NSString *)path headerOffset:(uint32_t)headeridx CRC:(uint32_t)crcval compressedSize:(uint32_t)csize uncompressedSize:(uint32_t)usize compressionType:(uint16_t)compression
{
    self = [super init];
    if (self) {
        isLeaf = ([path hasSuffix:@"/"] && compressedSize == 0) ? NO : YES;
        path = [@"/" stringByAppendingPathComponent:path];
        name = [[path lastPathComponent] copy];
        leadingPath = [[path stringByDeletingLastPathComponent] copy];
        if (!isLeaf) childEntries = [[NSMutableArray alloc] init];
        headerOffset = headeridx;
        CRC = crcval;
        compressedSize = csize;
        uncompressedSize = usize;
        compressionType = compression;
    }
    return self;
}

- (NSString *)path
{
    NSString *path = [leadingPath stringByAppendingPathComponent:name];
    return isLeaf ? path : [path stringByAppendingString:@"/"];
}

- (NSArray *)childEntries
{
    return childEntries;
}

@synthesize name;
@synthesize headerOffset;
@synthesize CRC;
@synthesize compressedSize;
@synthesize uncompressedSize;
@synthesize compressionType;
@synthesize isLeaf;

- (NSComparisonResult)compare:(AJRZipEntry *)other
{
    return [[self name] localizedCaseInsensitiveCompare:[other name]];
}

- (BOOL)addChildEntry:(AJRZipEntry *)entry
{
    if (!childEntries) return NO;
    [childEntries addObject:entry];
    [childEntries sortUsingSelector:@selector(compare:)];
    return YES;
}

- (AJRZipEntry *)childDirectoryEntryWithName:(NSString *)str createIfNotPresent:(BOOL)flag
{
    AJRZipEntry *childEntry = nil;
    for (AJRZipEntry *entry in childEntries) {
        if ([[entry name] isEqualToString:str] && ![entry isLeaf]) {
            childEntry = (AJRZipEntry *)entry;
            break;
        }
    }
    if (!childEntry && flag && !isLeaf) {
        childEntry = [[AJRZipEntry alloc] initWithPath:[[[self path] stringByAppendingPathComponent:str] stringByAppendingString:@"/"] headerOffset:0 CRC:0 compressedSize:0 uncompressedSize:0 compressionType:0];
        [self addChildEntry:childEntry];
    }
    return childEntry;
}

- (BOOL)addToRootEntry:(AJRZipEntry *)rootEntry
{
    AJRZipEntry *directoryEntry = rootEntry;
    NSArray *components = [leadingPath pathComponents];
    for (NSString *component in components) {
        if (![@"/" isEqualToString:component]) directoryEntry = [directoryEntry childDirectoryEntryWithName:component createIfNotPresent:YES];
    }
    return directoryEntry ? [directoryEntry addChildEntry:self] : NO;
}

@end
