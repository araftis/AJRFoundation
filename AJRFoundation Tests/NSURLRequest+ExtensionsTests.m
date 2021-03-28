/*
NSURLRequest+ExtensionsTests.m
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
