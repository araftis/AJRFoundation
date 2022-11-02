/*
 NSURL+ExtensionsTests.m
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

@interface NSURLTest : XCTestCase

@end

@implementation NSURLTest

- (void)testIsEqualToURL {
    NSURL *url1, *url2;
    
    url1 = [NSURL URLWithString:@"http://www.apple.com/"];
    url2 = [NSURL URLWithString:@"http://www.apple.com"];
    XCTAssertTrue([url1 isEqualToURL:url2], @"Unexpected results for %@ == %@", url1, url2);

    url1 = [NSURL URLWithString:@"http://www.apple.com/foo/"];
    url2 = [NSURL URLWithString:@"http://www.apple.com"];
    XCTAssertTrue(![url1 isEqualToURL:url2], @"Unexpected results for %@ == %@", url1, url2);

    url1 = [NSURL URLWithString:@"http://www.apple.com/foo/"];
    url2 = [NSURL URLWithString:@"http://www.apple.com//foo///"];
    XCTAssertTrue([url1 isEqualToURL:url2], @"Unexpected results for %@ == %@", url1, url2);
    
    url1 = [NSURL URLWithString:@"http://www.apple.com/foo/bar/?a=b&c=d"];
    url2 = [NSURL URLWithString:@"http://www.apple.com/foo/bar/?c=d&a=b"];
    XCTAssertTrue([url1 isEqualToURL:url2], @"Unexpected results for %@ == %@", url1, url2);
    
    url1 = [NSURL URLWithString:@"http://www.apple.com"];
    url2 = [NSURL URLWithString:@"http://www.apple.com"];
    XCTAssertTrue([url1 isEqualToURL:url2], @"Unexpected results for %@ == %@", url1, url2);
    
    url1 = [NSURL URLWithString:@"http://www.apple.com/search?hl=en&q=meaning+of+life"];
    url2 = [NSURL URLWithString:@"http://www.google.com/search?hl=en&q=meaning+of+life"];
    XCTAssert(![url1 isEqualToURL:url2]);
    
    url1 = [NSURL URLWithString:@"http://www.apple.com/search?hl=en&q=meaning+of+life"];
    url2 = [NSURL URLWithString:@"https://www.apple.com/search?hl=en&q=meaning+of+life"];
    XCTAssert(![url1 isEqualToURL:url2]);
    
    url1 = [NSURL URLWithString:@"http://www.apple.com/search?hl=en&q=meaning+of+life"];
    url2 = [NSURL URLWithString:@"http://www.apple.com/search?hl=es&q=meaning+of+life"];
    XCTAssert(![url1 isEqualToURL:url2]);
}

- (void)testQueries {
    NSURL *URL = [NSURL URLWithString:@"http://www.google.com/search"];
    NSDictionary *query;
    
    URL = [URL URLByAppendingQueryValue:@"en" forKey:@"hl"];
    URL = [URL URLByAppendingQueryValue:[@"meaning of life" stringByReplacingOccurrencesOfString:@" " withString:@"+"] forKey:@"q"];
    
    AJRPrintf(@"URL: %@\n", URL);
    
    URL = [NSURL URLWithParsableString:@"meaning of life"];
    XCTAssert(URL != nil && [[URL host] isEqualToString:@"www.google.com"] && [[URL scheme] isEqualToString:@"https"]);
    query = URL.queryDictionary;
    XCTAssert([query[@"hl"] isEqualToString:@"en"]);
    XCTAssert([query[@"q"] isEqualToString:@"meaning+of+life"]);

    URL = [NSURL URLWithParsableString:@"https://www.apple.com/"];
    XCTAssert(URL != nil && [[URL host] isEqualToString:@"www.apple.com"] && [[URL scheme] isEqualToString:@"https"]);
    
    URL = [NSURL URLWithParsableString:@"www.yahoo.com"];
    XCTAssert(URL != nil && [[URL host] isEqualToString:@"www.yahoo.com"] && [[URL scheme] isEqualToString:@"https"]);
    
    URL = [NSURL URLWithParsableString:@"www.yahoo.com is fine."];
    XCTAssert(URL != nil && [[URL host] isEqualToString:@"www.google.com"] && [[URL scheme] isEqualToString:@"https"]);
}

- (void)testPathUTI {
    NSString *UTI = [[NSURL URLWithString:@"http://www.apple.com/test.png"] pathUTI];
    XCTAssert([UTI isEqualToString:@"public.png"]);
    
    UTI = [[NSURL URLWithString:@"http://www.apple.com/test"] pathUTI];
    XCTAssert(UTI == nil);
}

@end
