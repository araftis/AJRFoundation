/* NSHost-Socks.m created by alex on Sat 03-Jan-1998 */

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
