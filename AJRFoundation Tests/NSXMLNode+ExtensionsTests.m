//
//  NSXMLNode+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/30/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSXMLNode_ExtensionsTests : XCTestCase

@end

@implementation NSXMLNode_ExtensionsTests

- (void)testAll {
    NSXMLElement *element = [NSXMLElement elementWithName:@"p"];
    NSXMLElement *thisIs = [NSXMLElement textWithStringValue:@"This is "];
    NSXMLElement *b = [NSXMLElement elementWithName:@"b"];
    NSXMLElement *bold = [NSXMLElement textWithStringValue:@"bold"];
    NSXMLElement *period = [NSXMLElement textWithStringValue:@"."];
    
    XCTAssert([[element description] isEqualToString:@"<p></p>"]);
    [element addChild:thisIs];
    XCTAssert([[element description] isEqualToString:@"<p>This is </p>"]);
    [element insertChild:period after:thisIs];
    XCTAssert([[element description] isEqualToString:@"<p>This is .</p>"]);
    [element insertChild:b before:period];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b></b>.</p>"]);
    [b addChild:bold];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b>bold</b>.</p>"]);
    [b addAttribute:@"heavy" forName:@"weight"];
    XCTAssert([[element description] isEqualToString:@"<p>This is <b weight=\"heavy\">bold</b>.</p>"]);

    XCTAssert([element findNodeWithName:@"b"] == b);
    XCTAssert([element findNodeWithName:@"b" andValue:@"heavy" forAttribute:@"weight"] == b);
    XCTAssert([thisIs nextSibling] == b);
    
    NSMutableSet *all = [NSMutableSet setWithArray:[element children]];
    [element enumerateChildrenUsingBlock:^(NSXMLNode *node, BOOL *stop) {
        XCTAssert([all containsObject:node]);
        [all removeObject:node];
    }];
    XCTAssert(all.count == 0);
}

@end
