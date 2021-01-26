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
