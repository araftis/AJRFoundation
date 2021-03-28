/*
AJRPlugInManagerTests.m
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

@interface AJRPlugInManagerTest : XCTestCase

@end

@implementation AJRPlugInManagerTest

- (void)setUp {
    [super setUp];
    [AJRPlugInManager initializePlugInManager];
}

- (void)testAccessingBasicBundles {
    AJRPlugInManager *plugInManager = [AJRPlugInManager sharedPlugInManager];
    
    XCTAssert(plugInManager != nil);
    
    AJRPlugInExtensionPoint *extensionPoint = [plugInManager extensionPointForName:@"ajrconstant"];
    XCTAssert(extensionPoint != nil);
    XCTAssert([[extensionPoint extensions] count] != 0); // Because we know we should have some constants.
    XCTAssert([extensionPoint extensionForName:@"AJRPIConstant"]);
}

- (BOOL)array:(NSMutableArray<NSString *> *)warnings hasWarningWithText:(NSString *)text {
    for (NSInteger x = 0; x < [warnings count]; x++) {
        NSString *warning = [warnings objectAtIndex:x];
        if ([warning rangeOfString:text].location != NSNotFound) {
            [warnings removeObjectAtIndex:x];
            return YES;
        }
    }
    return NO;
}

- (void)testBundleLoading {
    // We're going to redirect the warning log to a memory stream, so that we can examine it as see if we generate the appropriate warnings.
    NSOutputStream *warningStream = [NSOutputStream outputStreamToMemory];
    NSOutputStream *infoStream = [NSOutputStream outputStreamToMemory];
    NSOutputStream *errorStream = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(infoStream, AJRLogLevelInfo);
    AJRLogSetOutputStream(warningStream, AJRLogLevelWarning);
    AJRLogSetOutputStream(errorStream, AJRLogLevelError);

    // Load our bundle.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"AJRPlugInManagerTestBundle" withExtension:@"bundle"];
    XCTAssert(URL != nil, @"Hum, didn't find our test bundle: AJRPlugInManagerTestBundle.bundle");
    NSBundle *testBundle = [NSBundle bundleWithURL:URL];
    [testBundle load];
    
    // Get the warning stream
    NSMutableArray<NSString *> *warnings = [[[warningStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"] mutableCopy];
    NSMutableArray<NSString *> *infos = [[[infoStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"] mutableCopy];
    NSMutableArray<NSString *> *errors = [[[errorStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"] mutableCopy];
    XCTAssert([self array:infos hasWarningWithText:@"AJRPlugInManagerTestBundle loaded"], @"Apparently, our bundle didn't load.");
    XCTAssert([self array:warnings hasWarningWithText:@"There's already an extension-point named \"ajr_duplicated\" registered with the plug-in manager."]);
    XCTAssert([self array:warnings hasWarningWithText:@"Couldn't find class named \"AJRThisClassDoesntExist\" for extension-point \"ajr_non_existant_class\"."]);
    XCTAssert(![self array:warnings hasWarningWithText:@"Couldn't find class named \"AJRGoodClassWithSelector\" for extension-point \"ajr_good_test_with_class_with_selector\"."]);
    XCTAssert([self array:warnings hasWarningWithText:@"Asked to produce a value for an unknown type: bifrost, returning \"mjolnir\" as string."]);
    XCTAssert([self array:warnings hasWarningWithText:@"Missing \"name\" for attribute in extension-point \"ajr_bad_attributes\""]);
    // Note: We expect this one twice.
    XCTAssert([self array:warnings hasWarningWithText:@"Missing \"type\" for attribute in extension-point \"ajr_bad_attributes\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Missing \"type\" for attribute in extension-point \"ajr_bad_attributes\""]);
    // Note: We expect this one twice.
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to create attribute on extension-point \"ajr_bad_attributes\": "]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to create attribute on extension-point \"ajr_bad_attributes\": "]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to find class: \"AJRNotAnObjectClass\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"No \"name\" attribute specified for node: <element></element>"]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to create element on extension-point \"ajr_good_test_with_class_sans_selector_with_fails\": <element></element>"]);
    XCTAssert([self array:warnings hasWarningWithText:@"Elements of type \"array\" should also define the \"plural\" key: <element name=\"test-set\" type=\"set\"><attribute name=\"test-string\" type=\"string\"></attribute></element>"]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to create element on extension-point \"ajr_good_test_with_class_sans_selector_with_fails\": <element name=\"test-set\" type=\"set\"><attribute name=\"test-string\" type=\"string\"></attribute></element>"]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unknown child in extension-point definition: ajr_good_test_with_class_sans_selector_with_fails: scoobie"]);
    XCTAssert([self array:warnings hasWarningWithText:@"No name property defined for extension-point in node: <extension-point></extension-point>"]);
    XCTAssert([self array:warnings hasWarningWithText:@"Extension Point \"point-with-registry-no-class\" has a registrySelector @selector(registerSomethingUseful:), but no class defined."]);
    XCTAssert([self array:warnings hasWarningWithText:@"Missing required attribute \"testRequired\" in: <ajr_good_test_sans_class name=\"ajr_extension_good_but_missing\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unknown element \"test-undefined-element\" on: <ajr_good_test_sans_class name=\"ajr_extension_good_but_missing\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Missing required element \"test-child\" in: <ajr_good_test_sans_class name=\"ajr_extension_good_but_missing\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unknown attribute \"unknown-attribute-name\" on: <ajr_good_test_sans_class name=\"ajr_extension_good_but_missing\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Couldn't find class named \"AJRBadClass\" for extension-point \"ajr_bad_class\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to find class \"_BAD_CLASS_\" specified by extension:"]);
    XCTAssert([self array:warnings hasWarningWithText:@"All extensions must define a name or a class, this node didn't: <ajr_good_test_with_class_sans_selector class=\"_BAD_CLASS_\""]);
    XCTAssert([self array:warnings hasWarningWithText:@"Unable to find class: \"_BAD_CLASS_\""]);

    XCTAssert([self array:errors hasWarningWithText:@"Unable to load plug-in data: AJRPlugInManagerTestBundleWithError.ajrplugindata"]);

    XCTAssert([errors count] == 1, @"We generated errors we didn't expect:\n%@", errors);
    XCTAssert([warnings count] == 1, @"We generated warnings we didn't expect:\n%@", warnings);
    XCTAssert([infos count] == 1, @"We generated infos we didn't expect:\n%@", infos);

    // And reset the warning stream, because as a unit test, we should avoid side effects.
    AJRLogSetOutputStream(nil, AJRLogLevelInfo);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    AJRLogSetOutputStream(nil, AJRLogLevelError);

    NSException *exception;
    id extensionPoint = [[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajr_good_test_sans_class"];
    XCTAssert(extensionPoint != nil, @"Didn't find expected extension point: ajr_good_test_sans_class");
    XCTAssert([extensionPoint extensionPointClass] == Nil);
    id extension = [extensionPoint extensionForName:@"ajr_extension_good"];
    XCTAssert(extension);
    XCTAssert(AJREqual([extension valueForKey:@"testString"], @"string"));
    XCTAssert([[extension valueForKey:@"properties"] count] > 0);
    @try {
        [extension valueForKey:@"nonexistantProperty"];
    } @catch (NSException *localException) {
        exception = localException;
    }
    XCTAssert(exception != nil);
    exception = nil;
    XCTAssert(AJREqual([extension valueForKey:@"testInteger"], @(1)), @"Expected 1, got %@", [extension valueForKey:@"testInteger"]);
    XCTAssert(AJREqual([extension valueForKey:@"testFloat"], @(3.14159)), @"Expected 3.14159, got %@", [extension valueForKey:@"testFloat"]);
    XCTAssert(AJREqual([extension valueForKey:@"testBOOL"], @YES), @"Expected YES, got %@", [extension valueForKey:@"testBOOL"]);
    XCTAssert(AJREqual([extension valueForKey:@"testRequired"], @"required"), @"Expected \"required\", got \"%@\"", [extension valueForKey:@"testRequired"]);
    XCTAssert(AJREqual([extension valueForKey:@"testRequiredWithDefault"], @"default"), @"Expected \"default\", got \"%@\"", [extension valueForKey:@"testRequiredWithDefault"]);
    XCTAssert([[extension valueForKey:@"testArray"] count] == 4, @"Expected 4 objects in testArray, got %d", (int)[extension valueForKey:@"test-array"]);
    NSBundle *referencedBundle = [extension valueForKey:@"test-bundle"];
    XCTAssert([[referencedBundle bundleIdentifier] isEqualToString:@"com.apple.Foundation"]);

    extensionPoint = [[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajr_late_defined_extension"];
    XCTAssert(extensionPoint != nil, @"Didn't find expected extension point: ajr_late_defined_extension");
    extension = [extensionPoint extensionForName:@"late"];
    XCTAssert(extension);
    XCTAssert([[extension valueForKey:@"test-string"] isEqualToString:@"We loaded!"]);
    
    extension = [AJRPlugInManager.sharedPlugInManager extensionPointForClass:NSClassFromString(@"AJRGoodClass")];
    XCTAssert(extension != nil);
}

- (void)testDebugStuff {
    // This just makes a few calls to make sure we're actually getting 100% coverage, but is called on code that's only used as part of debugging.
    AJRPlugInExtensionPoint *extensionPoint = [[AJRPlugInManager sharedPlugInManager] extensionPointForName:@"ajrconstant"];
    AJRPlugInExtension *extension = [extensionPoint extensionForName:@"AJRPIConstant"];
    AJRPrintf(@"extension: %@\n", extension);
    AJRPrintf(@"   attributes: %@\n", [extensionPoint attributes]);
    AJRPrintf(@"   elements: %@\n", [extensionPoint elements]);
}

@end
