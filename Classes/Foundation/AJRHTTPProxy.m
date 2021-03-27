
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
