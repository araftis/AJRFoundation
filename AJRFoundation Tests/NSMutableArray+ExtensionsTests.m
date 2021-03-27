
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
