/*
 AJRMutableCaseInsensitiveDictionaryTests.m
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

@interface AJRMutableCaseInsensitiveDictionaryTests : XCTestCase

@end

@implementation AJRMutableCaseInsensitiveDictionaryTests

- (void)testAll {
    AJRMutableCaseInsensitiveDictionary *dictionary;
    
    dictionary = [[AJRMutableCaseInsensitiveDictionary alloc] init];
    [dictionary setObject:@"uno" forKey:@"One"];
    [dictionary setObject:@"dos" forKey:@"Two"];
    [dictionary setObject:@"tres" forKey:@(3)];

    XCTAssert([[dictionary objectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[dictionary objectForKey:@"two"] isEqualToString:@"dos"]);
    XCTAssert([[dictionary objectForKey:@(3)] isEqualToString:@"tres"]);
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]]) {
            XCTAssert([[dictionary objectForKey:[key uppercaseString]] isEqualToString:[dictionary objectForKey:key]]);
        }
    }];
    
    [dictionary removeObjectForKey:@(3)];
    [dictionary removeObjectForKey:@"one"];
    XCTAssert(dictionary.count == 1 && dictionary[@"two"] != nil);
    
    dictionary = [[AJRMutableCaseInsensitiveDictionary alloc] initWithCapacity:10];
    XCTAssert([dictionary isKindOfClass:AJRMutableCaseInsensitiveDictionary.class]);
    [dictionary setObject:@"uno" forKey:@"One"];
    XCTAssert(dictionary.count == 1 && dictionary[@"One"] != nil);

    id keys[] = { @"One", @"Two", @"Three" };
    id objects[] = { @"uno", @"dos", @"tres" };
    dictionary = [[AJRMutableCaseInsensitiveDictionary alloc] initWithObjects:objects forKeys:keys count:AJRCountOf(keys)];
    XCTAssert(dictionary.count == 3 && dictionary[@"One"] != nil);
}

@end
