/*
NSBundle+ExtensionsTests.m
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

@interface NSBundle_ExtensionsTests : XCTestCase

@end

@implementation NSBundle_ExtensionsTests

- (void)testFinding {
    NSBundle *bundle;
    
    // Try by a name we're sure we'll find.
    bundle = [NSBundle bundleWithName:@"AJRFoundation"];
    XCTAssert(bundle != nil);
    XCTAssert([bundle.bundleIdentifier isEqualToString:@"com.ajr.framework.AJRFoundation"]);
    
    // Try by it's identifier. This is the fallback case.
    bundle = [NSBundle bundleWithName:@"com.ajr.framework.AJRFoundation"];
    XCTAssert(bundle != nil);

    // Find a resource
    NSString *path = [NSBundle pathForResource:@"AJRSharedStrings" ofType:@"strings"];
    XCTAssert(path != nil);
}

- (void)testMachO {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.ajr.framework.AJRFoundation"];
    NSData *data = [bundle machOTextDataNamed:@"__cstring"];
    
    XCTAssert(data != nil);
    
    data = [bundle machOTextDataNamed:@"__not_found"];
    XCTAssert(data == nil);
    
    bundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/Tcl.framework"];
    XCTAssert(bundle != nil);
    XCTAssert(!bundle.isLoaded);
    data = [bundle machODataOfType:@"__TEXT" named:@"__text"];
    XCTAssert(data != nil);
    
    // Final error case, which is a bundle with no executable.
    bundle = [NSBundle bundleWithPath:@"/System/Library/LinguisticData/RequiredAssets_en.bundle"];
    XCTAssert(bundle != nil);
    XCTAssert(!bundle.isLoaded);
    data = [bundle machODataOfType:@"__TEXT" named:@"__text"];
    XCTAssert(data == nil);
}

@end
