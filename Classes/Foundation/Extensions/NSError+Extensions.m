/*
 NSError+Extensions.m
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

#import "NSError+Extensions.h"

#import "AJRFormat.h"
#import "NSNumber+Extensions.h"

@implementation NSError (Extensions)

+ (NSError *)errorWithDomain:(NSString *)domain errorNumber:(int)errorNo {
    return [NSError errorWithDomain:domain code:errorNo userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithCString:strerror(errorNo) encoding:NSUTF8StringEncoding]}];
}

+ (NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message {
    return [NSError errorWithDomain:domain code:-1 userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (NSError *)errorWithDomain:(NSString *)domain format:(NSString *)format arguments:(va_list)ap {
    return [self errorWithDomain:domain message:AJRFormatv(format, ap)];
}

+ (NSError *)errorWithDomain:(NSString *)domain format:(NSString *)format, ... {
    NSError *error;
    va_list ap;
    
    va_start(ap, format);
    error = [self errorWithDomain:domain format:format arguments:ap];
    va_end(ap);
    
    return error;
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)message {
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format arguments:(va_list)ap {
    return [self errorWithDomain:domain code:code message:AJRFormatv(format, ap)];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format, ... {
    NSError *error;
    va_list ap;
    
    va_start(ap, format);
    error = [self errorWithDomain:domain code:code format:format arguments:ap];
    va_end(ap);
    
    return error;
}

@end
