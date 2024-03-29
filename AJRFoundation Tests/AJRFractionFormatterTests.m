/*
 AJRFractionFormatterTests.m
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

@interface AJRFractionFormatterTests : XCTestCase

@end

@implementation AJRFractionFormatterTests

- (void)testFormatring {
    NSError *localError;
    AJRFractionFormatter *formatter = [[AJRFractionFormatter alloc] init];
    
    XCTAssert([formatter valueFromFraction:@"1/2" error:&localError] == 0.5);
    XCTAssert([formatter valueFromFraction:@"-1/2" error:&localError] == -0.5);
    XCTAssert([formatter valueFromFraction:@"1" error:&localError] == 1.0);
    XCTAssert([formatter valueFromFraction:@"-1" error:&localError] == -1.0);
    XCTAssert([formatter valueFromFraction:@"1 1/2" error:&localError] == 1.5);
    XCTAssert([formatter valueFromFraction:@"-1 1/2" error:&localError] == -1.5);
    XCTAssert([formatter valueFromFraction:@"1½" error:&localError] == 1.5);
    XCTAssert([formatter valueFromFraction:@"-1½" error:&localError] == -1.5);
    XCTAssert([formatter valueFromFraction:@"1 ½" error:&localError] == 1.5);
    XCTAssert([formatter valueFromFraction:@"-1 ½" error:&localError] == -1.5);
    XCTAssert([formatter valueFromFraction:@"-1 1/2" error:&localError] == -1.5);
    XCTAssert([formatter valueFromFraction:@"1.5" error:&localError] == 1.5);
    XCTAssert([formatter valueFromFraction:@"-1.5" error:&localError] == -1.5);
    XCTAssert([formatter valueFromFraction:@"1.5 1/2" error:&localError] == 2.0);
    XCTAssert([formatter valueFromFraction:@"-1.5 1/2" error:&localError] == -2.0);
    XCTAssert(isnan([formatter valueFromFraction:@"bad" error:&localError]) && localError != nil);
    
    formatter.prefix = @"test";
    formatter.suffix = @"picas";
    XCTAssert([formatter valueFromFraction:@"test 1/2 picas" error:&localError] == 0.5);
    
    // NOTE: We're only doing limited testing here, because we're mostly concerned with the API of AJRFractionFormatter. We more thoroughly test fraction to string conversion in AJRFractionTests.m
    XCTAssert([[formatter fractionFromValue:0.5] isEqualToString:@"test¹⁄₂picas"]);
    formatter.prefix = nil;
    formatter.suffix = nil;
    XCTAssert([[formatter fractionFromValue:0.5] isEqualToString:@"¹⁄₂"]);
}

@end

