/*
AJRHTTPProxy.m
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

#import "AJRHTTPProxy.h"

#import <SystemConfiguration/SystemConfiguration.h>

@implementation AJRHTTPProxy

+ (id)proxyWithHost:(NSHost *)host port:(NSUInteger)port {
    return [[self alloc] initWithHost:host port:port];
}

+ (id)proxyWithHost:(NSHost *)host port:(NSUInteger)port username:(NSString *)username password:(NSString *)password {
    return [[self alloc] initWithHost:host port:port username:username password:password];
}

+ (id)proxyWithPAC:(NSString *)pac {
    return [[self alloc] initWithPAC:pac];
}

+ (id)proxyWithPAC:(NSString *)pac username:(NSString *)username password:(NSString *)password {
    return [[self alloc] initWithPAC:pac username:username password:password];
}

- (id)initWithHost:(NSHost *)host port:(NSUInteger)port {
    if ((self = [super init])) {
        self.host = host;
        self.port = port;
    }
    return self;
}

- (id)initWithHost:(NSHost *)host port:(NSUInteger)port username:(NSString *)username password:(NSString *)password {
    if ((self = [self initWithHost:host port:port])) {
        self.username = username;
        self.password = password;
    }
    return self;
}

- (id)initWithPAC:(NSString *)pac {
    if ((self = [super init])) {
        self.pacURL = pac;
    }
    return self;
}

- (id)initWithPAC:(NSString *)pac username:(NSString *)username password:(NSString *)password {
    if ((self = [self initWithPAC:pac])) {
        self.username = username;
        self.password = password;
    }
    return self;
}

- (NSDictionary *)dictionary {
    if (_pacURL) {
        return @{
#if !defined(AJRFoundation_iOS)
                 (__bridge NSString *)kSCPropNetProxiesProxyAutoConfigEnable:[NSNumber numberWithBool:YES],
                 (__bridge NSString *)kSCPropNetProxiesProxyAutoConfigURLString:_pacURL,
#endif
                };
    }
    return @{
#if !defined(AJRFoundation_iOS)
             (__bridge NSString *)kSCPropNetProxiesHTTPEnable:[NSNumber numberWithBool:YES],
             (__bridge NSString *)kSCPropNetProxiesHTTPPort:[NSNumber numberWithUnsignedInteger:_port],
             (__bridge NSString *)kSCPropNetProxiesHTTPProxy:[_host name],
             (__bridge NSString *)kSCPropNetProxiesHTTPSEnable:[NSNumber numberWithBool:YES],
             (__bridge NSString *)kSCPropNetProxiesHTTPSPort:[NSNumber numberWithUnsignedInteger:_port],
             (__bridge NSString *)kSCPropNetProxiesHTTPSProxy:[_host name],
#endif
            };
}

@end
