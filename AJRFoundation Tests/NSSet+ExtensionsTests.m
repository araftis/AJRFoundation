/*
 NSSet+ExtensionsTests.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import "AJRSimpleTestClass.h"

@interface NSSet_ExtensionsTests : XCTestCase

@end

@implementation NSSet_ExtensionsTests

- (void)testCreations {
    NSSet *set = [NSSet setWithCollection:@[@"one", @"two", @"three"]];
    
    XCTAssert([set containsObject:@"one"]);
    XCTAssert([set containsObject:@"two"]);
    XCTAssert([set containsObject:@"three"]);
}

// Might move this into an XML coding unit test.
- (void)testXMLCoding {
    NSError *localError;
    
    // Case one: array with codeable objects
    NSData *data;
    id one = [AJRSimpleTestClass objectWithStringValue:@"One"];
    id two = [AJRSimpleTestClass objectWithStringValue:@"Two"];
    id three = [AJRSimpleTestClass objectWithStringValue:@"Three"];
    NSSet *original = [NSSet setWithArray:@[one, two, three, one]];
    
    data = [AJRXMLArchiver archivedDataWithRootObject:original forKey:@"array"];
    XCTAssert(data != nil);

    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSSet *decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    
    // Case two: array with strings
    one = @"One";
    two = @"Two";
    three = @"Three";
    original = [NSSet setWithArray:@[one, two, three, one]];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));

    // Case three: array with numbers
    one = @(1);
    two = @(2);
    three = @(3);
    original = [NSSet setWithArray:@[one, two, three, one]];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
}

- (void)testMutableXMLCoding {
    NSError *localError;
    
    // Case one: array with codeable objects
    NSData *data;
    id one = [AJRSimpleTestClass objectWithStringValue:@"One"];
    id two = [AJRSimpleTestClass objectWithStringValue:@"Two"];
    id three = [AJRSimpleTestClass objectWithStringValue:@"Three"];
    NSMutableSet *original = [NSMutableSet setWithArray:@[one, two, three, one]];
    
    data = [AJRXMLArchiver archivedDataWithRootObject:original forKey:@"array"];
    XCTAssert(data != nil);

    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSSet *decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    
    // Case two: array with strings
    one = @"One";
    two = @"Two";
    three = @"Three";
    original = [NSMutableSet setWithArray:@[one, two, three, one]];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));

    // Case three: array with numbers
    one = @(1);
    two = @(2);
    three = @(3);
    original = [NSMutableSet setWithArray:@[one, two, three, one]];

    data = [AJRXMLArchiver archivedDataWithRootObject:original];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(original, decoded));
    
    NSMutableSet *large = [NSMutableSet set];
    for (NSInteger x = 0; x < 1024; x++) {
        [large addObject:@(x)];
    }
    data = [AJRXMLArchiver archivedDataWithRootObject:large];
    AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
    XCTAssert(decoded != nil, @"Error while decoded: %@", localError.localizedDescription);
    XCTAssert(AJREqual(large, decoded));
    
}

- (void)testDebugErrorHandling {
    NSMutableSet *set = [NSMutableSet set];
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    AJRLogSetOutputStream(output, AJRLogLevelWarning);
    [set addObjectsFromArray:@[@"one", @"two", @"three"]];
    XCTAssert([[output ajr_data] length] == 0);
    [set addObjectsFromArray:(id)[NSSet setWithArray:@[@"four", @"five", @"six"]]];
    XCTAssert([[output ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] rangeOfString:@"<WARNING>: Called -[__NSSetM addObjectsFromArray:] with a"].location != NSNotFound);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
}

- (void)testFiltering {
    NSSet<NSNumber *> *test = [NSSet setWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10)]];
    NSMutableSet<NSNumber *> *bigTest;
    NSSet<NSNumber *> *result;
    
    bigTest = [NSMutableSet set];
    for (NSInteger x = 0; x < 200; x++) {
        [bigTest addObject:@(x + 1)];
    }

    // Test Filtering
    result = [test filteredSetUsingBlock:^BOOL(NSNumber *object) {
        return [object integerValue] <= 5;
    }];
    
    XCTAssert(result.count == 5);
    for (NSNumber *number in result) {
        XCTAssert([number integerValue] <= 5);
    }

    result = [bigTest filteredSetUsingBlock:^BOOL(NSNumber *object) {
        return [object integerValue] <= 100;
    }];
    
    XCTAssert(result.count == 100);
    for (NSNumber *number in result) {
        XCTAssert([number integerValue] <= 100);
    }

    // Test Mapping
    result = [test mappedSetUsingBlock:^NSNumber *(NSNumber *object) {
        return @([object integerValue] * 2);
    }];
    
    XCTAssert(result.count == 10);
    for (NSNumber *number in result) {
        // Since the result is unordered, just make sure all values are even.
        XCTAssert(number.integerValue % 2 == 0);
    }

    result = [bigTest mappedSetUsingBlock:^NSNumber *(NSNumber *object) {
        return @([object integerValue] * 2);
    }];
    
    XCTAssert(result.count == 200);
    for (NSNumber *number in result) {
        // Since the result is unordered, just make sure all values are even.
        XCTAssert(number.integerValue % 2 == 0);
    }
    
    // Test Filtering and Mapping
    result = [test filteredAndMappedSetUsingBlock:^id (NSNumber *object) {
        if (object.integerValue <= 5) {
            return @(object.integerValue * 2);
        }
        return nil;
    }];
    
    XCTAssert(result.count == 5);
    for (NSNumber *number in result) {
        XCTAssert(number.integerValue <= 10);
        // Since the result is unordered, just make sure all values are even.
        XCTAssert(number.integerValue % 2 == 0);
    }

    result = [bigTest filteredAndMappedSetUsingBlock:^id (NSNumber *object) {
        if (object.integerValue <= 100) {
            return @(object.integerValue * 2);
        }
        return nil;
    }];
    
    XCTAssert(result.count == 100);
    for (NSNumber *number in result) {
        XCTAssert(number.integerValue <= 200);
        // Since the result is unordered, just make sure all values are even.
        XCTAssert(number.integerValue % 2 == 0);
    }

    test = [NSSet setWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10)]];
    test = [test setByRemovingObjects:[NSSet setWithArray:@[@(1), @(2), @(3)]]];
    XCTAssert(test.count == 7);
    for (NSNumber *number in test) {
        XCTAssert(number.integerValue > 3);
    }
    test = [test setByRemovingObjects:@[@(4), @(5), @(6)]];
    XCTAssert(test.count == 4);
    for (NSNumber *number in test) {
        XCTAssert(number.integerValue > 6);
    }
}

@end
