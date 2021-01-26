//
//  NSPointerArray+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 1/9/20.
//

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
