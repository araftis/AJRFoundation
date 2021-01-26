//
//  AJRFractionFormatterTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 11/12/19.
//

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
    XCTAssert([formatter valueFromFraction:@"-1 1/2" error:&localError] == -1.5);
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

