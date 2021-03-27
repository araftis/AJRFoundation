
#import <XCTest/XCTest.h>
#import <AJRFoundation/AJRFoundation.h>

#import "AJRSimpleTestClass.h"

@interface NSArrayExtensionsTest : XCTestCase

@end

@implementation NSArrayExtensionsTest

- (void)testArraySplitIntoBatchedArray {
    NSArray *testArray = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
    NSArray *batchedArray = [testArray arraySplitIntoBatchedArrayWithItemsPerBatch:2];
    XCTAssertTrue(batchedArray.count == 4, @"error with batched array");
    
    NSArray *testArray2 = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", nil];
    NSArray *batchedArray2 = [testArray2 arraySplitIntoBatchedArrayWithItemsPerBatch:2];
    XCTAssertTrue(batchedArray2.count == 4, @"error with batched array");

    NSArray *testArray3 = [NSArray arrayWithObjects:@"1", nil];
    NSArray *batchedArray3 = [testArray3 arraySplitIntoBatchedArrayWithItemsPerBatch:2];
    XCTAssertTrue(batchedArray3.count == 1, @"error with batched array");
}

- (void)testCreations {
    NSArray *array = [NSArray arrayWithCollection:[NSSet setWithObjects:@"one", @"two", @"three", nil]];
    
    XCTAssert([array containsObject:@"one"]);
    XCTAssert([array containsObject:@"two"]);
    XCTAssert([array containsObject:@"three"]);
    XCTAssert([array containsObjectIdenticalTo:array[0]]);
    XCTAssert([array containsObjectIdenticalTo:array[1]]);
    XCTAssert([array containsObjectIdenticalTo:array[2]]);
}

- (void)testDifferences {
    NSArray *left = @[@"One", @"Two", @"Three"];
    NSArray *right = @[@"Three", @"Four", @"Five"];
    NSArray *expected = @[@"One", @"Two", @"Four", @"Five"];
    NSArray *diff = [left differencesFromArray:right];
    
    XCTAssert([diff isEqualToArray:expected]);
}

// Declared in NSArray+Extensions.m, but not generally public.
extern NSUInteger _ajrBinarySearch(NSArray *array, id key, NSComparator comparator, NSUInteger idxBottom, NSUInteger idxTop, NSUInteger *insertIndex);

- (void)testBinarySearch{
    NSArray *input = @[ @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10)];
    
    XCTAssert([input findIndexOfObject:@(1)] == 0);
    XCTAssert([input findIndexOfObject:@(2)] == 1);
    XCTAssert([input findIndexOfObject:@(3)] == 2);
    XCTAssert([input findIndexOfObject:@(4)] == 3);
    XCTAssert([input findIndexOfObject:@(5)] == 4);
    XCTAssert([input findIndexOfObject:@(6)] == 5);
    XCTAssert([input findIndexOfObject:@(7)] == 6);
    XCTAssert([input findIndexOfObject:@(8)] == 7);
    XCTAssert([input findIndexOfObject:@(9)] == 8);
    XCTAssert([input findIndexOfObject:@(10)] == 9);
    XCTAssert([input findIndexOfObject:@(20)] == NSNotFound);

    // These use the same underlying code as the above, so just make sure the API's working.
    XCTAssert([input findIndexOfObject:@(3) usingComparator:AJRSimpleCompare] == 2);
    
    XCTAssert([@[] findIndexOfObject: @(1)] == NSNotFound);

    NSUInteger insertIndex = NSNotFound;
    XCTAssert(_ajrBinarySearch(input, @(1), AJRSimpleCompare, 0, 0, &insertIndex) == 0);
    XCTAssert(insertIndex == 0);
    XCTAssert(_ajrBinarySearch(input, @(20), AJRSimpleCompare, 0, 0, &insertIndex) == NSNotFound);
    XCTAssert(insertIndex == 0);
}

- (void)testFindInsertionPoint{
    NSArray *input = @[@(2), @(4), @(6), @(8), @(10), @(12), @(14), @(16), @(18), @(20)];

    XCTAssert([input findInsertionIndexForObject:@(1)] == 0);
    XCTAssert([input findInsertionIndexForObject:@(3)] == 1);
    XCTAssert([input findInsertionIndexForObject:@(5)] == 2);
    XCTAssert([input findInsertionIndexForObject:@(7)] == 3);
    XCTAssert([input findInsertionIndexForObject:@(9)] == 4);
    XCTAssert([input findInsertionIndexForObject:@(11)] == 5);
    XCTAssert([input findInsertionIndexForObject:@(13)] == 6);
    XCTAssert([input findInsertionIndexForObject:@(15)] == 7);
    XCTAssert([input findInsertionIndexForObject:@(17)] == 8);
    XCTAssert([input findInsertionIndexForObject:@(19)] == 9);
    XCTAssert([input findInsertionIndexForObject:@(21)] == 10);

    // These use the same underlying code as the above, so just make sure the API's working.
    XCTAssert([input findInsertionIndexForObject:@(9) usingComparator:AJRSimpleCompare] == 4);

    XCTAssert([@[] findInsertionIndexForObject: @(1)] == 0);
    XCTAssert([@[(@1)] findInsertionIndexForObject: @(1)] == 0);
}

- (void)testUniqueObjects {
    NSArray<NSNumber *> *input = @[@(5), @(5), @(4), @(4), @(3), @(3), @(2), @(2), @(1), @(1)];
    NSSet<NSNumber *> *unique = [input ajr_uniqueObjects];
    NSArray<NSNumber *> *orderedUnique = [input ajr_orderedUniqueObjects];

    XCTAssert(unique.count == 5);
    XCTAssert([unique containsObject:@(1)]);
    XCTAssert([unique containsObject:@(2)]);
    XCTAssert([unique containsObject:@(3)]);
    XCTAssert([unique containsObject:@(4)]);
    XCTAssert([unique containsObject:@(5)]);

    XCTAssert([orderedUnique indexOfObject:@(1)] == 4);
    XCTAssert([orderedUnique indexOfObject:@(2)] == 3);
    XCTAssert([orderedUnique indexOfObject:@(3)] == 2);
    XCTAssert([orderedUnique indexOfObject:@(4)] == 1);
    XCTAssert([orderedUnique indexOfObject:@(5)] == 0);
}

- (void)testPropertyListCoding {
    NSArray *original = @[[AJRSimpleTestClass objectWithStringValue:@"One"], [AJRSimpleTestClass objectWithStringValue:@"Two"]];
    NSArray *decoded = nil;
    NSArray *propertyListValue = [original propertyListValue];
    
    decoded = [NSArray createFromPropertyList:propertyListValue class:[AJRSimpleTestClass class] error:nil];
    
    XCTAssert([original isEqualToArray:decoded]);

    NSError *localError = nil;
    original = @[[AJRSimpleTestClass objectWithStringValue:@"One"], [AJRSimpleTestClass objectWithStringValue:@"Two"], [AJRSimpleTestClass objectWithStringValue:@"Three"]];
    propertyListValue = [original propertyListValue];
    decoded = [NSArray createFromPropertyList:propertyListValue class:[AJRSimpleTestClass class] error:&localError];
    XCTAssert(decoded == nil);
    XCTAssert(localError != nil);
    
    localError = nil;
    decoded = [NSArray createFromPropertyList:propertyListValue class:[NSObject class] error:&localError];
    XCTAssert(decoded == nil);
    XCTAssert(localError != nil);
}

// Might move this into an XML coding unit test.
- (void)testXMLCoding {
    NSError *localError;
    
    // Case one: array with codeable objects
    NSData *data;
    id one = [AJRSimpleTestClass objectWithStringValue:@"One"];
    id two = [AJRSimpleTestClass objectWithStringValue:@"Two"];
    id three = [AJRSimpleTestClass objectWithStringValue:@"Three"];
    NSArray *original = @[one, two, three, one];
    
    data = [AJRXMLArchiver archivedDataWithRootObject:original forKey:@"array"];
    XCTAssert(data != nil);

    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSArray *decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    XCTAssert(decoded[0] == decoded[3]);
    
    // Case two: array with strings
    one = @"One";
    two = @"Two";
    three = @"Three";
    original = @[one, two, three, one];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    XCTAssert(decoded[0] == decoded[3]);

    // Case three: array with numbers
    one = @(1);
    two = @(2);
    three = @(3);
    original = @[one, two, three, one];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    XCTAssert(decoded[0] == decoded[3]);
}

- (void)testMutableXMLCoding {
    NSError *localError;
    
    // Case one: array with codeable objects
    NSData *data;
    id one = [AJRSimpleTestClass objectWithStringValue:@"One"];
    id two = [AJRSimpleTestClass objectWithStringValue:@"Two"];
    id three = [AJRSimpleTestClass objectWithStringValue:@"Three"];
    NSMutableArray *original = [@[one, two, three, one] mutableCopy];
    
    data = [AJRXMLArchiver archivedDataWithRootObject:original forKey:@"array"];
    XCTAssert(data != nil);

    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSArray *decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    XCTAssert(decoded[0] == decoded[3]);
    
    // Case two: array with strings
    one = @"One";
    two = @"Two";
    three = @"Three";
    original = [@[one, two, three, one] mutableCopy];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    XCTAssert(decoded[0] == decoded[3]);

    // Case three: array with numbers
    one = @(1);
    two = @(2);
    three = @(3);
    original = [@[one, two, three, one] mutableCopy];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    XCTAssert(decoded[0] == decoded[3]);
    
    NSMutableArray *large = [NSMutableArray array];
    for (NSInteger x = 0; x < 1024; x++) {
        [large addObject:@(x)];
    }
    data = [AJRXMLArchiver archivedDataWithRootObject:large];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(large, decoded));
    
}

- (void)testJoingingArrays {
    NSArray<NSString *> *test = @[@"One"];
    
    XCTAssert([[test componentsJoinedByString:@", " twoValueSeparator:@" and " finalSeparator:@", and "] isEqualToString:@"One"]);
    
    test = @[@"One", @"Two"];
    XCTAssert([[test componentsJoinedByString:@", " twoValueSeparator:@" and " finalSeparator:@", and "] isEqualToString:@"One and Two"]);
    
    test = @[@"One", @"Two", @"Three"];
    XCTAssert([[test componentsJoinedByString:@", " twoValueSeparator:@" and " finalSeparator:@", and "] isEqualToString:@"One, Two, and Three"]);
}

- (void)testPerformSelectors {
    NSArray *array = @[[AJRSimpleTestClass objectWithStringValue:@"One"], [AJRSimpleTestClass objectWithStringValue:@"Two"]];

    // Basic case.
    [array makeObjectsPerformSelectorIfImplemented:@selector(setStringValue:) withObject:@"Three"];
    XCTAssert([[array[0] stringValue] isEqualToString:@"Three"]);
    XCTAssert([[array[1] stringValue] isEqualToString:@"Three"]);

    // Shouldn't crash.
    [array makeObjectsPerformSelectorIfImplemented:@selector(setArgument:atIndex:) withObject:@"Three"];

    // Try a mixed case, where some of the objects won't implement the selector.
    array = @[[AJRSimpleTestClass objectWithStringValue:@"One"], [AJRSimpleTestClass objectWithStringValue:@"Two"], @"Three"];
    
    [array makeObjectsPerformSelectorIfImplemented:@selector(setStringValue:) withObject:@"Three"];
    XCTAssert([[array[0] stringValue] isEqualToString:@"Three"]);
    XCTAssert([[array[1] stringValue] isEqualToString:@"Three"]);
    XCTAssert([array[2] isEqualToString:@"Three"]);

    // Try the two parameter case.
    array = @[[AJRSimpleTestClass objectWithStringValue:@"One"], [AJRSimpleTestClass objectWithStringValue:@"Two"]];

    [array makeObjectsPerformSelectorIfImplemented:@selector(setStringByConcatenating:with:) withObject:@"Three" withObject:@"Four"];
    XCTAssert([[array[0] stringValue] isEqualToString:@"ThreeFour"]);
    XCTAssert([[array[1] stringValue] isEqualToString:@"ThreeFour"]);
    
    // Try the integer case.
    array = @[[AJRSimpleTestClass objectWithIntegerValue:1], [AJRSimpleTestClass objectWithIntegerValue:2]];

    [array makeObjectsSetIntegerValue:3 withSelector:@selector(setIntegerValue:)];
    XCTAssert([array[0] integerValue] == 3);
    XCTAssert([array[1] integerValue] == 3);
    
    // Try the float case.
    array = @[[AJRSimpleTestClass objectWithFloatValue:1.0], [AJRSimpleTestClass objectWithFloatValue:1.0]];

    [array makeObjectsSetFloatValue:3.0 withSelector:@selector(setFloatValue:)];
    XCTAssert([array[0] floatValue] == 3.0);
    XCTAssert([array[1] floatValue] == 3.0);
    
    // Try the double case.
    array = @[[AJRSimpleTestClass objectWithDoubleValue:1.0], [AJRSimpleTestClass objectWithDoubleValue:1.0]];

    [array makeObjectsSetDoubleValue:3.0 withSelector:@selector(setDoubleValue:)];
    XCTAssert([array[0] doubleValue] == 3.0);
    XCTAssert([array[1] doubleValue] == 3.0);
    
    // Try the bool case.
    array = @[[AJRSimpleTestClass objectWithBOOLValue:NO], [AJRSimpleTestClass objectWithBOOLValue:NO]];

    [array makeObjectsSetBOOLValue:YES withSelector:@selector(setBoolValue:)];
    XCTAssert([array[0] boolValue] == YES);
    XCTAssert([array[1] boolValue] == YES);
    
    // Finally, thy the message signature case...
    BOOL newValue = NO;
    NSMethodSignature *signature = [array[0] methodSignatureForSelector:@selector(setBoolValue:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:@selector(setBoolValue:)];
    [invocation setArgument:&newValue atIndex:2];
    [array makeObjectsPerformInvocation:invocation];
    XCTAssert([array[0] boolValue] == NO);
    XCTAssert([array[1] boolValue] == NO);
}

- (void)testFiltering {
    NSArray<NSNumber *> *test = @[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10)];
    NSMutableArray<NSNumber *> *bigTest;
    NSArray<NSNumber *> *result;
    
    bigTest = [NSMutableArray array];
    for (NSInteger x = 0; x < 200; x++) {
        [bigTest addObject:@(x + 1)];
    }

    // Test Filtering
    result = [test filteredArrayUsingBlock:^BOOL(NSNumber *object) {
        return [object integerValue] <= 5;
    }];
    
    XCTAssert(result.count == 5);
    for (NSNumber *number in result) {
        XCTAssert([number integerValue] <= 5);
    }

    result = [bigTest filteredArrayUsingBlock:^BOOL(NSNumber *object) {
        return [object integerValue] <= 100;
    }];
    
    XCTAssert(result.count == 100);
    for (NSNumber *number in result) {
        XCTAssert([number integerValue] <= 100);
    }

    // Test Mapping
    result = [test mappedArrayUsingBlock:^NSNumber *(NSNumber *object) {
        return @([object integerValue] * 2);
    }];
    
    XCTAssert(result.count == 10);
    for (NSInteger x = 0; x < test.count; x++) {
        XCTAssert(test[x].integerValue * 2 == result[x].integerValue);
    }

    result = [bigTest mappedArrayUsingBlock:^NSNumber *(NSNumber *object) {
        return @([object integerValue] * 2);
    }];
    
    XCTAssert(result.count == 200);
    for (NSInteger x = 0; x < bigTest.count; x++) {
        XCTAssert(bigTest[x].integerValue * 2 == result[x].integerValue);
    }
    
    // Test Filtering and Mapping
    result = [test filteredAndMappedArrayUsingBlock:^id (NSNumber *object) {
        if (object.integerValue <= 5) {
            return @(object.integerValue * 2);
        }
        return nil;
    }];
    
    XCTAssert(result.count == 5);
    for (NSInteger x = 0; x < result.count; x++) {
        XCTAssert(result[x].integerValue <= 10);
        XCTAssert(test[x].integerValue * 2 == result[x].integerValue);
    }

    result = [bigTest filteredAndMappedArrayUsingBlock:^id (NSNumber *object) {
        if (object.integerValue <= 100) {
            return @(object.integerValue * 2);
        }
        return nil;
    }];
    
    XCTAssert(result.count == 100);
    for (NSInteger x = 0; x < result.count; x++) {
        XCTAssert(result[x].integerValue <= 200);
        XCTAssert(bigTest[x].integerValue * 2 == result[x].integerValue);
    }

}

- (void)testFinding {
    NSArray *test = @[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    
    id found = [test ajr_firstObjectPassingTest:^BOOL(id object) {
        return [object integerValue] == 3;
    }];
    XCTAssert([found isKindOfClass:[NSNumber class]]);
    XCTAssert([found integerValue] == 3);

    found = [test ajr_lastObjectPassingTest:^BOOL(id object) {
        return [object integerValue] == 3;
    }];
    XCTAssert([found isKindOfClass:[NSString class]]);
    XCTAssert([found integerValue] == 3);
}

- (void)testCopying {
    NSArray<NSString *> *test = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten"];
    NSArray<NSMutableString *> *mutableCopy;
    NSArray<NSString *> *copy;
    
    mutableCopy = [test mutableDeepCopy];
    XCTAssert([test isEqualToArray:mutableCopy]);
    for (NSInteger x = 0; x < test.count; x++) {
        XCTAssert(test[x] != mutableCopy[x]);
        @try {
            [mutableCopy[x] appendString:@"Test"];
        } @catch (NSException *localException) {
            XCTAssert(NO, @"We shouldn't have caught: %@\n", localException);
        }
    }

    copy = [mutableCopy deepCopy];
    XCTAssert([(id)mutableCopy isEqualToArray:(id)copy]);
    for (NSInteger x = 0; x < test.count; x++) {
        XCTAssert(test[x] != mutableCopy[x]);
    }
    
    // Test objects that aren't copyable.
    NSArray *test2 = @[[[NSObject alloc] init], [[NSObject alloc] init], [[NSObject alloc] init], [[NSObject alloc] init], [[NSObject alloc] init]];
    NSArray *copy2;
    
    copy2 = [test2 deepCopy];
    XCTAssert(copy2.count == test2.count);
    for (NSInteger x = 0; x < test2.count; x++) {
        XCTAssert(test2[x] == copy2[x]);
    }
    
    // Test copyable, but not mutable copyable.
    NSArray *test3 = @[[AJRSimpleTestClass objectWithStringValue:@"One"], [AJRSimpleTestClass objectWithStringValue:@"Two"], [[NSObject alloc] init]];
    NSArray *copy3;
    
    copy3 = [test3 mutableDeepCopy];
    XCTAssert([test3 isEqualToArray:copy3]);
    for (NSInteger x = 0; x < test.count; x++) {
        XCTAssert(test[x] != mutableCopy[x]);
    }
}

@end
