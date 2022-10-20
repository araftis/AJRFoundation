/*
NSPointerArray+ExtensionsTests.m
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

@interface NSPointerArray_ExtensionsTests : XCTestCase

@end

@implementation NSPointerArray_ExtensionsTests

- (void)testBasic {
    NSPointerArray *array = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsStrongMemory];
    
    id object1 = [[NSObject alloc] init];
    id object2 = [[NSObject alloc] init];
    
    [array addObject:object1];
    [array addObject:object2];
    
    __block id foundObject = nil;
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        if (object == object2) {
            foundObject = object;
            *stop = YES;
        }
    }];
    XCTAssert(foundObject == object2);
    
    XCTAssert([array indexOfObject:object1] == 0);
    XCTAssert([array indexOfObject:object2] == 1);
    XCTAssert([array indexOfObjectIdenticalTo:object1] == 0);
    XCTAssert([array indexOfObjectIdenticalTo:object2] == 1);
    
    [array removeObject:object1];
    XCTAssert([array indexOfObject:object1] == NSNotFound);
    XCTAssert([array indexOfObject:object2] == 0);
    XCTAssert([array indexOfObjectIdenticalTo:object1] == NSNotFound);
    XCTAssert([array indexOfObjectIdenticalTo:object2] == 0);
    
    [array removeObjectIdenticalTo:object2];
    XCTAssert([array indexOfObject:object1] == NSNotFound);
    XCTAssert([array indexOfObject:object2] == NSNotFound);
    XCTAssert([array indexOfObjectIdenticalTo:object1] == NSNotFound);
    XCTAssert([array indexOfObjectIdenticalTo:object2] == NSNotFound);
}

@end
