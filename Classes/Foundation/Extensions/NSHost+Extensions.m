/*
NSHost+Extensions.m
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

#import "NSHost+Extensions.h"

#import "AJRFunctions.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>

NSString *AJRAddressToString(struct addrinfo *address) {
	NSString *string = nil;

	switch (address->ai_addr->sa_family) {
		case AF_INET:
		{
			char buffer[128];
			struct sockaddr_in *p = (struct sockaddr_in *)(address->ai_addr);
			if (inet_ntop(p->sin_family, &p->sin_addr, buffer, sizeof buffer) != NULL) {
				string = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
			}
			break;
		}
		case AF_INET6:
		{
			char buffer[128];
			struct sockaddr_in6 *p = (struct sockaddr_in6 *)(address->ai_addr);
			if (inet_ntop(p->sin6_family, &p->sin6_addr, buffer, sizeof buffer) != NULL) {
				string = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
			}
			break;
		}
	}
	return string;
}

@implementation NSString (AJRHostExtensions)

- (BOOL)isPossibleIPV4Address {
	struct addrinfo address;
	if (inet_pton(AF_INET, self.UTF8String, &address)) {
		return YES;
	}
	return NO;
}

- (BOOL)isPossibleIPV6Address {
	struct addrinfo address;
	if (inet_pton(AF_INET6, self.UTF8String, &address)) {
		return YES;
	}
	return NO;
}

- (BOOL)isPossibleIPAddress {
	return self.isPossibleIPV4Address || self.isPossibleIPV6Address;
}

@end

@implementation NSHost (Extensions)

static NSMutableDictionary *_cache = nil;

+ (NSHost *)_cachedHostForString:(NSString *)string {
    @synchronized ([NSHost class]) {
        if (_cache == nil) {
            _cache = [[NSMutableDictionary alloc] init];
        }
    }

    return [_cache objectForKey:string];
}

+ (NSHost *)hostWithString:(NSString *)string {
    NSHost *host = nil;
    
	if (string.length) {
		host = [self _cachedHostForString:string];
		if (host == nil) {
			if ([string isPossibleIPAddress]) {
				host = [NSHost hostWithAddress:string];
			} else {
				host = [NSHost hostWithName:string];
			}
			if (host) {
				[_cache setObject:host forKey:string];
			}
		}
	}
    
    return host;
}

@end
