/*
NSPropertyList+ExtensionsTests.m
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
