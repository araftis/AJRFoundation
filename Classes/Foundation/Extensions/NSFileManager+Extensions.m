/*
 NSFileManager+Extensions.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import "NSFileManager+Extensions.h"

#import "NSError+Extensions.h"
#import "AJRFormat.h"
#import "AJRLogging.h"

#import <glob.h>

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
    mkstemp(buffer);
    
    fileName = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    if (extension) {
        fileName = [fileName stringByAppendingPathExtension:extension];
    }
    
    return fileName;
}

- (BOOL)enumerateFilesMatchingPattern:(NSString *)pattern usingBlock:(void (^)(NSString *filename, BOOL *stop))block error:(NSError **)error {
    glob_t globber;
    __block NSError *localError = nil;
    int (^errorHandler)(const char *path, int errorNumber) = ^(const char *path, int errorNumber){
        localError = [NSError errorWithDomain:@"NSFileManagerErrorDomain" code:errorNumber format:@"An error occured while expanding pattern \"%@\": %s.", pattern, strerror(errorNumber)];
        return 0;
    };

    glob_b([pattern UTF8String], 0, errorHandler, &globber);
    for (int y = 0; y < globber.gl_pathc; y++) {
        BOOL stop = NO;
        block([NSString stringWithUTF8String:globber.gl_pathv[y]], &stop);
        if (localError != nil || stop) {
            break;
        }
    }
    globfree(&globber);
    if (localError != nil) {
        AJRSetOutParameter(error, localError);
        return NO;
    }
    return YES;
}

- (NSURL *)currentDirectoryURL {
    return [NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath];
}

@end
