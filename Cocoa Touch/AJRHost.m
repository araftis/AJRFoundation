/*
AJRHost.m
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

#import "AJRHostP.h"

#import "AJRFormat.h"
#import "AJRLogging.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"

#import <netinet/in.h>
#import <netdb.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#define AJRMaxHostNameLength        1024
#define AJRMaxHostNameSize        (AJRMaxHostNameLength+1)

typedef NS_ENUM(uint8_t, AJRHostResolutionType) {
    AJRHostResolutionTypeLocalhost,
    AJRHostResolutionTypeName,
    AJRHostResolutionTypeAddress,
};

BOOL AJRHostFailNameLookUpForUnitTesting = NO;
BOOL AJRHostFailLocalHostNameForUnitTesting = NO;

static NSString * const AJRHostErrorDomain = @"AJRHostError";
static NSString * const AJRHostNameKey = @"hostName";
static NSString * const AJRHostAddressKey = @"hostAddress";
static NSString * const AJRBlockKey = @"block";

@class AJRHostResolutionThread;

static NSRecursiveLock *_hostCacheLock = nil;
static NSMutableDictionary *_hostCache = nil;

static dispatch_queue_t AJRGetResolutionQueue(void) {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("ajr_host_resolution", DISPATCH_QUEUE_CONCURRENT_WITH_AUTORELEASE_POOL);
    });
    return queue;
}

typedef void (^AJRResolutionBlock)(void);

void AJRResolveLocalHost(BOOL wait, AJRHostResolutionCompletionBlock block) {
    AJRResolutionBlock resolutionBlock = ^{
        struct ifaddrs *ifa, *ifap;
        NSMutableArray *addresses = nil;
        NSMutableArray *names = nil;
        __block NSUInteger insertIndexAddresses = 0;
        __block NSUInteger insertIndexNames = 0;
        NSError *localError = nil;
        dispatch_group_t group;
        char hostname[NI_MAXHOST];
        NSRecursiveLock *valuesLock = [[NSRecursiveLock alloc] init];
        
        if (getifaddrs(&ifa) == 0 && !AJRHostFailNameLookUpForUnitTesting) {
            group = dispatch_group_create();
            
            for (ifap = ifa; ifap; ifap = ifap->ifa_next) {
                sa_family_t family = ifap->ifa_addr->sa_family;
                socklen_t length = ifap->ifa_addr->sa_len;
                dispatch_queue_t queue;
                
                // We only care about IPv4 & IPv6.
                if (family != AF_INET && family != AF_INET6) continue;
                
                void (^lookup)(NSMutableArray *, int) = ^(NSMutableArray *values, int lookupType) {
                    char hostname[NI_MAXHOST];
                    
                    memset(hostname, 0, sizeof(hostname));
                    if (getnameinfo(ifap->ifa_addr, length, hostname, sizeof(hostname), NULL, 0, lookupType) == 0) {
                        NSString *result = [NSString stringWithUTF8String:hostname];
                        if ([result isEqualToString:@"localhost"]) return;
                        if (result) {
                            [valuesLock lock];
                            @try {
                                if (![values containsObject:result]) {
                                    if ('l' == ifap->ifa_name[0] && 'o' == ifap->ifa_name[1]) {
                                        [values addObject:result];
                                    } else {
                                        [values insertObject:result atIndex:(lookupType & NI_NAMEREQD) ? insertIndexNames++ : insertIndexAddresses++];
                                    }
                                }
                            } @finally {
                                [valuesLock unlock];
                            }
                        }
                    }
                };
                if (addresses == nil) {
                    addresses = [NSMutableArray array];
                }
                if (names == nil) {
                    names = [NSMutableArray array];
                }
                queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_group_async(group, queue, ^{ lookup(addresses, NI_NUMERICHOST); });
                dispatch_group_async(group, queue, ^{ lookup(names, NI_NAMEREQD); });
                dispatch_group_async(group, queue, ^{ lookup(names, NI_NOFQDN|NI_NAMEREQD); });
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            freeifaddrs(ifa);
            
            // Do a little more massaging, now that we've resolved everything above.
            memset(hostname, 0, sizeof(hostname));
            if (gethostname(hostname, sizeof(hostname)) == 0) {
                NSString *name = [NSString stringWithUTF8String:hostname];
                if (AJRHostFailLocalHostNameForUnitTesting) {
                    [names removeObject:name];
                    insertIndexNames = [names count];
                }
                if (name && ![names containsObject:name]) {
                    [names insertObject:name atIndex:insertIndexNames];
                }
            }
            if (![names containsObject:@"localhost"]) {
                [names addObject:@"localhost"];
            }
        } else {
            localError = [NSError errorWithDomain:AJRHostErrorDomain message:@"Failed to look up host localhost"];
        }
        
        block(names, addresses, localError);
    };
    
    if (wait) {
        dispatch_sync(AJRGetResolutionQueue(), resolutionBlock);
    } else {
        dispatch_async(AJRGetResolutionQueue(), resolutionBlock);
    }
}

static void AJRResolveHost(BOOL wait, NSString *hostName, NSString *address, AJRHostResolutionCompletionBlock block) {
    AJRResolutionBlock resolutionBlock = ^{
        NSString *resolutionValue = hostName;
        int addressInfoFlags;
        struct addrinfo hints, *resolution, *firstResolution;
        NSMutableArray *addresses = nil;
        NSMutableArray *names = nil;
        NSError *localError = nil;
        dispatch_group_t group;
        NSRecursiveLock *valuesLock = [[NSRecursiveLock alloc] init];
        
        if (resolutionValue) {
            addressInfoFlags = AI_PASSIVE | AI_CANONNAME;
        } else {
            resolutionValue = address;
            addressInfoFlags = AI_PASSIVE | AI_CANONNAME | AI_NUMERICHOST;
        }
        
        memset(&hints, 0, sizeof(hints));
        hints.ai_family = PF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = addressInfoFlags;
        if (getaddrinfo([resolutionValue UTF8String], NULL, &hints, &firstResolution) == 0 && !AJRHostFailNameLookUpForUnitTesting) {
            group = dispatch_group_create();
            
            for (resolution = firstResolution; resolution; resolution = resolution->ai_next) {
                sa_family_t family = resolution->ai_addr->sa_family;
                socklen_t length = resolution->ai_addr->sa_len;
                dispatch_queue_t queue;
                
                // We only care about IPv4 & IPv6.
                if (family != AF_INET && family != AF_INET6) continue;
                
                void (^lookup)(NSMutableArray *, int) = ^(NSMutableArray *values, int lookupType) {
                    char hostname[NI_MAXHOST];
                    
                    memset(hostname, 0, sizeof(hostname));
                    if (getnameinfo(resolution->ai_addr, length, hostname, sizeof(hostname), NULL, 0, lookupType) == 0) {
                        NSString *result = [NSString stringWithUTF8String:hostname];
                        if (result) {
                            [valuesLock lock];
                            @try {
                                if (![values containsObject:result]) {
                                    [values addObject:result];
                                }
                            } @finally {
                                [valuesLock unlock];
                            }
                        }
                    }
                };
                if (addresses == nil) {
                    addresses = [NSMutableArray array];
                }
                if (names == nil) {
                    names = [NSMutableArray array];
                }
                queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_group_async(group, queue, ^{ lookup(addresses, NI_NUMERICHOST); });
                dispatch_group_async(group, queue, ^{ lookup(names, NI_NAMEREQD); });
                dispatch_group_async(group, queue, ^{ lookup(names, NI_NOFQDN|NI_NAMEREQD); });
                
                if (NULL != resolution->ai_canonname) {
                    dispatch_group_async(group, queue, ^ {
                        NSString *name = [NSString stringWithUTF8String:resolution->ai_canonname];
                        if (name && ![names containsObject:name]) {
                            [names addObject:name];
                        }
                    });
                };
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            freeaddrinfo(firstResolution);
        } else {
            localError = [NSError errorWithDomain:AJRHostErrorDomain format:@"Failed to look up host via %@", resolutionValue];
        }
        
        block(names, addresses, localError);
    };
    
    if (wait) {
        dispatch_sync(AJRGetResolutionQueue(), resolutionBlock);
    } else {
        dispatch_async(AJRGetResolutionQueue(), resolutionBlock);
    }
}

void AJRResolveHostByName(BOOL wait, NSString *hostName, AJRHostResolutionCompletionBlock block) {
    AJRResolveHost(wait, hostName, nil, block);
}

void AJRResolveHostByAddress(BOOL wait, NSString *address, AJRHostResolutionCompletionBlock block) {
    AJRResolveHost(wait, nil, address, block);
}

@implementation AJRHost {
    NSArray *_names;
    NSArray *_addresses;
    
    AJRHostResolutionType _resolutionType;
    NSString *_resolutionValue;
    NSCondition *_resolutionCondition;
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hostCache = [[NSMutableDictionary alloc] init];
        _hostCacheLock = [[NSRecursiveLock alloc] init];
    });
}

+ (void)flushHostCache {
    [_hostCacheLock lock];
    [_hostCache removeAllObjects];
    [_hostCacheLock unlock];
}

+ (AJRHost *)currentHost {
    return [[self alloc] init];
}

+ (AJRHost *)hostWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

+ (AJRHost *)hostWithAddress:(NSString *)address {
    return [[self alloc] initWithAddress:address];
}

- (id)init {
    return [self initWithResolutionType:AJRHostResolutionTypeLocalhost value:nil];
}

- (id)initWithName:(NSString *)name {
    return [self initWithResolutionType:AJRHostResolutionTypeName value:name];
}

- (id)initWithAddress:(NSString *)address {
    return [self initWithResolutionType:AJRHostResolutionTypeAddress value:address];
}

- (id)initWithResolutionType:(AJRHostResolutionType)type value:(NSString *)value {
    AJRHost    *host = nil;
    
    [_hostCacheLock lock];
    @try {
        host = [_hostCache objectForKey:value ? value : @"localhost"];
    } @finally {
        [_hostCacheLock unlock];
    }
    if (host) {
        self = host;
    } else {
        if ((self = [super init])) {
            _resolutionType = type;
            _resolutionValue = value;
            _resolutionCondition = [[NSCondition alloc] init];
        }
    }
    return self;
}

static void _addToCache(AJRHost *host, NSArray *values) {
    for (NSString *value in values) {
        if (![_hostCache objectForKey:value]) {
            [_hostCache setObject:host forKey:value];
        }
    }
}

- (void)resolveAndWait:(BOOL)wait {
    if (_names == nil && _addresses == nil) {
        // We've already scheduled a host resolution, so don't do so again.
        AJRHostResolutionCompletionBlock    block = ^(NSArray *names, NSArray *addresses, NSError *error) {
            if (error) {
                AJRLogError(@"Failed to resolve host %@: %@", self->_resolutionValue, [error localizedDescription]);
            } else {
                self->_addresses = [addresses copy];
                self->_names = [names copy];
                // Copy into our host cache...
                [_hostCacheLock lock];
                @try {
                    _addToCache(self, self->_addresses);
                    _addToCache(self, self->_names);
                } @finally {
                    [_hostCacheLock unlock];
                }
            }
        };
        
        switch (_resolutionType) {
            case AJRHostResolutionTypeLocalhost:
                AJRResolveLocalHost(wait, block);
                break;
            case AJRHostResolutionTypeName:
                AJRResolveHostByName(wait, _resolutionValue, block);
                break;
            case AJRHostResolutionTypeAddress:
                AJRResolveHostByAddress(wait, _resolutionValue, block);
                break;
        }
    }
}

- (BOOL)isEqualToHost:(AJRHost *)aHost {
    // I'm not 100% sure this is correct, but it's what I'm going with. Basically, if either of the hosts shares an address, I'll consider them the same.
    NSMutableSet *leftSet = [[NSSet setWithArray:[self addresses]] mutableCopy];
    NSSet *rightSet = [NSSet setWithArray:[aHost addresses]];
    
    [leftSet intersectSet:rightSet];
    
    return [leftSet count] != 0;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[AJRHost class]] ? [self isEqualToHost:object] : NO;
}

- (NSString *)name {
    if (_resolutionType == AJRHostResolutionTypeName) {
        return _resolutionValue;
    }
    [self resolveAndWait:YES];
    return [_names count] ? [_names objectAtIndex:0] : nil;
}

- (NSArray *)names {
    [self resolveAndWait:YES];
    return _names;
}

- (NSString *)address {
    if (_resolutionType == AJRHostResolutionTypeAddress) {
        return _resolutionValue;
    }
    [self resolveAndWait:YES];
    return [_addresses count] ? [_addresses objectAtIndex:0] : nil;
}

- (NSArray *)addresses {
    [self resolveAndWait:YES];
    return _addresses;
}

- (NSString *)localizedName {
    [self resolveAndWait:YES];
    return [self name];
}

@end
