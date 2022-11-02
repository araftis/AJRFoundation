/*
 NSKeyedUnarchiver+Extensions.m
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

#import "NSKeyedUnarchiver+Extensions.h"

#import "AJRFunctions.h"
#import "NSError+Extensions.h"

@implementation NSKeyedUnarchiver (Extensions)

+ (id)ajr_unarchivedObjectWithData:(NSData *)data error:(NSError **)error {
    NSError *localError;
    id newObject;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&localError];
    if (unarchiver) {
        unarchiver.requiresSecureCoding = NO;
        newObject = [unarchiver decodeObjectForKey:@"__ROOT__"];
        if (newObject == nil) {
            localError = [NSError errorWithDomain:NSPOSIXErrorDomain message:@"Failed to unarchive object."];
        }
    }

    return AJRAssertOrPropagateError(newObject, error, localError);
}

+ (nullable id)ajr_unarchivedObjectWithPath:(NSString *)path error:(NSError * _Nullable * _Nullable)error {
    NSError *localError = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&localError];
    id object = nil;
    if (data) {
        object = [self ajr_unarchivedObjectWithData:data error:&localError];
    }
    return AJRAssertOrPropagateError(object, error, localError);
}

+ (nullable id)ajr_unarchivedObjectWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    return [self ajr_unarchivedObjectWithPath:[url path] error:error];
}

@end
