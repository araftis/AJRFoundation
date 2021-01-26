//
//  NSFileManager+Extensions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 10/17/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "NSFileManager+Extensions.h"

#import "AJRFormat.h"

@implementation NSFileManager (Extensions)

- (NSString *)temporaryFilename {
    return [self temporaryFilenameForTemplate:[NSTemporaryDirectory() stringByAppendingPathComponent:AJRFormat(@"%@-XXXXXX", NSProcessInfo.processInfo.processName)]];
}

- (NSString *)temporaryFilenameForTemplate:(NSString *)template {
    char buffer[1024];
    NSString *extension = [template pathExtension];
	NSString *fileName;
    
    template = [template stringByDeletingPathExtension];
    strncpy(buffer, [template cStringUsingEncoding:NSUTF8StringEncoding], 1023);
	mktemp(buffer);
    
	fileName = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    if (extension) {
        fileName = [fileName stringByAppendingPathExtension:extension];
    }
    
    return fileName;
}

@end
