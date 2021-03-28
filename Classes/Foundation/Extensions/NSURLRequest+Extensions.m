/*
NSURLRequest+Extensions.m
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

#import "NSURLRequest+Extensions.h"

#import "AJRFunctions.h"

@implementation NSURLRequest (Extensions)

- (NSString *)longDescription {
    NSMutableString *string = [[NSMutableString alloc] init];
    NSDictionary *headers = [self allHTTPHeaderFields];
    NSURL *URL = [self URL];
    NSData *content;
    NSString *contentAsString = nil;
    
    [string appendFormat:@"%@ %@ HTTP/1.1\r\n", [self HTTPMethod], [URL absoluteString]];
    for (NSString *key in headers) {
        id value = [headers objectForKey:key];
        [string appendFormat:@"%@: %@\r\n", key, value];
    }
    [string appendString:@"User-Agent: AJRFoundation/"];
    [string appendString:AJRFoundationBundle().infoDictionary[@"CFBundleVersion"]];
    [string appendString:@"\r\n"];
    if ([URL host]) {
        [string appendString:@"Host: "];
        [string appendString:[URL host]];
        if ([URL port]) {
            [string appendString:@":"];
            [string appendString:[[URL port] description]];
        }
        [string appendString:@"\r\n"];
    }
    if (![headers objectForKey:@"Accept"]) {
        [string appendString:@"Accept: */*\r\n"];
    }
    content = [self HTTPBody];
    if (content) {
        contentAsString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
        [string appendFormat:@"Content-Length: %lu\r\n", (unsigned long)[contentAsString length]];
    }
    [string appendString:@"Connection: close\r\n"];
    [string appendString:@"\r\n"];
    if (contentAsString) {
        [string appendString:contentAsString];
    }
    
    return string;
}

@end
