/*
 NSDictionary+ExtensionsTests.m
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
#import <AJRFoundation/NSDictionary+ExtensionsP.h>

#import "AJRXMLErrorDecodeObject.h"

@interface NSDictionary_ExtensionsTests : XCTestCase

@end

@implementation NSDictionary_ExtensionsTests

- (void)testErrorHandling {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    
    AJRLogSetOutputStream(outputStream, AJRLogLevelWarning);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    // Because we're purposefully trying to cause an error.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    @try {
        [dictionary setObject:nil forKey:@"test"];
    } @catch (NSException *localException) {
    }
#pragma clang diagnostic pop
    
    NSString *string = [outputStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([string containsString:@"_AJRSetObjectNilObjectOrKey()"]);
    
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
}

- (void)testGetters {
    static const NSRange NSRangeNotFound = {0, NSNotFound};
    id testObject1 = [[NSObject alloc] init];
    id testObject2 = [[NSObject alloc] init];
    NSSize size = {10.0, 20.0};
    NSPoint point = {30.0, 40.0};
    NSRect rect = {.origin = point, .size = size};
    NSRange range = { 10, 100 };
    NSArray *array = @[@"one", @"two", @"three"];
    NSTimeInterval timeInterval = [NSDate timeIntervalSinceReferenceDate];
    long long milliseconds = ((1 * AJRSecondsPerHour) + (15 * AJRSecondsPerMinute) + 32) * AJRMillisPerSecond + 15.0;
    char charValue = INT8_MAX;
    short shortValue = INT16_MAX;
    int intValue = INT32_MAX;
    NSInteger integerValue = NSIntegerMax;
    long longValue = INT64_MAX;
    long long longLongValue = INT64_MAX;
    unsigned char unsignedCharValue = UINT8_MAX;
    unsigned short unsignedShortValue = UINT16_MAX;
    unsigned int unsignedIntValue = UINT32_MAX;
    NSUInteger unsignedIntegerValue = NSUIntegerMax;
    unsigned long unsignedLongValue = UINT64_MAX;
    unsigned long long unsignedLongLongValue = UINT64_MAX;
    float floatValue = 1000000.0;
    double doubleValue = 10000000.0;
    long double longDoubleValue = 100000000.0;
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSMutableDictionary *test = [@{
        @"object":testObject2,
        @"rect":NSStringFromRect(rect),
        @"size":NSStringFromSize(size),
        @"point":NSStringFromPoint(point),
        @"range":NSStringFromRange(range),
        @"array":array,
        @"string":@"test",
        @"timeInterval":@(timeInterval),
        @"timeIntervalString":[@(timeInterval) description],
        @"milliseconds":@"1h 15m 32s 15ms",
        @"milliseconds-nounits":@"1234",
        @"char":@(charValue),
        @"char-string":[@(charValue) description],
        @"short":@(shortValue),
        @"short-string":[@(shortValue) description],
        @"int":@(intValue),
        @"int-string":[@(intValue) description],
        @"integer":@(integerValue),
        @"integer-string":[@(integerValue) description],
        @"long":@(longValue),
        @"long-string":[@(longValue) description],
        @"long-long":@(longLongValue),
        @"long-long-string":[@(longLongValue) description],
        @"unsigned-char":@(unsignedCharValue),
        @"unsigned-char-string":[@(unsignedCharValue) description],
        @"unsigned-short":@(unsignedShortValue),
        @"unsigned-short-string":[@(unsignedShortValue) description],
        @"unsigned-int":@(unsignedIntValue),
        @"unsigned-int-string":[@(unsignedIntValue) description],
        @"unsigned-integer":@(unsignedIntegerValue),
        @"unsigned-integer-string":[@(unsignedIntegerValue) description],
        @"unsigned-long":@(unsignedLongValue),
        @"unsigned-long-string":[@(unsignedLongValue) description],
        @"unsigned-long-long":@(unsignedLongLongValue),
        @"unsigned-long-long-string":[@(unsignedLongLongValue) description],
        @"float":@(floatValue),
        @"float-string":[@(floatValue) description],
        @"double":@(doubleValue),
        @"double-string":[@(doubleValue) description],
        @"long-double":AJRFormat(@"%lf", longDoubleValue),
        @"bool-1":@YES,
        @"bool-2":@(1),
        @"bool-3":@(0),
        @"bool-yes-string-1":@"yes",
        @"bool-yes-string-2":@"YES",
        @"bool-yes-string-3":@"true",
        @"bool-yes-string-4":@"TRUE",
        @"bool-no-string-1":@"no",
        @"bool-no-string-2":@"NO",
        @"bool-no-string-3":@"false",
        @"bool-no-string-4":@"FALSE",
        @"characterSet":characterSet,
        @"characterSet-string":@"0123456789",
    } mutableCopy];
    NSMutableDictionary *subdictionary = [test mutableCopy];
    NSDictionary *subsubdictionary = [subdictionary copy];
    subdictionary[@"subsubdictionary"] = subsubdictionary;
    test[@"subdictionary"] = subdictionary;
    
    void (^executeCheckingWarningStream)(NSString *, void (^)(void)) = ^(NSString *expectedWarning, void (^block)(void)) {
        NSOutputStream *saved = AJRLogGetOutputStream(AJRLogLevelWarning);
        NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
        AJRLogSetOutputStream(stream, AJRLogLevelWarning);
        block();
        NSString *string = [stream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding];
        XCTAssert([string hasPrefix:expectedWarning]);
        AJRLogSetOutputStream(saved, AJRLogLevelWarning);
    };
    
    XCTAssert([test objectForKey:@"object" defaultValue:testObject1] == testObject2);
    XCTAssert([test objectForKey:@"object-notfound" defaultValue:testObject1] == testObject1);
    XCTAssert([test objectForKeyPath:@"subdictionary.object" defaultValue:testObject1] == testObject2);
    XCTAssert([test objectForKeyPath:@"subdictionary.object-notfound" defaultValue:testObject1] == testObject1);

    XCTAssert(NSEqualRects([test rectForKey:@"rect" defaultValue:NSZeroRect], rect));
    XCTAssert(NSEqualRects([test rectForKey:@"rect-notfound" defaultValue:NSZeroRect], NSZeroRect));
    XCTAssert(NSEqualRects([test rectForKeyPath:@"subdictionary.rect" defaultValue:NSZeroRect], rect));
    XCTAssert(NSEqualRects([test rectForKeyPath:@"subdictionary.rect-notfound" defaultValue:NSZeroRect], NSZeroRect));

    XCTAssert(NSEqualSizes([test sizeForKey:@"size" defaultValue:NSZeroSize], size));
    XCTAssert(NSEqualSizes([test sizeForKey:@"size-notfound" defaultValue:NSZeroSize], NSZeroSize));
    XCTAssert(NSEqualSizes([test sizeForKeyPath:@"subdictionary.size" defaultValue:NSZeroSize], size));
    XCTAssert(NSEqualSizes([test sizeForKeyPath:@"subdictionary.size-notfound" defaultValue:NSZeroSize], NSZeroSize));

    XCTAssert(NSEqualPoints([test pointForKey:@"point" defaultValue:NSZeroPoint], point));
    XCTAssert(NSEqualPoints([test pointForKey:@"point-notfound" defaultValue:NSZeroPoint], NSZeroPoint));
    XCTAssert(NSEqualPoints([test pointForKeyPath:@"subdictionary.point" defaultValue:NSZeroPoint], point));
    XCTAssert(NSEqualPoints([test pointForKeyPath:@"subdictionary.point-notfound" defaultValue:NSZeroPoint], NSZeroPoint));

    XCTAssert(NSEqualRanges([test rangeForKey:@"range" defaultValue:NSRangeNotFound], range));
    XCTAssert(NSEqualRanges([test rangeForKey:@"range-notfound" defaultValue:NSRangeNotFound], NSRangeNotFound));
    XCTAssert(NSEqualRanges([test rangeForKeyPath:@"subdictionary.range" defaultValue:NSRangeNotFound], range));
    XCTAssert(NSEqualRanges([test rangeForKeyPath:@"subdictionary.range-notfound" defaultValue:NSRangeNotFound], NSRangeNotFound));

    XCTAssert([[test arrayForKey:@"array"] isEqualToArray:array]);
    XCTAssert([[test arrayForKey:@"array" defaultValue:@[]] isEqualToArray:array]);
    XCTAssert([[test arrayForKey:@"array-notfound" defaultValue:@[]] isEqualToArray:@[]]);
    executeCheckingWarningStream(@"<WARNING>: Expected array value for key", ^{
        XCTAssert([[test arrayForKey:@"rect" defaultValue:@[]] isEqualToArray:@[]]);
    });
    XCTAssert([[test arrayForKeyPath:@"subdictionary.array" defaultValue:@[]] isEqualToArray:array]);
    XCTAssert([[test arrayForKeyPath:@"subdictionary.array-notfound" defaultValue:@[]] isEqualToArray:@[]]);
    executeCheckingWarningStream(@"<WARNING>: Expected array value for key", ^{
        XCTAssert([[test arrayForKeyPath:@"subdictionary.rect" defaultValue:@[]] isEqualToArray:@[]]);
    });

    XCTAssert([[test dictionaryForKey:@"subdictionary"] isEqualToDictionary:subdictionary]);
    XCTAssert([[test dictionaryForKey:@"subdictionary" defaultValue:@{}] isEqualToDictionary:subdictionary]);
    XCTAssert([[test dictionaryForKey:@"subdictionary-notfound" defaultValue:@{}] isEqualToDictionary:@{}]);
    executeCheckingWarningStream(@"<WARNING>: Expected dictionary value for key", ^{
        XCTAssert([[test dictionaryForKey:@"rect" defaultValue:@{}] isEqualToDictionary:@{}]);
    });
    XCTAssert([[test dictionaryForKeyPath:@"subdictionary.subsubdictionary" defaultValue:@{}] isEqualToDictionary:subsubdictionary]);
    XCTAssert([[test dictionaryForKeyPath:@".subdictionary.subsubdictionary-notfound" defaultValue:@{}] isEqualToDictionary:@{}]);
    executeCheckingWarningStream(@"<WARNING>: Expected dictionary value for key", ^{
        XCTAssert([[test dictionaryForKeyPath:@"subdictionary.subsubdictionary.rect" defaultValue:@{}] isEqualToDictionary:@{}]);
    });
    XCTAssert([[test stringForKey:@"string" defaultValue:@"default"] isEqualToString:@"test"]);
    XCTAssert([[test stringForKey:@"string-notfound" defaultValue:@"default"] isEqualToString:@"default"]);
    XCTAssert([[test stringForKeyPath:@"subdictionary.string" defaultValue:@"default"] isEqualToString:@"test"]);
    XCTAssert([[test stringForKeyPath:@"subdictionary.string-notfound" defaultValue:@"default"] isEqualToString:@"default"]);

    XCTAssert([test timeIntervalForKey:@"timeInterval" defaultValue:10.0] == timeInterval);
    XCTAssert([test timeIntervalForKey:@"timeInterval-notfound" defaultValue:10.0] == 10.0);
    XCTAssert([test timeIntervalForKeyPath:@"subdictionary.timeInterval" defaultValue:10.0] == timeInterval);
    XCTAssert([test timeIntervalForKeyPath:@"subdictionary.timeInterval-notfound" defaultValue:10.0] == 10.0);
    XCTAssert([test timeIntervalForKey:@"timeIntervalString" defaultValue:10.0] == timeInterval);
    XCTAssert([test timeIntervalForKey:@"timeIntervalString-notfound" defaultValue:10.0] == 10.0);
    XCTAssert([test timeIntervalForKeyPath:@"subdictionary.timeIntervalString" defaultValue:10.0] == timeInterval);
    XCTAssert([test timeIntervalForKeyPath:@"subdictionary.timeIntervalString-notfound" defaultValue:10.0] == 10.0);

    XCTAssert([test millisecondsForKey:@"milliseconds" defaultValue:10.0] == milliseconds);
    XCTAssert([test millisecondsForKey:@"milliseconds-notfound" defaultValue:10.0] == 10.0);
    XCTAssert([test millisecondsForKeyPath:@"subdictionary.milliseconds" defaultValue:10.0] == milliseconds);
    XCTAssert([test millisecondsForKeyPath:@"subdictionary.milliseconds-notfound" defaultValue:10.0] == 10.0);

    XCTAssert([[test numberForKey:@"char" defaultValue:@(1)] isEqualToNumber:@(charValue)]);
    XCTAssert([[test numberForKey:@"char-notfound" defaultValue:@(1)] isEqualToNumber:@(1)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.char" defaultValue:@(1)] isEqualToNumber:@(charValue)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.char-notfound" defaultValue:@(1)] isEqualToNumber:@(1)]);
    XCTAssert([[test numberForKey:@"char-string" defaultValue:@(1)] isEqualToNumber:@(charValue)]);
    XCTAssert([[test numberForKey:@"char-string-notfound" defaultValue:@(1)] isEqualToNumber:@(1)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.char-string" defaultValue:@(1)] isEqualToNumber:@(charValue)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.char-string-notfound" defaultValue:@(1)] isEqualToNumber:@(1)]);

    XCTAssert([[test numberForKey:@"float" defaultValue:@(1.0)] isEqualToNumber:@(floatValue)]);
    XCTAssert([[test numberForKey:@"float-notfound" defaultValue:@(1.0)] isEqualToNumber:@(1.0)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.float" defaultValue:@(1.0)] isEqualToNumber:@(floatValue)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.float-notfound" defaultValue:@(1.0)] isEqualToNumber:@(1.0)]);
    XCTAssert([[test numberForKey:@"float-string" defaultValue:@(1.0)] isEqualToNumber:@(floatValue)]);
    XCTAssert([[test numberForKey:@"float-string-notfound" defaultValue:@(1.0)] isEqualToNumber:@(1.0)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.float-string" defaultValue:@(1.0)] isEqualToNumber:@(floatValue)]);
    XCTAssert([[test numberForKeyPath:@"subdictionary.float-string-notfound" defaultValue:@(1.0)] isEqualToNumber:@(1.0)]);
    
    XCTAssert([test charForKey:@"char" defaultValue:1] == charValue);
    XCTAssert([test charForKey:@"char-notfound" defaultValue:1] == 1);
    XCTAssert([test charForKeyPath:@"subdictionary.char" defaultValue:1] == charValue);
    XCTAssert([test charForKeyPath:@"subdictionary.char-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedCharForKey:@"unsigned-char" defaultValue:1] == unsignedCharValue);
    XCTAssert([test unsignedCharForKey:@"unsigned-char-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedCharForKeyPath:@"subdictionary.unsigned-char" defaultValue:1] == unsignedCharValue);
    XCTAssert([test unsignedCharForKeyPath:@"subdictionary.unsigned-char-notfound" defaultValue:1] == 1);
    
    XCTAssert([test charForKey:@"char-string" defaultValue:1] == charValue);
    XCTAssert([test charForKey:@"char-string-notfound" defaultValue:1] == 1);
    XCTAssert([test charForKeyPath:@"subdictionary.char-string" defaultValue:1] == charValue);
    XCTAssert([test charForKeyPath:@"subdictionary.char-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedCharForKey:@"unsigned-char-string" defaultValue:1] == unsignedCharValue);
    XCTAssert([test unsignedCharForKey:@"unsigned-char-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedCharForKeyPath:@"subdictionary.unsigned-char-string" defaultValue:1] == unsignedCharValue);
    XCTAssert([test unsignedCharForKeyPath:@"subdictionary.unsigned-char-string-notfound" defaultValue:1] == 1);
    
    XCTAssert([test shortForKey:@"short" defaultValue:1] == shortValue);
    XCTAssert([test shortForKey:@"short-notfound" defaultValue:1] == 1);
    XCTAssert([test shortForKeyPath:@"subdictionary.short" defaultValue:1] == shortValue);
    XCTAssert([test shortForKeyPath:@"subdictionary.short-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedShortForKey:@"unsigned-short" defaultValue:1] == unsignedShortValue);
    XCTAssert([test unsignedShortForKey:@"unsigned-short-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedShortForKeyPath:@"subdictionary.unsigned-short" defaultValue:1] == unsignedShortValue);
    XCTAssert([test unsignedShortForKeyPath:@"subdictionary.unsigned-short-notfound" defaultValue:1] == 1);
    
    XCTAssert([test shortForKey:@"short-string" defaultValue:1] == shortValue);
    XCTAssert([test shortForKey:@"short-string-notfound" defaultValue:1] == 1);
    XCTAssert([test shortForKeyPath:@"subdictionary.short-string" defaultValue:1] == shortValue);
    XCTAssert([test shortForKeyPath:@"subdictionary.short-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedShortForKey:@"unsigned-short-string" defaultValue:1] == unsignedShortValue);
    XCTAssert([test unsignedShortForKey:@"unsigned-short-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedShortForKeyPath:@"subdictionary.unsigned-short-string" defaultValue:1] == unsignedShortValue);
    XCTAssert([test unsignedShortForKeyPath:@"subdictionary.unsigned-short-string-notfound" defaultValue:1] == 1);
    
    XCTAssert([test intForKey:@"int" defaultValue:1] == intValue);
    XCTAssert([test intForKey:@"int-notfound" defaultValue:1] == 1);
    XCTAssert([test intForKeyPath:@"subdictionary.int" defaultValue:1] == intValue);
    XCTAssert([test intForKeyPath:@"subdictionary.int-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntForKey:@"unsigned-int" defaultValue:1] == unsignedIntValue);
    XCTAssert([test unsignedIntForKey:@"unsigned-int-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntForKeyPath:@"subdictionary.unsigned-int" defaultValue:1] == unsignedIntValue);
    XCTAssert([test unsignedIntForKeyPath:@"subdictionary.unsigned-int-notfound" defaultValue:1] == 1);
    
    XCTAssert([test intForKey:@"int-string" defaultValue:1] == intValue);
    XCTAssert([test intForKey:@"int-string-notfound" defaultValue:1] == 1);
    XCTAssert([test intForKeyPath:@"subdictionary.int-string" defaultValue:1] == intValue);
    XCTAssert([test intForKeyPath:@"subdictionary.int-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntForKey:@"unsigned-int-string" defaultValue:1] == unsignedIntValue);
    XCTAssert([test unsignedIntForKey:@"unsigned-int-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntForKeyPath:@"subdictionary.unsigned-int-string" defaultValue:1] == unsignedIntValue);
    XCTAssert([test unsignedIntForKeyPath:@"subdictionary.unsigned-int-string-notfound" defaultValue:1] == 1);
    
    XCTAssert([test integerForKey:@"integer" defaultValue:1] == integerValue);
    XCTAssert([test integerForKey:@"integer-notfound" defaultValue:1] == 1);
    XCTAssert([test integerForKeyPath:@"subdictionary.integer" defaultValue:1] == integerValue);
    XCTAssert([test integerForKeyPath:@"subdictionary.integer-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntegerForKey:@"unsigned-integer" defaultValue:1] == unsignedIntegerValue);
    XCTAssert([test unsignedIntegerForKey:@"unsigned-integer-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntegerForKeyPath:@"subdictionary.unsigned-integer" defaultValue:1] == unsignedIntegerValue);
    XCTAssert([test unsignedIntegerForKeyPath:@"subdictionary.unsigned-integer-notfound" defaultValue:1] == 1);
    
    XCTAssert([test integerForKey:@"integer-string" defaultValue:1] == integerValue);
    XCTAssert([test integerForKey:@"integer-string-notfound" defaultValue:1] == 1);
    XCTAssert([test integerForKeyPath:@"subdictionary.integer-string" defaultValue:1] == integerValue);
    XCTAssert([test integerForKeyPath:@"subdictionary.integer-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntegerForKey:@"unsigned-integer-string" defaultValue:1] == unsignedIntegerValue);
    XCTAssert([test unsignedIntegerForKey:@"unsigned-integer-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedIntegerForKeyPath:@"subdictionary.unsigned-integer-string" defaultValue:1] == unsignedIntegerValue);
    XCTAssert([test unsignedIntegerForKeyPath:@"subdictionary.unsigned-integer-string-notfound" defaultValue:1] == 1);
    
    XCTAssert([test longForKey:@"long" defaultValue:1] == longValue);
    XCTAssert([test longForKey:@"long-notfound" defaultValue:1] == 1);
    XCTAssert([test longForKeyPath:@"subdictionary.long" defaultValue:1] == longValue);
    XCTAssert([test longForKeyPath:@"subdictionary.long-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongForKey:@"unsigned-long" defaultValue:1] == unsignedLongValue);
    XCTAssert([test unsignedLongForKey:@"unsigned-long-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongForKeyPath:@"subdictionary.unsigned-long" defaultValue:1] == unsignedLongValue);
    XCTAssert([test unsignedLongForKeyPath:@"subdictionary.unsigned-long-notfound" defaultValue:1] == 1);
    
    XCTAssert([test longForKey:@"long-string" defaultValue:1] == longValue);
    XCTAssert([test longForKey:@"long-string-notfound" defaultValue:1] == 1);
    XCTAssert([test longForKeyPath:@"subdictionary.long-string" defaultValue:1] == longValue);
    XCTAssert([test longForKeyPath:@"subdictionary.long-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongForKey:@"unsigned-long-string" defaultValue:1] == unsignedLongValue);
    XCTAssert([test unsignedLongForKey:@"unsigned-long-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongForKeyPath:@"subdictionary.unsigned-long-string" defaultValue:1] == unsignedLongValue);
    XCTAssert([test unsignedLongForKeyPath:@"subdictionary.unsigned-long-string-notfound" defaultValue:1] == 1);
    
    XCTAssert([test longLongForKey:@"long-long" defaultValue:1] == longLongValue);
    XCTAssert([test longLongForKey:@"long-long-notfound" defaultValue:1] == 1);
    XCTAssert([test longLongForKeyPath:@"subdictionary.long-long" defaultValue:1] == longLongValue);
    XCTAssert([test longLongForKeyPath:@"subdictionary.long-long-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongLongForKey:@"unsigned-long-long" defaultValue:1] == unsignedLongLongValue);
    XCTAssert([test unsignedLongLongForKey:@"unsigned-long-long-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongLongForKeyPath:@"subdictionary.unsigned-long-long" defaultValue:1] == unsignedLongLongValue);
    XCTAssert([test unsignedLongLongForKeyPath:@"subdictionary.unsigned-long-long-notfound" defaultValue:1] == 1);
    
    XCTAssert([test longLongForKey:@"long-long-string" defaultValue:1] == longLongValue);
    XCTAssert([test longLongForKey:@"long-long-string-notfound" defaultValue:1] == 1);
    XCTAssert([test longLongForKeyPath:@"subdictionary.long-long-string" defaultValue:1] == longLongValue);
    XCTAssert([test longLongForKeyPath:@"subdictionary.long-long-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongLongForKey:@"unsigned-long-long-string" defaultValue:1] == unsignedLongLongValue);
    XCTAssert([test unsignedLongLongForKey:@"unsigned-long-long-string-notfound" defaultValue:1] == 1);
    XCTAssert([test unsignedLongLongForKeyPath:@"subdictionary.unsigned-long-long-string" defaultValue:1] == unsignedLongLongValue);
    XCTAssert([test unsignedLongLongForKeyPath:@"subdictionary.unsigned-long-long-string-notfound" defaultValue:1] == 1);

    XCTAssert([test boolForKey:@"bool-1" defaultValue:NO]);
    XCTAssert([test boolForKey:@"bool-2" defaultValue:NO]);
    XCTAssert(![test boolForKey:@"bool-3" defaultValue:YES]);
    XCTAssert(![test boolForKey:@"bool-1-notfound" defaultValue:NO]);
    XCTAssert(![test boolForKey:@"bool-2-notfound" defaultValue:NO]);
    XCTAssert([test boolForKey:@"bool-3-notfound" defaultValue:YES]);
    XCTAssert([test boolForKeyPath:@"subdictionary.bool-1" defaultValue:NO]);
    XCTAssert([test boolForKeyPath:@"subdictionary.bool-2" defaultValue:NO]);
    XCTAssert(![test boolForKeyPath:@"subdictionary.bool-3" defaultValue:YES]);
    XCTAssert(![test boolForKeyPath:@"subdictionary.bool-1-notfound" defaultValue:NO]);
    XCTAssert(![test boolForKeyPath:@"subdictionary.bool-2-notfound" defaultValue:NO]);
    XCTAssert([test boolForKeyPath:@"subdictionary.bool-3-notfound" defaultValue:YES]);
    XCTAssert([test boolForKey:@"bool-yes-string-1" defaultValue:NO]);
    XCTAssert([test boolForKey:@"bool-yes-string-2" defaultValue:NO]);
    XCTAssert([test boolForKey:@"bool-yes-string-3" defaultValue:NO]);
    XCTAssert([test boolForKey:@"bool-yes-string-4" defaultValue:NO]);
    XCTAssert(![test boolForKey:@"bool-no-string-1" defaultValue:YES]);
    XCTAssert(![test boolForKey:@"bool-no-string-2" defaultValue:YES]);
    XCTAssert(![test boolForKey:@"bool-no-string-3" defaultValue:YES]);
    XCTAssert(![test boolForKey:@"bool-no-string-4" defaultValue:YES]);
    
    XCTAssert([test floatForKey:@"float" defaultValue:1] == floatValue);
    XCTAssert([test floatForKey:@"float-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test floatForKeyPath:@"subdictionary.float" defaultValue:1.0] == floatValue);
    XCTAssert([test floatForKeyPath:@"subdictionary.float-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test floatForKey:@"float-string" defaultValue:1] == floatValue);
    XCTAssert([test floatForKey:@"float-string-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test floatForKeyPath:@"subdictionary.float-string" defaultValue:1.0] == floatValue);
    XCTAssert([test floatForKeyPath:@"subdictionary.float-string-notfound" defaultValue:1.0] == 1.0);
    
    XCTAssert([test doubleForKey:@"double" defaultValue:1] == doubleValue);
    XCTAssert([test doubleForKey:@"double-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test doubleForKeyPath:@"subdictionary.double" defaultValue:1.0] == doubleValue);
    XCTAssert([test doubleForKeyPath:@"subdictionary.double-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test doubleForKey:@"double-string" defaultValue:1] == doubleValue);
    XCTAssert([test doubleForKey:@"double-string-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test doubleForKeyPath:@"subdictionary.double-string" defaultValue:1.0] == doubleValue);
    XCTAssert([test doubleForKeyPath:@"subdictionary.double-string-notfound" defaultValue:1.0] == 1.0);
    
    XCTAssert([test longDoubleForKey:@"long-double" defaultValue:1] == longDoubleValue);
    XCTAssert([test longDoubleForKey:@"long-double-notfound" defaultValue:1.0] == 1.0);
    XCTAssert([test longDoubleForKeyPath:@"subdictionary.long-double" defaultValue:1] == longDoubleValue);
    XCTAssert([test longDoubleForKeyPath:@"subdictionary.long-double-notfound" defaultValue:1.0] == 1.0);
    
    XCTAssert([[test characterSetForKey:@"characterSet" defaultValue:nil] isEqual:characterSet]);
    XCTAssert([[test characterSetForKey:@"characterSet-notfound" defaultValue:[NSCharacterSet whitespaceCharacterSet]] isEqual:[NSCharacterSet whitespaceCharacterSet]]);
    XCTAssert([[test characterSetForKeyPath:@"subdictionary.characterSet" defaultValue:nil] isEqual:characterSet]);
    XCTAssert([[test characterSetForKeyPath:@"subdictionary.characterSet-notfound" defaultValue:[NSCharacterSet whitespaceCharacterSet]] isEqual:[NSCharacterSet whitespaceCharacterSet]]);
    XCTAssert([[test characterSetForKey:@"characterSet-string" defaultValue:nil] isEqual:characterSet]);
    XCTAssert([[test characterSetForKey:@"characterSet-string-notfound" defaultValue:[NSCharacterSet whitespaceCharacterSet]] isEqual:[NSCharacterSet whitespaceCharacterSet]]);
    XCTAssert([[test characterSetForKeyPath:@"subdictionary.characterSet-string" defaultValue:nil] isEqual:characterSet]);
    XCTAssert([[test characterSetForKeyPath:@"subdictionary.characterSet-string-notfound" defaultValue:[NSCharacterSet whitespaceCharacterSet]] isEqual:[NSCharacterSet whitespaceCharacterSet]]);
    
    XCTAssert([test objectForKey:@"object" inDictionaryForKey:@"subdictionary"] == testObject2);
}

- (void)testDerivedDictionaries {
    NSDictionary *input = @{@"one":@(1), @"two":@(2), @"three":@(3)};
    
    NSDictionary *result;
    
    result = [input subdictionaryForKeys:@[@"one", @"two"]];
    XCTAssert(result.count == 2);
    XCTAssert(result[@"one"] != nil);
    XCTAssert(result[@"two"] != nil);
    XCTAssert(result[@"three"] == nil);

    result = [input subdictionaryForKeys:@[@"one", @"two", @"four"] missingValue:[NSNull null]];
    XCTAssert(result.count == 3);
    XCTAssert([result[@"one"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"two"] isKindOfClass:[NSNumber class]]);
    XCTAssert(result[@"four"] != nil && ![result[@"four"] isKindOfClass:[NSNumber class]] && result[@"four"] == [NSNull null]);
    
    result = [input dictionaryByAddingEntriesFromDictionary:@{@"four":@(4), @"five":@(5)}];
    XCTAssert(result.count == 5);
    XCTAssert([result[@"one"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"two"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"three"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"four"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"five"] isKindOfClass:[NSNumber class]]);

    result = [input dictionaryByAddingEntriesFromDictionary:nil];
    XCTAssert(result.count == 3);
    XCTAssert([result[@"one"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"two"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"three"] isKindOfClass:[NSNumber class]]);
    
    result = [input dictionaryByRemovingObjectForKey:@"three"];
    XCTAssert(result.count == 2);
    XCTAssert([result[@"one"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"two"] isKindOfClass:[NSNumber class]]);
    
    result = [input dictionaryBySettingObject:@(4) forKey:@"four"];
    XCTAssert(result.count == 4);
    XCTAssert([result[@"one"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"two"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"three"] isKindOfClass:[NSNumber class]]);
    XCTAssert([result[@"four"] isKindOfClass:[NSNumber class]]);
}

- (void)testXMLCoding {
    NSDictionary *dictionary;
    NSData *data;
    NSError *localError;
    NSDictionary *decoded;

    @autoreleasepool {
        // Basic dictionary first
        dictionary = @{@"one":@(1), @"two":@(2), @"three":@(3), @"tres":@(3)};
        data = [AJRXMLArchiver archivedDataWithRootObject:dictionary];
        AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
        
        XCTAssert(decoded != nil);
        XCTAssert([decoded isEqualToDictionary:dictionary]);
        XCTAssert(![decoded isKindOfClass:[NSMutableDictionary class]] && [decoded isKindOfClass:[NSDictionary class]]);
    }

    @autoreleasepool {
        // Let's try a dictionary in a dictionary
        dictionary = @{@"one":@(1), @"two":@(2), @"dict":@{@"one":@(1), @"two":@(2)}};
        data = [AJRXMLArchiver archivedDataWithRootObject:dictionary];
        AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
        
        XCTAssert(decoded != nil);
        XCTAssert([decoded isEqualToDictionary:dictionary]);
        XCTAssert(![decoded isKindOfClass:[NSMutableDictionary class]] && [decoded isKindOfClass:[NSDictionary class]]);
    }
    
    @autoreleasepool {
        // And a mutable dictionary
        dictionary = [@{@"one":@(1), @"two":@(2), @"three":@(3), @"tres":@(3)} mutableCopy];
        data = [AJRXMLArchiver archivedDataWithRootObject:dictionary];
        AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
        
        XCTAssert(decoded != nil);
        XCTAssert([decoded isEqualToDictionary:dictionary]);
        XCTAssert([decoded isKindOfClass:[NSMutableDictionary class]]);
    }
    
    @autoreleasepool {
         // Try a really big dictionary
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSInteger x = 0; x < 512; x++) {
            dictionary[@(x)] = @(x * x);
        }

        data = [AJRXMLArchiver archivedDataWithRootObject:dictionary];
        AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
        
        XCTAssert(decoded != nil);
        XCTAssert([decoded isEqualToDictionary:dictionary]);
        XCTAssert([decoded isKindOfClass:[NSMutableDictionary class]]);
    }
    
    @autoreleasepool {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSInteger x = 0; x < 17; x++) {
            dictionary[@(x)] = [[AJRXMLErrorDecodeObject alloc] initWithValue:x];
        }

        data = [AJRXMLArchiver archivedDataWithRootObject:dictionary];
        AJRPrintf(@"xml: %@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        decoded = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];
        
        XCTAssert(decoded == nil);
        XCTAssert(localError != nil);
    }
    
    @autoreleasepool {
        // Finally, make sure the fallback dealloc method is working.
        AJRXMLDictionaryPlaceholder *placeholder = [[AJRXMLDictionaryPlaceholder alloc] initWithFinalClass:[NSDictionary class]];
        
        for (NSInteger x = 0; x < 200; x++) {
            [placeholder appendKey:@(x) andObject:@(x * x)];
        }
        
        // We're mostly just hoping that we don't crash in our dealloc method for AJRXMLDictionaryPlaceholder, because we didn't call finalizeForXMLCoding, which means the key/value pairs will be freed in dealloc.
    }
}

@end
