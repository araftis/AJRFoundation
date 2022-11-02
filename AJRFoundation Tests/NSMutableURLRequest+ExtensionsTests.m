/*
 NSMutableURLRequest+ExtensionsTests.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

@interface NSMutableURLRequest_ExtensionsTests : XCTestCase

@end

@implementation NSMutableURLRequest_ExtensionsTests

- (void)testUserAuthorization {
    NSError *localError;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com"]];
    
    [request setBasicAuthorizationForUserName:@"test" andPassword:@"test_password"];
    NSString *header = [request valueForHTTPHeaderField:@"Authorization"];
    XCTAssert(header != nil);
    XCTAssert([header isEqualToString:@"Basic dGVzdDp0ZXN0X3Bhc3N3b3Jk="]);
    NSData *data = [NSData ajr_dataWithBase64EncodedString:[header substringFromIndex:6] error:&localError];
    XCTAssert(data != nil && localError == nil);
    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    XCTAssert([decodedString isEqualToString:@"test:test_password"]);
    
    [request setBasicAuthorizationForUserName:@"test" andPassword:nil];
    header = [request valueForHTTPHeaderField:@"Authorization"];
    XCTAssert(header != nil);
    XCTAssert([header isEqualToString:@"Basic dGVzdA=="]);
    data = [NSData ajr_dataWithBase64EncodedString:[header substringFromIndex:6] error:&localError];
    XCTAssert(data != nil && localError == nil);
    decodedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    XCTAssert([decodedString isEqualToString:@"test"]);

    [request setBasicAuthorizationForUserName:nil andPassword:nil];
    XCTAssert([request valueForHTTPHeaderField:@"Authorization"] == nil);
}

- (void)testUserProxyAuthorization {
    NSError *localError;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com"]];
    
    [request setBasicProxyAuthorizationForUserName:@"test" andPassword:@"test_password"];
    NSString *header = [request valueForHTTPHeaderField:@"Proxy-Authorization"];
    XCTAssert(header != nil);
    XCTAssert([header isEqualToString:@"Basic dGVzdDp0ZXN0X3Bhc3N3b3Jk="]);
    NSData *data = [NSData ajr_dataWithBase64EncodedString:[header substringFromIndex:6] error:&localError];
    XCTAssert(data != nil && localError == nil);
    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    XCTAssert([decodedString isEqualToString:@"test:test_password"]);
    
    [request setBasicProxyAuthorizationForUserName:@"test" andPassword:nil];
    header = [request valueForHTTPHeaderField:@"Proxy-Authorization"];
    XCTAssert(header != nil);
    XCTAssert([header isEqualToString:@"Basic dGVzdA=="]);
    data = [NSData ajr_dataWithBase64EncodedString:[header substringFromIndex:6] error:&localError];
    XCTAssert(data != nil && localError == nil);
    decodedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    XCTAssert([decodedString isEqualToString:@"test"]);

    [request setBasicProxyAuthorizationForUserName:nil andPassword:nil];
    XCTAssert([request valueForHTTPHeaderField:@"Proxy-Authorization"] == nil);
}

@end
