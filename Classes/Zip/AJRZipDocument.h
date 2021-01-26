//
//  AJRZipDocument.h
//  iWork
//
//  Created by Alex Raftis on 7/14/10.
//  Copyright (c) 2010 Apple, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AJRZipEntry, AJRZipEntryView, AJRZipFileBuffer;

extern NSString * const AJRZipErrorDomain;

@interface AJRZipDocument : NSObject
{
    AJRZipEntry            *_rootEntry;
    AJRZipFileBuffer        *fileBuffer;
    NSURL                *documentURL;
    uint32_t            directoryEntriesStart;
    uint16_t            numberOfDirectoryEntries;
    NSOperationQueue    *_operationQueue;
    
    NSMutableDictionary    *_entriesByPath;
}

- (id)initWithURL:(NSURL *)url error:(NSError **)error;

@property (readonly) AJRZipEntry *rootEntry;

- (AJRZipEntry *)entryForPath:(NSString *)path;
- (NSData *)dataForEntry:(AJRZipEntry *)entry error:(NSError **)error;

@end
