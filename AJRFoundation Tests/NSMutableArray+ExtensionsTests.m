/*
 NSMutableArray+ExtensionsTests.m
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

@interface NSMutableArray_ExtensionsTests : XCTestCase

@end

@implementation NSMutableArray_ExtensionsTests

- (void)testInsertions {
    NSMutableArray<NSNumber *> *array = [NSMutableArray arrayWithObjects:@(1), @(5), @(10), nil];
    
    XCTAssert([array addObjectIfNotNil:@(15)]);
    XCTAssert(array.count == 4);
    XCTAssert(![array addObjectIfNotNil:nil]);
    
    XCTAssert([array addSortedObject:@(3)] == 1);
    
    XCTAssert([array insertObjectIfNotNil:@(7) atIndex:3]);
    XCTAssert(![array insertObjectIfNotNil:nil atIndex:3]);
    
    [array addObject:@(20) atIndex:10];
    XCTAssert(array.count == 11);
    
    [array removeObjectsPassingTest:^BOOL(id  _Nonnull object) {
        return [object isKindOfClass:[NSNull class]];
    }];
    XCTAssert(array.count == 7);
    
    [array moveObjectAtIndex:0 toIndex:4];
    XCTAssert(array[0].integerValue == 3);
    XCTAssert(array[1].integerValue == 5);
    XCTAssert(array[2].integerValue == 7);
    XCTAssert(array[3].integerValue == 1);
    XCTAssert(array[4].integerValue == 10);
    XCTAssert(array[5].integerValue == 15);
    XCTAssert(array[6].integerValue == 20);
    
    [array moveObjectAtIndex:3 toIndex:0];
    XCTAssert(array[0].integerValue == 1);
    XCTAssert(array[1].integerValue == 3);
    XCTAssert(array[2].integerValue == 5);
    XCTAssert(array[3].integerValue == 7);
    XCTAssert(array[4].integerValue == 10);
    XCTAssert(array[5].integerValue == 15);
    XCTAssert(array[6].integerValue == 20);
    
    [array addObject:@(1)];
    [array removeFirstObjectPassingTest:^BOOL(NSNumber * _Nonnull object) {
        return object.integerValue == 1;
    }];
    XCTAssert(array[0].integerValue == 3);
    XCTAssert(array[1].integerValue == 5);
    XCTAssert(array[2].integerValue == 7);
    XCTAssert(array[3].integerValue == 10);
    XCTAssert(array[4].integerValue == 15);
    XCTAssert(array[5].integerValue == 20);
    XCTAssert(array[6].integerValue == 1);
    
    [array moveObjectAtIndex:6 toIndex:0];
    [array insertObjects:@[@(16), @(17)] atIndex:6];
    XCTAssert(array[0].integerValue == 1);
    XCTAssert(array[1].integerValue == 3);
    XCTAssert(array[2].integerValue == 5);
    XCTAssert(array[3].integerValue == 7);
    XCTAssert(array[4].integerValue == 10);
    XCTAssert(array[5].integerValue == 15);
    XCTAssert(array[6].integerValue == 16);
    XCTAssert(array[7].integerValue == 17);
    XCTAssert(array[8].integerValue == 20);
    
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(stream, AJRLogLevelWarning);
    @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        [array insertObject:nil atIndex:0];
#pragma clang diagnostic pop
    } @catch (NSException *localException) {
    }
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    
    XCTAssert([[stream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] hasPrefix:@"<WARNING>: Attempt to insert nil object into array. Break on _AJRInsertNilObjectAtIndex() to debug."]);
}

@end
