/*
NSObject+AJRUserInfoTests.m
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

@interface NSObject_AJRUserInfoTests : XCTestCase

@end

@implementation NSObject_AJRUserInfoTests

- (void)testObject {
    NSObject *object = [[NSObject alloc] init];
    
    [object setInstanceObject:@(1) forKey:@"one"];
    [object setInstanceObject:@(2) forKey:@"two"];
    [[NSObject class] setClassObject:@"uno" forKey:@"one"];
    [[NSObject class] setClassObject:@"dos" forKey:@"two"];
    XCTAssert([[object instanceObjectForKey:@"one"] isEqualToNumber:@(1)]);
    XCTAssert([[object instanceObjectForKey:@"two"] isEqualToNumber:@(2)]);
    XCTAssert([[[NSObject class] classObjectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[[NSObject class] classObjectForKey:@"two"] isEqualToString:@"dos"]);
    [object setInstanceObject:nil forKey:@"two"];
    [[NSObject class] setClassObject:nil forKey:@"two"];
    XCTAssert([[object instanceObjectForKey:@"one"] isEqualToNumber:@(1)]);
    XCTAssert([object instanceObjectForKey:@"two"] == nil);
    XCTAssert([[[NSObject class] classObjectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[NSObject class] classObjectForKey:@"two"] == nil);
    [object clearInstanceObjects];
    XCTAssert([object instanceObjectForKey:@"one"] == nil);
    XCTAssert([object instanceObjectForKey:@"two"] == nil);
    XCTAssert([[[NSObject class] classObjectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[NSObject class] classObjectForKey:@"two"] == nil);
    [[NSObject class] clearClassObjects];
    XCTAssert([[NSObject class] classObjectForKey:@"one"] == nil);
    XCTAssert([[NSObject class] classObjectForKey:@"two"] == nil);
}

@end
