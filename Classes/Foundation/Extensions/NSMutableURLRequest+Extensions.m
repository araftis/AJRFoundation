
#import "NSMutableURLRequest+Extensions.h"

#import "AJRFormat.h"
#import "NSData+Base64.h"

@implementation NSMutableURLRequest (Extensions)

- (void)setAuthorizationForUserName:(NSString *)userName andPassword:(NSString *)password forHeader:(NSString *)header {
    NSString *base = nil;
    NSString *encoded = nil;
    
    if (userName && !password) {
        base = userName;
    } else if (userName && password) {
        base = AJRFormat(@"%@:%@", userName, password);
    }
    if (base) {
        encoded = [[base dataUsingEncoding:NSUTF8StringEncoding] ajr_base64EncodedString];
    }
    
    if (encoded) {
        [self setValue:AJRFormat(@"Basic %@=", encoded) forHTTPHeaderField:header];
    } else {
        [self setValue:nil forHTTPHeaderField:header];
    }
}

- (void)setBasicAuthorizationForUserName:(NSString *)userName andPassword:(NSString *)password {
	[self setAuthorizationForUserName:userName andPassword:password forHeader:@"Authorization"];
}

- (void)setBasicProxyAuthorizationForUserName:(NSString *)userName andPassword:(NSString *)password {
	[self setAuthorizationForUserName:userName andPassword:password forHeader:@"Proxy-Authorization"];
}

@end
