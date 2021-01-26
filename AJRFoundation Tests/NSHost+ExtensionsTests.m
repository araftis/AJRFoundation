//
//  NSHost+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/16/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>

@interface NSHost_ExtensionsTests : XCTestCase

@end

@implementation NSHost_ExtensionsTests

- (void)testIPAddressDetection {
    NSHost *host = [NSHost currentHost];
    
    for (NSString *address in [host addresses]) {
        AJRPrintf(@"address: %@, addr: %B, IPv4: %B IPv6: %B\n", address, [address isPossibleIPAddress], [address isPossibleIPV4Address], [address isPossibleIPV6Address]);
        XCTAssert(address.isPossibleIPAddress);
        XCTAssert(address.isPossibleIPV4Address != address.isPossibleIPV6Address);
    }
    XCTAssert(!@"This is a test".isPossibleIPAddress);
    XCTAssert(!@"www.apple.com".isPossibleIPAddress);
}

- (void)testHostResolution {
    NSHost *host;
    
    host = [NSHost hostWithString:@"www.apple.com"];
    for (NSString *address in host.addresses) {
        NSHost *hostViaAddress = [NSHost hostWithString:address];
        XCTAssert([host isEqualToHost:hostViaAddress]);
        
        struct addrinfo *addressInfo;
        if (getaddrinfo([address UTF8String], NULL, NULL, &addressInfo) == 0) {
            XCTAssert([address isEqualToString:AJRAddressToString(addressInfo)]);
            freeaddrinfo(addressInfo);
        }
    }
    
    XCTAssert([NSHost hostWithString:@""] == nil);
}

@end
