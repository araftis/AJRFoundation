/*
 NSMutableDictionary+ExtensionsTests.m
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

@interface NSMutableDictionary_ExtensionsTests : XCTestCase

@end

@implementation NSMutableDictionary_ExtensionsTests

- (void)testTypeSetters {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setBool:YES forKey:@"yes"];
    [dictionary setBool:NO forKey:@"no"];
    [dictionary setInt:1 forKey:@"int"];
    [dictionary setUnsignedInt:2 forKey:@"unsignedInt"];
    [dictionary setInteger:3 forKey:@"integer"];
    [dictionary setUnsignedInteger:4 forKey:@"unsignedInteger"];
    [dictionary setChar:5 forKey:@"char"];
    [dictionary setUnsignedChar:6 forKey:@"unsignedChar"];
    [dictionary setShort:7 forKey:@"short"];
    [dictionary setUnsignedShort:8 forKey:@"unsignedShort"];
    [dictionary setLong:9 forKey:@"long"];
    [dictionary setUnsignedLong:10 forKey:@"unsignedLong"];
    [dictionary setLongLong:11 forKey:@"longLong"];
    [dictionary setUnsignedLongLong:12 forKey:@"unsignedLongLong"];
    [dictionary setFloat:13.0 forKey:@"float"];
    [dictionary setDouble:14.0 forKey:@"double"];
    [dictionary setLongDouble:15.0 forKey:@"longDouble"];
    [dictionary setRect:(NSRect){{16, 17}, {18, 19}} forKey:@"rect"];
    [dictionary setSize:(NSSize){20, 21} forKey:@"size"];
    [dictionary setPoint:(NSPoint){22, 23} forKey:@"point"];
    [dictionary setRange:(NSRange){24, 25} forKey:@"range"];
    
    XCTAssert([dictionary boolForKey:@"yes" defaultValue:NO] == YES);
    XCTAssert([dictionary boolForKey:@"!yes" defaultValue:NO] == NO);
    XCTAssert([dictionary boolForKey:@"no" defaultValue:YES] == NO);
    XCTAssert([dictionary boolForKey:@"!no" defaultValue:YES] == YES);
    XCTAssert([dictionary intForKey:@"int" defaultValue:100] == 1);
    XCTAssert([dictionary intForKey:@"!int" defaultValue:100] == 100);
    XCTAssert([dictionary unsignedIntForKey:@"unsignedInt" defaultValue:100] == 2);
    XCTAssert([dictionary unsignedIntForKey:@"!unsignedInt" defaultValue:100] == 100);
    XCTAssert([dictionary integerForKey:@"integer" defaultValue:100] == 3);
    XCTAssert([dictionary integerForKey:@"!integer" defaultValue:100] == 100);
    XCTAssert([dictionary unsignedIntegerForKey:@"unsignedInteger" defaultValue:100] == 4);
    XCTAssert([dictionary unsignedIntegerForKey:@"!unsignedInteger" defaultValue:100] == 100);
    XCTAssert([dictionary charForKey:@"char" defaultValue:100] == 5);
    XCTAssert([dictionary charForKey:@"!char" defaultValue:100] == 100);
    XCTAssert([dictionary unsignedCharForKey:@"unsignedChar" defaultValue:100] == 6);
    XCTAssert([dictionary unsignedCharForKey:@"!unsignedChar" defaultValue:100] == 100);
    XCTAssert([dictionary shortForKey:@"short" defaultValue:100] == 7);
    XCTAssert([dictionary shortForKey:@"!short" defaultValue:100] == 100);
    XCTAssert([dictionary unsignedShortForKey:@"unsignedShort" defaultValue:100] == 8);
    XCTAssert([dictionary unsignedShortForKey:@"!unsignedShort" defaultValue:100] == 100);
    XCTAssert([dictionary longForKey:@"long" defaultValue:100] == 9);
    XCTAssert([dictionary longForKey:@"!long" defaultValue:100] == 100);
    XCTAssert([dictionary unsignedLongForKey:@"unsignedLong" defaultValue:100] == 10);
    XCTAssert([dictionary unsignedLongForKey:@"!unsignedLong" defaultValue:100] == 100);
    XCTAssert([dictionary longLongForKey:@"longLong" defaultValue:100] == 11);
    XCTAssert([dictionary longLongForKey:@"!longLong" defaultValue:100] == 100);
    XCTAssert([dictionary unsignedLongLongForKey:@"unsignedLongLong" defaultValue:100] == 12);
    XCTAssert([dictionary unsignedLongLongForKey:@"!unsignedLongLong" defaultValue:100] == 100);
    XCTAssert([dictionary floatForKey:@"float" defaultValue:100] == 13);
    XCTAssert([dictionary floatForKey:@"!float" defaultValue:100] == 100);
    XCTAssert([dictionary doubleForKey:@"double" defaultValue:100] == 14);
    XCTAssert([dictionary doubleForKey:@"!double" defaultValue:100] == 100);
    XCTAssert([dictionary longDoubleForKey:@"longDouble" defaultValue:100] == 15);
    XCTAssert([dictionary longDoubleForKey:@"!longDouble" defaultValue:100] == 100);
    XCTAssert(NSEqualRects([dictionary rectForKey:@"rect" defaultValue:NSZeroRect], (NSRect){{16, 17}, {18, 19}}));
    XCTAssert(NSEqualRects([dictionary rectForKey:@"!rect" defaultValue:NSZeroRect], NSZeroRect));
    XCTAssert(NSEqualSizes([dictionary sizeForKey:@"size" defaultValue:NSZeroSize], (NSSize){20, 21}));
    XCTAssert(NSEqualSizes([dictionary sizeForKey:@"!size" defaultValue:NSZeroSize], NSZeroSize));
    XCTAssert(NSEqualPoints([dictionary pointForKey:@"point" defaultValue:NSZeroPoint], (NSPoint){22, 23}));
    XCTAssert(NSEqualPoints([dictionary pointForKey:@"!point" defaultValue:NSZeroPoint], NSZeroPoint));
    XCTAssert(NSEqualRanges([dictionary rangeForKey:@"range" defaultValue:(NSRange){0, 0}], (NSRange){24, 25}));
    XCTAssert(NSEqualRanges([dictionary rangeForKey:@"!range" defaultValue:(NSRange){0, 0}], (NSRange){0, 0}));
}

- (void)testMath {
    NSMutableDictionary<NSString *, NSNumber *> *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary addInteger:@(1) toKey:@"integer"];
    XCTAssert(dictionary[@"integer"].integerValue == 1);
    [dictionary addInteger:@(2) toKey:@"integer"];
    XCTAssert(dictionary[@"integer"].integerValue == 3);

    [dictionary addDouble:@(1.0) toKey:@"double"];
    XCTAssert(dictionary[@"double"].doubleValue == 1.0);
    [dictionary addDouble:@(2.0) toKey:@"double"];
    XCTAssert(dictionary[@"double"].doubleValue == 3.0);
}

- (void)testAddingObjects {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObjectIfNotNil:@(1) forKey:@"one"];
    [dictionary setObjectIfNotNil:nil forKey:@"two"];
    XCTAssert([dictionary[@"one"] isEqual:@(1)]);
    XCTAssert(dictionary[@"two"] == nil);
    
    [dictionary addObject:@"one" toArrayForKey:@"array"];
    [dictionary addObject:@"two" toArrayForKey:@"array"];
    [dictionary addObject:@"three" toArrayForKey:@"array"];
    NSArray *array = @[@"one", @"two", @"three"];
    XCTAssert([dictionary[@"array"] isEqual:array]);
    
    [dictionary addObject:@"one" toSetForKey:@"set"];
    [dictionary addObject:@"two" toSetForKey:@"set"];
    [dictionary addObject:@"three" toSetForKey:@"set"];
    NSSet *set = [NSSet setWithArray:@[@"one", @"two", @"three"]];
    XCTAssert([dictionary[@"set"] isEqual:set]);
    
    [dictionary setObject:@(1) forKey:@"one" inDictionaryForKey:@"dictionary"];
    [dictionary setObject:@(2) forKey:@"two" inDictionaryForKey:@"dictionary"];
    [dictionary setObject:@(3) forKey:@"three" inDictionaryForKey:@"dictionary"];
    NSDictionary *subdictionary = @{@"one":@(1), @"two":@(2), @"three":@(3)};
    XCTAssert([dictionary[@"dictionary"] isEqual:subdictionary]);
    
    id object = [dictionary objectForKey:@"created" createIfAbsent:^id _Nonnull{
        return @(71);
    }];
    XCTAssert([dictionary[@"created"] isEqual:object]);
    XCTAssert([dictionary[@"created"] isEqual:@(71)]);
    XCTAssert([object isEqual:@(71)]);
}

@end
