
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
