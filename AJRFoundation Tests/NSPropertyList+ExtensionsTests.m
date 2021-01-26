//
//  NSPropertyListTest.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/5/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <Foundation/NSDebug.h>
#import <XCTest/XCTest.h>

@interface NSPropertyListTest : XCTestCase

@end

@implementation NSPropertyListTest

- (void)testPropertyListSerialization {
    NSZombieEnabled = YES;
    NSDeallocateZombies = NO;

    @autoreleasepool {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"two", @"three", @"four", nil];
        NSData *intermediate;
        NSDictionary *decoded;
        NSPropertyListFormat format;
        NSError *error;
        
        intermediate = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
        XCTAssertTrue(intermediate != nil, @"Failed to serialize test property list: %@", [error localizedDescription]);
        
        decoded = [NSPropertyListSerialization propertyListWithData:intermediate options:0 format:&format error:&error];
        XCTAssertTrue(decoded != nil, @"Failed to deserialize test property list: %@", [error localizedDescription]);
        XCTAssertTrue(format == NSPropertyListXMLFormat_v1_0, @"Property list wasn't in XML format: %lu", format);
    }
}

@end
