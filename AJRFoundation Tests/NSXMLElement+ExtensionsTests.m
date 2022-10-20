/*
NSXMLElement+ExtensionsTests.m
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

@interface NSXMLElement_ExtensionsTests : XCTestCase

@end

@implementation NSXMLElement_ExtensionsTests

- (void)testElements {
    NSXMLElement *element = [NSXMLElement elementWithName:@"p"];
    NSXMLElement *thisIs = [NSXMLElement textWithStringValue:@"This is "];
    NSXMLElement *b = [NSXMLElement elementWithName:@"b"];
    NSXMLElement *bold = [NSXMLElement textWithStringValue:@"bold"];
    NSXMLElement *period = [NSXMLElement textWithStringValue:@"."];
    NSXMLElement *reallyBold = [NSXMLElement textWithStringValue:@"really bold"];
    
    XCTAssert([[element description] isEqualToString:@"<p></p>"]);
    [element addChild:thisIs];
    XCTAssert([[element description] isEqualToString:@"<p>This is </p>"]);
    [element insertChild:period after:thisIs];
    XCTAssert([[element description] isEqualToString:@"<p>This is .</p>"]);
    [element insertChild:b before:period];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b></b>.</p>"]);
    [b addChild:bold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b>bold</b>.</p>"]);
    [b replaceChild:bold withNode:reallyBold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b>really bold</b>.</p>"]);
    [b removeChild:reallyBold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b></b>.</p>"]);
    [b insertChild:bold after:reallyBold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b>bold</b>.</p>"]);
    [b removeChild:bold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b></b>.</p>"]);
    [b removeChild:bold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b></b>.</p>"]);
    [b replaceChild:reallyBold withNode:bold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b></b>.</p>"]);
    [b insertChild:bold before:reallyBold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b>bold</b>.</p>"]);
    [b addAttribute:@"heavy" forName:@"weight"];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b weight=\"heavy\">bold</b>.</p>"]);
    [b addAttribute:nil forName:@"weight"];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b>bold</b>.</p>"]);
}

@end
