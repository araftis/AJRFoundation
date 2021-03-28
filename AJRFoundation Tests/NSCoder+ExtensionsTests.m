/*
NSCoder+ExtensionsTests.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
