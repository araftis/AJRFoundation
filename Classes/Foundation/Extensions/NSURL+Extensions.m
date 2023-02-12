/*
 NSURL+Extensions.m
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

#import "NSURL+Extensions.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSString+Extensions.h"
#import "NSMutableDictionary+Extensions.h"
#import "NSMutableString+Extensions.h"
#import "NSURLQueryItem+Extensions.h"

@implementation NSURL (Extensions)

- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary<NSString *, NSString *> *)queryDictionary; {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableArray *queryItems = [components.queryItems mutableCopy] ?: [NSMutableArray array];

    [queryItems addObjectsFromArray:[NSURLQueryItem queryItemsFromDictionary:queryDictionary]];
    components.queryItems = queryItems;

    return [components URL];
}

- (NSURL *)URLByAppendingQueryValue:(NSString *)query forKey:(NSString *)key {
    return [self URLByAppendingQueryDictionary:@{key:query}];
}

- (NSDictionary *)queryDictionary {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];

    for (NSURLQueryItem *item in components.queryItems) {
        [query setObjectIfNotNil:item.value forKey:item.name];
    }

    return query;
}

- (NSString *)pathUTI {
    return AJRUTIForPathExtension(self.pathExtension);
}

- (NSString *)_normalizePath:(NSString *)path {
    path = [path lowercaseString];
    
    NSArray *components = [path componentsSeparatedByString:@"/"];
    
    NSMutableString *result = [NSMutableString string];
    BOOL first = YES;
    for (NSString *component in components) {
        if ([component length] > 0) {
            if (!first) {
                [result appendString:@"/"];
            } else {
                first = NO;
            }
            [result appendString:component];
        }
    }
    
    path = result;
    
    return path;
}

- (BOOL)isEqualToURL:(NSURL *)other {
    NSString *scheme = [[self scheme] lowercaseString];
    NSString *otherScheme = [[other scheme] lowercaseString];
    
    if (!AJREqual(scheme, otherScheme)) {
        return NO;
    }
    
    NSString *host = [[self host] lowercaseString];
    NSString *otherHost = [[other host] lowercaseString];
    
    if (!AJREqual(host, otherHost)) {
        return NO;
    }
    
    NSString *path = [self _normalizePath:[self path]];
    NSString *otherPath = [self _normalizePath:[other path]];
    
    if (!AJREqual(path, otherPath)) {
        return NO;
    }
    
    NSDictionary *queryDict = [self queryDictionary];
    NSDictionary *otherQueryDict = [other queryDictionary];

    if (!AJREqual(queryDict, otherQueryDict)) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)ajr_string:(NSString *)string isPrefixedWithKnownScheme:(NSString **)output {
    static NSSet *knownSchemes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        knownSchemes = [NSSet setWithArray:@[@"http", @"https", @"ftp"]];
    });

    NSString *foundScheme = nil;

    for (NSString *scheme in knownSchemes) {
        if ([string hasCaseInsensitivePrefix:[scheme stringByAppendingString:@":"]]) {
            foundScheme = scheme;
            break;
        }
    }

    if (foundScheme) {
        AJRSetOutParameter(output, foundScheme);
    }
    return foundScheme != nil;
}

+ (NSURL *)URLWithParsableString:(NSString *)string {
    BOOL hasKnownPrefix = NO;

    // I'd like this to be smarter, but this'll do for now.
    hasKnownPrefix = [self ajr_string:string isPrefixedWithKnownScheme:NULL];

    if (!hasKnownPrefix) {
        NSURL *possibleURL = nil;

        // If all the characters are valid in a host name and we have at least one '.' character. If they are, try and turn into a URL.
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet URLHostAllowedCharacterSet] invertedSet]].location == NSNotFound && [string rangeOfString:@"."].location != NSNotFound) {
            possibleURL = [NSURL URLWithString:AJRFormat(@"https://%@", string)];
        }

        if (!possibleURL) {
            NSURL *url = [NSURL URLWithString:@"https://www.google.com/search"];
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *language = [NSLocale currentLocale].languageCode;
            components.queryItems = [NSURLQueryItem queryItemsFromDictionary:@{@"hl":language,
                                                                               @"q":string}];
            return [components URL];
        }

        if (possibleURL) {
            return possibleURL;
        }
    }

    return [NSURL URLWithString:string];
}

- (BOOL)isTemporary {
    return [self.path hasPrefix:NSTemporaryDirectory()];
}

- (NSURL *)URLByAppendingPathComponents:(NSArray<NSString *> *)components {
    return [self URLByAppendingPathComponents:components lastIsDirectory:NO];
}

- (NSURL *)URLByAppendingPathComponents:(NSArray<NSString *> *)components lastIsDirectory:(BOOL)flag {
    __block NSURL *result = self;

    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger index, BOOL *stop) {
        if (index == components.count - 1) {
            result = [result URLByAppendingPathComponent:component isDirectory:YES];
        } else {
            result = [result URLByAppendingPathComponent:component isDirectory:NO];
        }
    }];

    return result;
}

@end
