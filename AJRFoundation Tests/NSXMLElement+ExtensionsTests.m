
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
