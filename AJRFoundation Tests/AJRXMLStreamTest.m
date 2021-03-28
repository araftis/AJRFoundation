/*
AJRXMLStreamTest.m
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

#import "AJRXMLCoder.h"
#import "AJRXMLOutputStream.h"
#import "NSArray+Extensions.h"
#import "NSOutputStream+Extensions.h"

@interface TestDocument : NSObject <AJRXMLCoding>
- (id)initWithType:(NSString *)type;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSMutableArray *pages;
@end

@interface TestPage : NSObject <AJRXMLCoding>
- (id)initWithType:(NSString *)type pageNumber:(NSInteger)pageNumber;
@property (nonatomic,weak) TestDocument *document;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,assign) NSInteger pageNumber;
@end

@implementation TestDocument

- (id)initWithType:(NSString *)type {
    if ((self = [super init])) {
        _type = type;
        _pages = [[NSMutableArray alloc] init];
        
        [_pages addObject:[[TestPage alloc] initWithType:@"master.left" pageNumber:1]];
        [(TestPage *)[_pages lastObject] setDocument:self];
        [_pages addObject:[[TestPage alloc] initWithType:@"master.right" pageNumber:2]];
        [(TestPage *)[_pages lastObject] setDocument:self];
    }
    return self;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeString:_type forKey:@"type"];
    [coder encodeObject:_pages forKey:@"pages"];
}

@end

@implementation TestPage

- (id)initWithType:(NSString *)type pageNumber:(NSInteger)pageNumber {
    if ((self = [super init])) {
        _type = type;
        _pageNumber = pageNumber;
    }
    return self;
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"page";
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if (_document) [coder encodeObject:_document forKey:@"document"];
    [coder encodeString:_type forKey:@"type"];
    [coder encodeInteger:_pageNumber forKey:@"pageNumber"];
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
}

- (NSString *)preferredXMLName {
    return @"page";
}

@end

@interface AJRXMLStreamTest : XCTestCase <NSStreamDelegate>
@end

@implementation AJRXMLStreamTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleDocument {
    NSString *expectedResult = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               @"<document type=\"com.ajr.document\">\n"
                               @"  <page type=\"master.left\"/>\n"
                               @"  <page type=\"master.right\"/>\n"
                               @"</document>\n";
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    [output setDelegate:self];
    [output open];
    [AJRXMLOutputStream XMLDocumentStreamedInto:output scope:^(AJRXMLOutputStream *builder) {
        [builder setPrettyOutput:YES];
        [builder setEncoding:NSUTF8StringEncoding];
        [builder setVersion:@"1.0"];
        [builder push:@"document" scope:^{
            [builder addAttribute:@"type" withValue:@"com.ajr.document"];
            [builder push:@"page" scope:^{
                [builder addAttribute:@"type" withValue:@"master.left"];
            }];
            [builder push:@"page" scope:^{
                [builder addAttribute:@"type" withValue:@"master.right"];
            }];
        }];
    }];
    //[output close];
    
    NSString *string = [[NSString alloc] initWithData:[output propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[output encoding]];

    XCTAssert([string isEqualToString:expectedResult], @"expected to get document:\n%@\nbut got:\n%@\n", expectedResult, string);
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"%d", (int)streamEvent);
}

- (void)testNSOutputStream {
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    
    [stream setDelegate:self];
    [stream open];
    for (NSInteger x = 0; x < 10000; x++) {
        [stream writeCString:" "];
        [stream writeCString:""];
    }
    [stream close];

    NSString *string = [[NSString alloc] initWithData:[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[stream encoding]];
    XCTAssert([string length] == 10000, @"Expected the resulting string to be 10000 characters, but it was only %ld", (long)[string length]);
}

- (void)testEncodedSimpleDocument {
    TestDocument *document = [[TestDocument alloc] initWithType:@"com.ajr.document"];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    AJRXMLCoder *coder = [[AJRXMLCoder alloc] initWithStream:outputStream];
    
    [outputStream open];
    [coder encodeRootObject:document forKey:@"document"];
    [outputStream close];

    NSLog(@"result:\n\n%@\n\n", [[NSString alloc] initWithData:[outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[outputStream encoding]]);
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/
@end
