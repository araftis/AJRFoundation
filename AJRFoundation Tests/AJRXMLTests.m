/*
AJRXMLTests.m
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

// This is a private class, but we need access to it in order to fully test our code. Since it'll only exist in the unit test, this should be safe.
@interface NSXMLAttributeDeclaration : NSXMLNode

- (NSString *)elementName;

@end

@interface AJRXMLTest : XCTestCase

@end

@implementation AJRXMLTest

/* Basically removed, because I'm now only supporting the swift verison. We should bring back these tests for iOS based OSes, but we'll need to change the names to drop the AJR from the front.
- (void)testBasicTypes {
    NSXMLNode *nsNode;
    AJRXMLNode *ajrNode;
    
    nsNode = [NSXMLNode attributeWithName:@"name" stringValue:@"string"];
    ajrNode = [AJRXMLNode attributeWithName:@"name" stringValue:@"string"];
    AJRPrintf(@"attribute:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode attributeWithName:@"<name>" stringValue:@"<<string&fun>>"];
    ajrNode = [AJRXMLNode attributeWithName:@"<name>" stringValue:@"<<string&fun>>"];
    AJRPrintf(@"attribute:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode namespaceWithName:@"name" stringValue:@"string"];
    ajrNode = [AJRXMLNode namespaceWithName:@"name" stringValue:@"string"];
    AJRPrintf(@"namespace:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode commentWithStringValue:@"comment"];
    ajrNode = [AJRXMLNode commentWithStringValue:@"comment"];
    AJRPrintf(@"comment:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode commentWithStringValue:@"<<com&ment>>"];
    ajrNode = [AJRXMLNode commentWithStringValue:@"<<com&ment>>"];
    AJRPrintf(@"comment:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode processingInstructionWithName:@"name" stringValue:@"string"];
    ajrNode = [AJRXMLNode processingInstructionWithName:@"name" stringValue:@"string"];
    AJRPrintf(@"processing instruction:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode processingInstructionWithName:@"name" stringValue:@"<string>"];
    ajrNode = [AJRXMLNode processingInstructionWithName:@"name" stringValue:@"<string>"];
    AJRPrintf(@"processing instruction:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode textWithStringValue:@"string"];
    ajrNode = [AJRXMLNode textWithStringValue:@"string"];
    AJRPrintf(@"text:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode textWithStringValue:@"<string>"];
    ajrNode = [AJRXMLNode textWithStringValue:@"<string>"];
    AJRPrintf(@"text:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
    
    nsNode = [NSXMLNode attributeWithName:@"name" URI:@"uri" stringValue:@"string"];
    ajrNode = [AJRXMLNode attributeWithName:@"name" URI:@"uri" stringValue:@"string"];
    AJRPrintf(@"attribute w/uri:\n");
    AJRPrintf(@"    %C / %C\n", nsNode, ajrNode);
    AJRPrintf(@"    %@ / %@\n", nsNode, ajrNode);
    XCTAssert(AJREqual([nsNode description], [ajrNode description]), @"%@ != %@", nsNode, ajrNode);
}

- (void)testSettingStringValues {
    NSXMLNode *nsNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
    AJRXMLNode *ajrNode = [[AJRXMLNode alloc] initWithKind:AJRXMLNodeKindText];
    
    NSString *testString = @"string";
    [nsNode setStringValue:testString resolvingEntities:YES];
    [ajrNode setStringValue:testString resolvingEntities:YES];
    AJRPrintf(@"input: %@\n", testString);
    AJRPrintf(@"    nsNode: %@\n", [nsNode stringValue]);
    AJRPrintf(@"    ajrNode: %@\n", [ajrNode stringValue]);
    XCTAssert(AJREqual([nsNode stringValue], [ajrNode stringValue]), @"Nodes weren't equal: %@ vs. %@", [nsNode stringValue], [ajrNode stringValue]);
    
    testString = @"&lt;string&amp;fun&gt;";
    [nsNode setStringValue:testString resolvingEntities:YES];
    [ajrNode setStringValue:testString resolvingEntities:YES];
    AJRPrintf(@"input: %@\n", testString);
    AJRPrintf(@"    nsNode: %@\n", [nsNode stringValue]);
    AJRPrintf(@"    ajrNode: %@\n", [ajrNode stringValue]);
    XCTAssert(AJREqual([nsNode stringValue], [ajrNode stringValue]), @"Nodes weren't equal: %@ vs. %@", [nsNode stringValue], [ajrNode stringValue]);

    testString = @"testing lots: &lt;, &gt;, &amp;, &quot;, &apos;, &#65;, &#x41;, and &bad;, and that's it.";
    [nsNode setStringValue:testString resolvingEntities:YES];
    [ajrNode setStringValue:testString resolvingEntities:YES];
    AJRPrintf(@"input: %@\n", testString);
    AJRPrintf(@"    nsNode: %@\n", [nsNode stringValue]);
    AJRPrintf(@"    ajrNode: %@\n", [ajrNode stringValue]);
    XCTAssert(AJREqual([nsNode stringValue], [ajrNode stringValue]), @"Nodes weren't equal: %@ vs. %@", [nsNode stringValue], [ajrNode stringValue]);

    testString = @"test unterminated &quot and more.";
    [nsNode setStringValue:testString resolvingEntities:YES];
    [ajrNode setStringValue:testString resolvingEntities:YES];
    AJRPrintf(@"input: %@\n", testString);
    AJRPrintf(@"    nsNode: %@\n", [nsNode stringValue]);
    AJRPrintf(@"    ajrNode: %@\n", [ajrNode stringValue]);
    XCTAssert(AJREqual([nsNode stringValue], [ajrNode stringValue]), @"Nodes weren't equal: %@ vs. %@", [nsNode stringValue], [ajrNode stringValue]);

    testString = @"test a unicode 16 '&#xf8ff;' character.";
    [nsNode setStringValue:testString resolvingEntities:YES];
    [ajrNode setStringValue:testString resolvingEntities:YES];
    AJRPrintf(@"input: %@\n", testString);
    AJRPrintf(@"    nsNode: %@\n", [nsNode stringValue]);
    AJRPrintf(@"    ajrNode: %@\n", [ajrNode stringValue]);
    XCTAssert(AJREqual([nsNode stringValue], [ajrNode stringValue]), @"Nodes weren't equal: %@ vs. %@", [nsNode stringValue], [ajrNode stringValue]);

    testString = @"test a unicode 32 '&#x103a0;' character.";
    [nsNode setStringValue:testString resolvingEntities:YES];
    [ajrNode setStringValue:testString resolvingEntities:YES];
    AJRPrintf(@"input: %@\n", testString);
    AJRPrintf(@"    nsNode: %@\n", [nsNode stringValue]);
    AJRPrintf(@"    ajrNode: %@\n", [ajrNode stringValue]);
    XCTAssert(AJREqual([ajrNode stringValue], @"test a unicode 32 '𐎠' character."), @"Values weren't equal: %@ vs. %@", @"test a unicode 32 '𐎠' character.", [ajrNode stringValue]);
    // NSXMLNode doesn't handle UTF-32, and I think it should, so I'm not going to compare against it's value.
    //XCTAssert(AJREqual([nsNode stringValue], [ajrNode stringValue]), @"Nodes weren't equal: %@ vs. %@", [nsNode stringValue], [ajrNode stringValue]);
}

- (void)testNames {
    NSString *name = @"foo";
    XCTAssert(AJREqual([NSXMLNode localNameForName:name], [AJRXMLNode localNameForName:name]), @"%@ wasn't the same as %@", [NSXMLNode localNameForName:name], [AJRXMLNode localNameForName:name]);
    XCTAssert(AJREqual([NSXMLNode prefixForName:name], [AJRXMLNode prefixForName:name]), @"%@ wasn't the same as %@", [NSXMLNode prefixForName:name], [AJRXMLNode prefixForName:name]);
    name = @"foo:bar";
    XCTAssert(AJREqual([NSXMLNode localNameForName:name], [AJRXMLNode localNameForName:name]), @"%@ wasn't the same as %@", [NSXMLNode localNameForName:name], [AJRXMLNode localNameForName:name]);
    XCTAssert(AJREqual([NSXMLNode prefixForName:name], [AJRXMLNode prefixForName:name]), @"%@ wasn't the same as %@", [NSXMLNode prefixForName:name], [AJRXMLNode prefixForName:name]);
    name = @"foo:bar:baz";
    XCTAssert(AJREqual([NSXMLNode localNameForName:name], [AJRXMLNode localNameForName:name]), @"%@ wasn't the same as %@", [NSXMLNode localNameForName:name], [AJRXMLNode localNameForName:name]);
    XCTAssert(AJREqual([NSXMLNode prefixForName:name], [AJRXMLNode prefixForName:name]), @"%@ wasn't the same as %@", [NSXMLNode prefixForName:name], [AJRXMLNode prefixForName:name]);
}

- (void)testNamespaces {
    for (NSString *prefix in @[@"xml", @"xs", @"xsi", @"html"]) {
        NSXMLNode *nsNode = [NSXMLNode predefinedNamespaceForPrefix:prefix];
        AJRXMLNode *ajrNode = [AJRXMLNode predefinedNamespaceForPrefix:prefix];
        AJRPrintf(@"%@:\n", prefix);
        AJRPrintf(@"    nsNode: %@, class: %C, kind: %d, prefix: \"%@\", name: \"%@\", string: \"%@\"\n", nsNode, nsNode, (int)nsNode.kind, nsNode.prefix, nsNode.name, nsNode.stringValue);
        AJRPrintf(@"    ajrNode: %@, class: %C, kind: %d, prefix: \"%@\", name: \"%@\", string: \"%@\"\n", ajrNode, ajrNode, (int)ajrNode.kind, ajrNode.prefix, ajrNode.name, ajrNode.stringValue);
        XCTAssert(AJREqual([nsNode description], [ajrNode description]));
        XCTAssert(AJREqual(@(nsNode.kind), @(ajrNode.kind)));
        XCTAssert(AJREqual(nsNode.prefix, ajrNode.prefix));
        XCTAssert(AJREqual(nsNode.name, ajrNode.name));
        XCTAssert(AJREqual(nsNode.stringValue, ajrNode.stringValue));
    }
}

- (void)testChildren {
    NSXMLNode *nsNode = [[NSXMLNode alloc] initWithKind:NSXMLTextKind];
    AJRXMLNode *ajrNode = [[AJRXMLNode alloc] initWithKind:AJRXMLNodeKindText];
    
    AJRPrintf(@"nsNode: %@\n", [nsNode children]);
    AJRPrintf(@"ajrNode: %@\n", [ajrNode children]);
    XCTAssert(AJREqual([nsNode children], [ajrNode children]));
    
    AJRPrintf(@"nsNode: %@\n", [nsNode childAtIndex:0]);
    AJRPrintf(@"ajrNode: %@\n", [ajrNode childAtIndex:0]);
    XCTAssert(AJREqual([nsNode childAtIndex:0], [ajrNode childAtIndex:0]));
}

- (void)testElementAttributes {
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"foo"];
    [element addAttribute:@"value" forName:@"test"];
    [element addAttribute:@"another value" forName:@"test"];

    AJRPrintf(@"%@\n", element);
}

- (void)testElementNamespaces {
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"foo"];
    [element addAttribute:@"value" forName:@"test"];
    [element addNamespace:[NSXMLNode namespaceWithName:@"pat" stringValue:@"mom"]];
    [element addNamespace:[NSXMLNode namespaceWithName:@"mike" stringValue:@"dad"]];

    AJRPrintf(@"element with namespace: %@\n", element);
}

- (void)testElementTextMerging {
    NSXMLElement *nsElement = [NSXMLNode elementWithName:@"foo" stringValue:@"bar"];
    NSXMLElement *ajrElement = [AJRXMLNode elementWithName:@"foo" stringValue:@"bar"];
    
    [nsElement setAttributesWithDictionary:@{@"a":@"b"}];
    [nsElement addChild:[NSXMLNode textWithStringValue:@"baz"]];
    [nsElement addChild:[NSXMLNode elementWithName:@"bug" stringValue:@"spider"]];
    [(NSXMLElement *)[[nsElement children] lastObject] setAttributesWithDictionary:@{@"c":@"d"}];
    [nsElement addChild:[NSXMLNode textWithStringValue:@"bing"]];
    [nsElement addChild:[NSXMLNode textWithStringValue:@"bong"]];
    [ajrElement setAttributesWithDictionary:@{@"a":@"b"}];
    [ajrElement addChild:[AJRXMLNode textWithStringValue:@"baz"]];
    [ajrElement addChild:[AJRXMLNode elementWithName:@"bug" stringValue:@"spider"]];
    [(AJRXMLElement *)[[ajrElement children] lastObject] setAttributesWithDictionary:@{@"c":@"d"}];
    [ajrElement addChild:[AJRXMLNode textWithStringValue:@"bing"]];
    [ajrElement addChild:[AJRXMLNode textWithStringValue:@"bong"]];
    
    XCTAssert([nsElement childCount] == 5);
    XCTAssert([ajrElement childCount] == 5);

    [nsElement normalizeAdjacentTextNodesPreservingCDATA:YES];
    [ajrElement normalizeAdjacentTextNodesPreservingCDATA:YES];
    
    XCTAssert([nsElement childCount] == 3);
    XCTAssert([ajrElement childCount] == 3);

    AJRPrintf(@"nsElement: %@\n", nsElement);
    AJRPrintf(@"    stringValue: %@\n", [nsElement stringValue]);
    AJRPrintf(@"    tidy:\n%@\n", [nsElement XMLStringWithOptions:NSXMLNodePrettyPrint]);

    AJRPrintf(@"ajrElement: %@\n", ajrElement);
    AJRPrintf(@"    stringValue: %@\n", [ajrElement stringValue]);
    AJRPrintf(@"    tidy:\n%@\n", [ajrElement XMLStringWithOptions:NSXMLNodePrettyPrint]);

    XCTAssert(AJREqual([nsElement stringValue], [ajrElement stringValue]));
    XCTAssert(AJREqual([nsElement XMLStringWithOptions:0], [ajrElement XMLStringWithOptions:0]));
}

- (void)testDTD {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Test DTDs" ofType:nil];
    
    if (path) {
        for (NSURL *URL in [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:0 errorHandler:NULL]) {
            if ([[URL pathExtension] isEqualToString:@"dtd"]) {
                NSError *localError;
                NSXMLDTD *nsDTD = [[NSXMLDTD alloc] initWithContentsOfURL:URL options:NSXMLNodePreserveAll error:&localError];
                
                XCTAssert(nsDTD != nil);
                XCTAssert(localError == nil);
                
                AJRSetGlobalLogLevel(AJRLogLevelDebug);
                
                AJRXMLDTD *ajrDTD = [[AJRXMLDTD alloc] initWithContentsOfURL:URL options:AJRXMLNodePreserveAll error:&localError];
                
                for (NSXMLNode *nsNode in [nsDTD children]) {
                    AJRXMLNode *ajrNode;
                    
                    if ([nsNode kind] == NSXMLElementDeclarationKind) {
                        ajrNode = [ajrDTD elementDeclarationForName:[nsNode name]];
                    } else if ([nsNode kind] == NSXMLEntityDeclarationKind) {
                        ajrNode = [ajrDTD entityDeclarationForName:[nsNode name]];
                    } else if ([nsNode kind] == NSXMLAttributeDeclarationKind) {
                        ajrNode = [ajrDTD attributeDeclarationForName:[nsNode name] elementName:[(NSXMLAttributeDeclaration *)nsNode elementName]];
                    } else if ([nsNode kind] == NSXMLNotationDeclarationKind) {
                        ajrNode = [ajrDTD notationDeclarationForName:[nsNode name]];
                        AJRPrintf(@"Don't handle yet.\n");
                        continue;
                    } else {
                        // We don't care about other types, like whitespace or comments.
                        continue;
                    }
                    XCTAssert([nsNode kind] == (NSXMLNodeKind)[ajrNode kind], @"nsNode: %@ kind: %d, ajrNode: %@ kind: %d", nsNode, (int)[nsNode kind], ajrNode, (int)[ajrNode kind]);
                    XCTAssert([(NSXMLDTDNode *)nsNode DTDKind] == (NSXMLDTDNodeKind)[(AJRXMLDTDNode *)ajrNode DTDKind], @"DTD Kind didn't match: %@: %d, %@: %d", nsNode, (int)[(NSXMLDTDNode *)nsNode DTDKind], ajrNode, (int)[(AJRXMLDTDNode *)ajrNode DTDKind]);
                    XCTAssert(AJREqual([nsNode XMLStringWithOptions:0], [ajrNode XMLStringWithOptions:0]), @"Strings didn't match: nsNode: %@ != ajrNode: %@", [nsNode XMLStringWithOptions:0], [ajrNode XMLStringWithOptions:0]);
                }
                
                AJRPrintf(@"%@\n", [ajrDTD XMLStringWithOptions:0]);
                
                XCTAssert(ajrDTD != nil);
                XCTAssert(localError == nil);
            }
        }
    }
}

- (void)testBasicDocument {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Test XML" ofType:nil];
    
    if (path) {
        for (NSURL *URL in [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:0 errorHandler:NULL]) {
            if ([[URL pathExtension] isEqualToString:@"xml"]) {
                NSError *localError;
                
                AJRPrintf(@"Testing %@...\n", [URL lastPathComponent]);
                //if (![[URL lastPathComponent] isEqualToString:@"icu_parse_test.xml"]) continue;

                NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:URL options:0 error:&localError];
                AJRXMLDocument *ajrDocument = [[AJRXMLDocument alloc] initWithContentsOfURL:URL options:0 error:&localError];

                XCTAssert((document == nil && ajrDocument == nil) || (document != nil && ajrDocument != nil), @"Either both documents must load or both must fail to load, but one succeeded.");

                if (document == nil && ajrDocument == nil) continue;

                // Might seem strange, but at this point, only one document will have failed to load, and we want to know why.
                XCTAssert(document, @"Failed to load document: %@", [localError localizedDescription]);
                XCTAssert(ajrDocument, @"Failed to load document: %@", [localError localizedDescription]);

                [document setStandalone:[ajrDocument isStandalone]];
                
                if ([[URL lastPathComponent] isEqualToString:@"wap.xml"]) {
                    // I'm not particularly fond of how Foundation formats this document, so mine's different. As such, just make sure they loaded.
                    continue;
                }

                if (!AJREqual([document XMLStringWithOptions:NSXMLNodePrettyPrint], [ajrDocument XMLStringWithOptions:AJRXMLNodePrettyPrint])) {
                    AJRPrintf(@"ns:\n%@\n", [document XMLStringWithOptions:NSXMLNodePrettyPrint]);
                    if (document) {
                        [[[document XMLStringWithOptions:NSXMLNodePrettyPrint] dataUsingEncoding:AJRStringEncodingFromIANAName([document characterEncoding])] writeToFile:AJRFormat(@"/tmp/%@.ns.xml", [[URL lastPathComponent] stringByDeletingPathExtension]) atomically:YES];
                    }
                    AJRPrintf(@"ajr:\n%@\n", [ajrDocument XMLStringWithOptions:AJRXMLNodePrettyPrint]);
                    if (ajrDocument) {
                        [[[ajrDocument XMLStringWithOptions:AJRXMLNodePrettyPrint] dataUsingEncoding:AJRStringEncodingFromIANAName([ajrDocument characterEncoding])] writeToFile:AJRFormat(@"/tmp/%@.ajr.xml", [[URL lastPathComponent] stringByDeletingPathExtension]) atomically:YES];
                    }
                } else {
                    [[NSFileManager defaultManager] removeItemAtPath:AJRFormat(@"/tmp/%@.ns.xml", [[URL lastPathComponent] stringByDeletingPathExtension]) error:NULL];
                    [[NSFileManager defaultManager] removeItemAtPath:AJRFormat(@"/tmp/%@.ajr.xml", [[URL lastPathComponent] stringByDeletingPathExtension]) error:NULL];
                }
                XCTAssert(AJREqual([document XMLStringWithOptions:NSXMLNodePrettyPrint], [ajrDocument XMLStringWithOptions:AJRXMLNodePrettyPrint]));
            }
        }
    }
}
*/
@end
