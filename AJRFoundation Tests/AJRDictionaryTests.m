/*
 AJRDictionaryTests.m
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

@interface AJRDictionaryTest : XCTestCase

@end

@implementation AJRDictionaryTest

#define MAX_DOUBLE    (DBL_MAX)

- (void)testDictionaryAccessors
{
    NSMutableDictionary    *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setChar:'a' forKey:@"char"];
    [dictionary setUnsignedChar:'a' forKey:@"unsignedChar"];
    [dictionary setShort:INT16_MAX forKey:@"shortMax"];
    [dictionary setShort:INT16_MIN forKey:@"shortMin"];
    [dictionary setUnsignedShort:UINT16_MAX forKey:@"unsignedShortMax"];
    [dictionary setUnsignedShort:0 forKey:@"unsignedShortMin"];
    [dictionary setInt:INT32_MAX forKey:@"intMax"];
    [dictionary setInt:INT32_MIN forKey:@"intMin"];
    [dictionary setUnsignedInt:UINT32_MAX forKey:@"unsignedIntMax"];
    [dictionary setUnsignedInt:0 forKey:@"unsignedIntMin"];
    [dictionary setInteger:NSIntegerMax forKey:@"integerMax"];
    [dictionary setInteger:NSIntegerMin forKey:@"integerMin"];
    [dictionary setUnsignedInteger:NSUIntegerMax forKey:@"unsignedIntegerMax"];
    [dictionary setUnsignedInteger:0 forKey:@"unsignedIntegerMin"];
    [dictionary setLong:INT32_MAX forKey:@"longMax"];
    [dictionary setLong:INT32_MIN forKey:@"longMin"];
    [dictionary setUnsignedLong:UINT32_MAX forKey:@"unsignedLongMax"];
    [dictionary setUnsignedLong:0 forKey:@"unsignedLongMin"];
    [dictionary setLongLong:INT64_MAX forKey:@"longLongMax"];
    [dictionary setLongLong:INT64_MIN forKey:@"longLongMin"];
    [dictionary setUnsignedLongLong:UINT64_MAX forKey:@"unsignedLongLongMax"];
    [dictionary setUnsignedLongLong:0 forKey:@"unsignedLongLongMin"];
    [dictionary setFloat:FLT_MAX forKey:@"floatMax"];
    [dictionary setFloat:FLT_MIN forKey:@"floatMin"];
    [dictionary setDouble:MAX_DOUBLE forKey:@"doubleMax"];
    [dictionary setDouble:DBL_MIN forKey:@"doubleMin"];
    [dictionary setLongDouble:M_PI forKey:@"longDoubleMax"];
    [dictionary setLongDouble:-M_PI forKey:@"longDoubleMin"];
    [dictionary setRect:(NSRect){{1,2},{3,4}} forKey:@"rect"];
    [dictionary setSize:(NSSize){3,4} forKey:@"size"];
    [dictionary setPoint:(NSPoint){1,2} forKey:@"point"];
    [dictionary setRange:(NSRange){1,2} forKey:@"range"];
    
    AJRPrintf(@"dict: %@\n", dictionary);

    XCTAssertTrue([dictionary charForKey:@"char" defaultValue:0] == 'a', @"Did not retrieve char");
    XCTAssertTrue([dictionary unsignedCharForKey:@"unsignedChar" defaultValue:0] == 'a', @"Did not retrieve unsigned char");
    XCTAssertTrue([dictionary shortForKey:@"shortMax" defaultValue:0] == INT16_MAX, @"Did not retrieve shortMax");
    XCTAssertTrue([dictionary shortForKey:@"shortMin" defaultValue:0] == INT16_MIN, @"Did not retrieve shortMin");
    XCTAssertTrue([dictionary unsignedShortForKey:@"unsignedShortMax" defaultValue:0] == UINT16_MAX, @"Did not retrieve unsignedShortMax");
    XCTAssertTrue([dictionary unsignedShortForKey:@"unsignedShortMin" defaultValue:0] == 0, @"Did not retrieve unsignedShortMin");
    XCTAssertTrue([dictionary intForKey:@"intMax" defaultValue:0] == INT32_MAX, @"Did not retrieve intMax");
    XCTAssertTrue([dictionary intForKey:@"intMin" defaultValue:0] == INT32_MIN, @"Did not retrieve intMin");
    XCTAssertTrue([dictionary unsignedIntForKey:@"unsignedIntMax" defaultValue:0] == UINT32_MAX, @"Did not retrieve unsignedIntMax");
    XCTAssertTrue([dictionary unsignedIntForKey:@"unsignedIntMin" defaultValue:0] == 0, @"Did not retrieve unsignedIntMin");
    XCTAssertTrue([dictionary integerForKey:@"integerMax" defaultValue:0] == NSIntegerMax, @"Did not retrieve integerMax");
    XCTAssertTrue([dictionary integerForKey:@"integerMin" defaultValue:0] == NSIntegerMin, @"Did not retrieve integerMin");
    XCTAssertTrue([dictionary unsignedIntegerForKey:@"unsignedIntegerMax" defaultValue:0] == NSUIntegerMax, @"Did not retrieve unsignedIntegerMax");
    XCTAssertTrue([dictionary unsignedIntegerForKey:@"unsignedIntegerMin" defaultValue:0] == 0, @"Did not retrieve unsignedIntegerMin");
    XCTAssertTrue([dictionary longForKey:@"longMax" defaultValue:0] == INT32_MAX, @"Did not retrieve longMax");
    XCTAssertTrue([dictionary longForKey:@"longMin" defaultValue:0] == INT32_MIN, @"Did not retrieve longMin");
    XCTAssertTrue([dictionary unsignedLongForKey:@"unsignedLongMax" defaultValue:0] == UINT32_MAX, @"Did not retrieve unsignedLongMax");
    XCTAssertTrue([dictionary unsignedLongForKey:@"unsignedLongMin" defaultValue:0] == 0, @"Did not retrieve unsignedLongMin");
    XCTAssertTrue([dictionary longLongForKey:@"longLongMax" defaultValue:0] == INT64_MAX, @"Did not retrieve longLongMax");
    XCTAssertTrue([dictionary longLongForKey:@"longLongMin" defaultValue:0] == INT64_MIN, @"Did not retrieve longLongMin");
    XCTAssertTrue([dictionary unsignedLongLongForKey:@"unsignedLongLongMax" defaultValue:0] == UINT64_MAX, @"Did not retrieve unsignedLongLongMax");
    XCTAssertTrue([dictionary unsignedLongLongForKey:@"unsignedLongLongMin" defaultValue:0] == 0, @"Did not retrieve unsignedLongLongMin");
    XCTAssertTrue([[dictionary objectForKey:@"floatMax"] isEqualToString:AJRFormat(@"%g", [dictionary floatForKey:@"floatMax" defaultValue:0])], @"Did not retrieve floatMax");
    XCTAssertTrue([[dictionary objectForKey:@"floatMin"] isEqualToString:AJRFormat(@"%g", [dictionary floatForKey:@"floatMin" defaultValue:0])], @"Did not retrieve floatMin");
    XCTAssertTrue([[dictionary objectForKey:@"doubleMax"] isEqualToString:AJRFormat(@"%g", [dictionary doubleForKey:@"doubleMax" defaultValue:0])], @"Did not retrieve doubleMax");
    XCTAssertTrue([[dictionary objectForKey:@"doubleMin"] isEqualToString:AJRFormat(@"%g", [dictionary doubleForKey:@"doubleMin" defaultValue:0])], @"Did not retrieve doubleMin");
    XCTAssertTrue([[dictionary objectForKey:@"longDoubleMax"] isEqualToString:AJRFormat(@"%LG", [dictionary longDoubleForKey:@"longDoubleMax" defaultValue:0])], @"Did not retrieve longDoubleMax");
    XCTAssertTrue([[dictionary objectForKey:@"longDoubleMin"] isEqualToString:AJRFormat(@"%LG", [dictionary longDoubleForKey:@"longDoubleMin" defaultValue:0])], @"Did not retrieve longDoubleMin");
    XCTAssertTrue(NSEqualRects([dictionary rectForKey:@"rect" defaultValue:NSZeroRect], (NSRect){{1,2},{3,4}}), @"Did not retrieve rect");
    XCTAssertTrue(NSEqualSizes([dictionary sizeForKey:@"size" defaultValue:NSZeroSize], (NSSize){3,4}), @"Did not retrieve size");
    XCTAssertTrue(NSEqualPoints([dictionary pointForKey:@"point" defaultValue:NSZeroPoint], (NSPoint){1,2}), @"Did not retrieve point");
    XCTAssertTrue(NSEqualRanges([dictionary rangeForKey:@"range" defaultValue:(NSRange){NSNotFound, 0}], (NSRange){1,2}), @"Did not retrieve range");
}

@end
