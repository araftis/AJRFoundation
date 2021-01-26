//
//  NSCoder+ExtensionsTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/27/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSCoder_ExtensionsTests : XCTestCase

@end

@implementation NSCoder_ExtensionsTests

- (void)testCoding {
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    NSRange range = (NSRange){1, 10};
    
    [archiver encodeObject:@{@"One":@(1)} forKey:@"dictionary"];
    [archiver encodeRange:range forKey:@"range"];
    [archiver encodeBool:YES forKey:@"boolean"];
    [archiver encodeInteger:0xdeadbeef forKey:@"integer"];
    [archiver encodeFloat:M_PI forKey:@"pi"];
    [archiver encodeDouble:M_PI / 2.0 forKey:@"half_pi"];
    [archiver finishEncoding];
    
    NSData *data = [archiver encodedData];
    NSError *localError;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&localError];
    unarchiver.requiresSecureCoding = NO;
    
    XCTAssert([unarchiver containsValueForKey:@"dictionary"]);
    NSDictionary *decodedDictionary = [unarchiver decodeObjectForKey:@"dictionary"];
    XCTAssert(decodedDictionary != nil);
    XCTAssert([unarchiver containsValueForKey:@"range"]);
    NSRange decodedRange = [unarchiver decodeRangeForKey:@"range"];
    XCTAssert(NSEqualRanges(range, decodedRange));
    
    XCTAssert([unarchiver decodeBoolForKey:@"boolean" defaultValue:NO] == YES);
    XCTAssert([unarchiver decodeBoolForKey:@"no_boolean" defaultValue:YES] == YES);
    XCTAssert([unarchiver decodeIntegerForKey:@"integer" defaultValue:0] == 0xdeadbeef);
    XCTAssert([unarchiver decodeIntegerForKey:@"no_integer" defaultValue:0xdeadbeef] == 0xdeadbeef);
    XCTAssert([unarchiver decodeFloatForKey:@"pi" defaultValue:0.0] == (float)M_PI);
    XCTAssert([unarchiver decodeFloatForKey:@"no_pi" defaultValue:M_PI] == (float)M_PI);
    XCTAssert([unarchiver decodeDoubleForKey:@"half_pi" defaultValue:0.0] == M_PI / 2.0);
    XCTAssert([unarchiver decodeDoubleForKey:@"no_half_pi" defaultValue:M_PI / 2.0] == M_PI / 2.0);
}

@end
