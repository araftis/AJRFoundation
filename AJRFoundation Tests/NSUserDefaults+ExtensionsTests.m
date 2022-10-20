/*
NSUserDefaults+ExtensionsTests.m
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

@interface NSUserDefaults_ExtensionsTests : XCTestCase

@end

@implementation NSUserDefaults_ExtensionsTests

- (void)testUnits {
    NSSet<NSString *> *all = [NSUnit unitIdentifiers];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    
    NSInteger index = 0;
    for (NSString *identifier in all) {
        NSUnit *unit = [NSUnit unitForIdentifier:identifier];
        XCTAssert(unit != nil);
        
        [defaults setUnits:unit forKey:[@(index + 1) description]];

        index += 1;
    }
    
    NSInteger max = index;
    index = 0;
    for (index = 0; index < max; index++) {
        NSUnit *unit = [defaults unitsForKey:[@(index + 1) description] defaultValue:nil];
        XCTAssert(unit != nil);
        index++;
    }
}

- (void)testClasses {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    
    [defaults setClass:[NSString class] forKey:@"test1"];
    XCTAssert([defaults classForKey:@"test1" defaultValue:Nil] != Nil);
    XCTAssert([defaults classForKey:@"test2" defaultValue:NSNumber.class] == NSNumber.class);
    [defaults setObject:@"THIS_ISNT_A_VALID_CLASS" forKey:@"test2"];
    XCTAssert([defaults classForKey:@"test2" defaultValue:NSNumber.class] == NSNumber.class);
    
    [defaults setClass:Nil forKey:@"test1"];
    [defaults setClass:Nil forKey:@"test2"];
}

@end
