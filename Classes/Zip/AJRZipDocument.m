/*
AJRZipDocument.m
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
//  AJRZipDocument.m
//  iWork
//
//  Created by Alex Raftis on 7/14/10.
//  Copyright (c) 2010 Apple, Inc. All rights reserved.
//

#import "AJRZipDocument.h"

#import "AJRZipEntry.h"
#import "AJRZipFileBuffer.h"

#import <zlib.h>

#define MIN_DIRECTORY_END_OFFSET    20
#define MAX_DIRECTORY_END_OFFSET    66000
#define FILE_HEADER_LENGTH          30
#define DIRECTORY_ENTRY_LENGTH      46
#define ENTRY_READ_QUEUE_LENGTH     256
#define CHUNK                        16384

#define DIRECTORY_END_TAG           0x06054b50
#define DIRECTORY_ENTRY_TAG         0x02014b50
#define FILE_ENTRY_TAG              0x04034b50

NSString * const AJRZipErrorDomain = @"AJRZipErrorDomain";

@interface AJRZipDocument ()

- (BOOL)readFromURL:(NSURL *)absoluteURL error:(NSError **)error;
- (void)readEntries;

@end


@implementation AJRZipDocument

/* Initialization and setup methods */

- (id)initWithURL:(NSURL *)url error:(NSError **)error
{
    self = [super init];
    if (self) {
        _rootEntry = [AJRZipEntry rootEntry];
        _entriesByPath = [[NSMutableDictionary alloc] init];
        [_entriesByPath setObject:_rootEntry forKey:@"/"];
        
        if (![self readFromURL:url error:error]) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [fileBuffer close];
    fileBuffer = nil;

    [super dealloc];
}

@synthesize rootEntry = _rootEntry;

- (NSString *)windowNibName
{
    return @"AJRZipDocument";
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
    return (flag ? NSDragOperationNone : (NSDragOperationCopy|NSDragOperationGeneric));
}

/* Document reading methods */

- (void)_addEntries:(NSArray *)array
{
    for (AJRZipEntry *entry in array) {
        [entry addToRootEntry:_rootEntry];
        [_entriesByPath setObject:entry forKey:[entry path]];
        //PagesPrintf(@"added path: %@\n", [entry path]);
    }
}

- (void)readEntries 
{
    // This method is called in the background to read the entries from a zip archive's directory
    NSString            *path = nil;
    AJRZipEntry            *entry;
    NSMutableArray      *entryArray = [[NSMutableArray alloc] init];
    unsigned long long  length = [fileBuffer fileLength];
    uint32_t            i, directoryIndex;
    
    for (i = 0, directoryIndex = directoryEntriesStart; i < numberOfDirectoryEntries; i++) {
        uint16_t compression, namelen, extralen, commentlen;
        uint32_t crcval, csize, usize, headeridx;
        
        if (directoryIndex < directoryEntriesStart || directoryIndex >= length || directoryIndex + DIRECTORY_ENTRY_LENGTH <= directoryEntriesStart || directoryIndex + DIRECTORY_ENTRY_LENGTH > length || [fileBuffer littleUnsignedIntAtOffset:directoryIndex] != DIRECTORY_ENTRY_TAG) break;
        
        compression = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 10];
        crcval = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 16];
        csize = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 20];
        usize = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 24];
        namelen = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 28];
        extralen = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 30];
        commentlen = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 32];
        headeridx = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 42];
        
        if (directoryIndex + DIRECTORY_ENTRY_LENGTH + namelen <= directoryEntriesStart || directoryIndex + DIRECTORY_ENTRY_LENGTH + namelen > length) break;
        
        if (namelen > 0 && headeridx < directoryEntriesStart) {
            // We try to interpret the name using the document's encoding, but if this fails we fall back to the filesystem encoding, Windows Latin 1, and finally Mac Roman (which always succeeds)
            NSData *nameData = [fileBuffer dataAtOffset:directoryIndex + DIRECTORY_ENTRY_LENGTH length:namelen];
            if (nameData && [nameData length] == namelen) {
                path = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
                if (!path) path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:[nameData bytes] length:[nameData length]];
                if (!path) path = [[NSString alloc] initWithData:nameData encoding:NSWindowsCP1252StringEncoding];
                if (!path) path = [[NSString alloc] initWithData:nameData encoding:NSMacOSRomanStringEncoding];
            }
        }
        
        if (path) {
            entry = [[AJRZipEntry alloc] initWithPath:path headerOffset:headeridx CRC:crcval compressedSize:csize uncompressedSize:usize compressionType:compression];
            //PagesPrintf(@"%@: %@", path, entry);
            
            // We place the entries on a queue, and when we have enough we send them over to the main thread to be added to the document's entry tree and displayed
            [entryArray addObject:entry];
            if ([entryArray count] >= ENTRY_READ_QUEUE_LENGTH) {
                [self _addEntries:entryArray];
                [entryArray removeAllObjects];
            }
            [entry release];
        }
        directoryIndex += DIRECTORY_ENTRY_LENGTH + namelen + extralen + commentlen;
    }
    if ([entryArray count] > 0) {
        [self _addEntries:entryArray];
    }
    
    [entryArray release];
}

static inline uint32_t _crcFromData(NSData *data)
{
    uint32_t crc = crc32(0, NULL, 0);
    return crc32(crc, [data bytes], [data length]);
}
/*
- (BOOL)writeEntry:(AJRZipEntry *)zipEntry toFileURL:(NSURL *)fileURL error:(NSError **)error
{
    // This method is called in the background to uncompress an individual zip entry and write it to disk as a result of a drag
    BOOL retval = NO;
    unsigned long long length = [fileBuffer fileLength];
    uint16_t compression = [zipEntry compressionType], namelen, extralen;
    uint32_t crcval = [zipEntry CRC], csize = [zipEntry compressedSize], usize = [zipEntry uncompressedSize], headeridx = [zipEntry headerOffset], dataidx;
    NSData *compressedData = nil, *uncompressedData = nil;
    NSMutableData *mutableData = nil;
    NSError *localError = nil;
    z_stream stream;
    
    if (headeridx < length && headeridx + FILE_HEADER_LENGTH > headeridx && headeridx + FILE_HEADER_LENGTH < length && csize > 0 && usize > 0 && [fileBuffer littleUnsignedIntAtOffset:headeridx] == FILE_ENTRY_TAG && [fileBuffer littleUnsignedShortAtOffset:headeridx + 8] == compression) {
        namelen = [fileBuffer littleUnsignedShortAtOffset:headeridx + 26];
        extralen = [fileBuffer littleUnsignedShortAtOffset:headeridx + 28];
        dataidx = headeridx + FILE_HEADER_LENGTH + namelen + extralen;
        
        if (dataidx < length && dataidx + csize > dataidx && dataidx + csize > headeridx && dataidx + csize < length) {
            // Currently this is all done in memory, but it could potentially be done block-by-block as a stream
            compressedData = [fileBuffer dataAtOffset:dataidx length:csize];
            if (0 == compression && compressedData && [compressedData length] == csize && usize == csize && _crcFromData(compressedData) == crcval) {
                // If the entry is stored uncompressed, we write it out verbatim
                uncompressedData = compressedData;
            } else if (8 == compression && compressedData && [compressedData length] == csize && usize / 64 < csize) {
                // If the entry is stored deflated, we inflate it and write out the results
                mutableData = [NSMutableData dataWithLength:usize];
                bzero(&stream, sizeof(stream));
                stream.next_in = (Bytef *)[compressedData bytes];
                stream.avail_in = [compressedData length];
                stream.next_out = (Bytef *)[mutableData mutableBytes];
                stream.avail_out = usize;
                
                if (mutableData && Z_OK == inflateInit2(&stream, -15)) {
                    if (Z_STREAM_END == inflate(&stream, Z_FINISH)) {
                        if (Z_OK == inflateEnd(&stream) && usize == stream.total_out && _crcFromData(mutableData) == crcval) uncompressedData = mutableData;
                    } else {
                        (void)inflateEnd(&stream);
                    }
                }
            }
            if (uncompressedData && [uncompressedData writeToURL:fileURL options:NSAtomicWrite error:&localError]) retval = YES;
        }
    }
    if (retval != nil) {
        if (error) {
            *error = localError ? localError : [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileURL, NSURLErrorKey, nil]];
        }
        return nil;
    }
    return retval;
}
*/
+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
    return YES;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL error:(NSError **)error 
{
    // This is the main method for reading a document from disk
    BOOL retval = NO;
    unsigned long long i, length, directoryEntriesEnd = 0;
    uint32_t potentialTag;
    NSError *localError = nil;
    
    if (!fileBuffer) fileBuffer = [[AJRZipFileBuffer alloc] initWithURL:absoluteURL error:&localError];
    if (fileBuffer) {
        documentURL = [absoluteURL copy];
        length = [fileBuffer fileLength];
        
        // First, we locate the zip directory
        for (i = MIN_DIRECTORY_END_OFFSET; directoryEntriesEnd == 0 && i < MAX_DIRECTORY_END_OFFSET && i < length; i++) {
            potentialTag = [fileBuffer littleUnsignedIntAtOffset:length - i];
            if (potentialTag == DIRECTORY_END_TAG) {
                directoryEntriesEnd = length - i;
                numberOfDirectoryEntries = [fileBuffer littleUnsignedShortAtOffset:directoryEntriesEnd + 8];
                directoryEntriesStart = [fileBuffer littleUnsignedIntAtOffset:directoryEntriesEnd + 16];
            }
        }
        
        // If we have a valid zip directory, report success and queue reading of the actual entries in the background
        if (numberOfDirectoryEntries > 0 && directoryEntriesEnd > 0 && directoryEntriesStart > 0 && directoryEntriesStart < length) {
            [self readEntries];
            retval = YES;
        } else {
            [fileBuffer close];
            fileBuffer = nil;
        }
    }
    if (!retval && error) *error = localError ? localError : [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:absoluteURL, NSURLErrorKey, nil]];
    return retval;
}

- (AJRZipEntry *)entryForPath:(NSString *)path
{
    return [_entriesByPath objectForKey:path];
}

- (NSData *)dataForEntry:(AJRZipEntry *)zipEntry error:(NSError **)error
{
    // This method is called in the background to uncompress an individual zip entry and write it to disk as a result of a drag
    unsigned long long    length = [fileBuffer fileLength];
    uint16_t            compression = [zipEntry compressionType], 
                        namelen, 
                        extralen;
    uint32_t            crcval = [zipEntry CRC], 
                        csize = [zipEntry compressedSize], 
                        usize = [zipEntry uncompressedSize], 
                        headeridx = [zipEntry headerOffset], 
                        dataidx;
    NSData                *compressedData = nil, *uncompressedData = nil;
    NSMutableData        *mutableData = nil;
    NSError                *localError = nil;
    z_stream            stream;
    
    if (headeridx < length && headeridx + FILE_HEADER_LENGTH > headeridx && headeridx + FILE_HEADER_LENGTH < length && csize > 0 && usize > 0 && [fileBuffer littleUnsignedIntAtOffset:headeridx] == FILE_ENTRY_TAG && [fileBuffer littleUnsignedShortAtOffset:headeridx + 8] == compression) {
        namelen = [fileBuffer littleUnsignedShortAtOffset:headeridx + 26];
        extralen = [fileBuffer littleUnsignedShortAtOffset:headeridx + 28];
        dataidx = headeridx + FILE_HEADER_LENGTH + namelen + extralen;
        
        if (dataidx < length && dataidx + csize > dataidx && dataidx + csize > headeridx && dataidx + csize < length) {
            // Currently this is all done in memory, but it could potentially be done block-by-block as a stream
            compressedData = [fileBuffer dataAtOffset:dataidx length:csize];
            if (0 == compression && compressedData && [compressedData length] == csize && usize == csize && _crcFromData(compressedData) == crcval) {
                // If the entry is stored uncompressed, we write it out verbatim
                uncompressedData = compressedData;
            } else if (8 == compression && compressedData && [compressedData length] == csize && usize / 64 < csize) {
                // If the entry is stored deflated, we inflate it and write out the results
                mutableData = [NSMutableData dataWithLength:usize];
                bzero(&stream, sizeof(stream));
                stream.next_in = (Bytef *)[compressedData bytes];
                stream.avail_in = [compressedData length];
                stream.next_out = (Bytef *)[mutableData mutableBytes];
                stream.avail_out = usize;
                
                if (mutableData && Z_OK == inflateInit2(&stream, -15)) {
                    if (Z_STREAM_END == inflate(&stream, Z_FINISH)) {
                        if (Z_OK == inflateEnd(&stream) && usize == stream.total_out && _crcFromData(mutableData) == crcval) uncompressedData = mutableData;
                    } else {
                        (void)inflateEnd(&stream);
                    }
                } else {
                    uncompressedData = nil;
                }
            }
        }
    }
    if (uncompressedData == nil) {
        if (error) {
            *error = localError ? localError : [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:documentURL, NSURLErrorKey, nil]];
        }
        return nil;
    }
    return uncompressedData;
}

@end
