/*
NSHost+ExtensionsTests.m
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
