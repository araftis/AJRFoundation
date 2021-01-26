//
//  NSURLRequest+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/29/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSURLRequest_ExtensionsTests : XCTestCase

@end

@implementation NSURLRequest_ExtensionsTests

- (void)testDescription {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com:110"]];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"testReadingCharacters" ofType:@"utf8" inDirectory:@"Test Files"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    XCTAssert(data != nil);
    
    [request addValue:@"test" forHTTPHeaderField:@"Test-Field"];
    [request setHTTPBody:data];
    
    NSString *longDescription = request.longDescription;
    AJRPrintf(@"request:\n%@\n", longDescription);
    
    // Let's make sure some expected content can be found.
    XCTAssert([longDescription rangeOfString:string].location != NSNotFound);
    XCTAssert([longDescription rangeOfString:@"Content-Length:"].location != NSNotFound);
    XCTAssert([longDescription rangeOfString:@"Host: www.apple.com:110"].location != NSNotFound);
}

@end
