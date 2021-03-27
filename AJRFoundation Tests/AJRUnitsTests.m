
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/NSUnit+Extensions.h>

@interface AJRUnitsTests : XCTestCase

@end

@implementation AJRUnitsTests

- (void)testUnitsFromString {
    XCTAssert([[[NSUnitLength meters] identifier] isEqualToString:@"meters"]);
    XCTAssert([[[NSUnitLength points] identifier] isEqualToString:@"points"]);
}

- (void)testMeasurement {
    NSUnit *baseUnits = [NSUnitLength points];
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:72.0 unit:baseUnits];
    measurement = [measurement measurementByConvertingToUnit:[NSUnitLength inches]];
    XCTAssert(AJRRoundToPlaces([measurement doubleValue], 5) == 1.0, @"Expected 1 inch, got %f != %f", AJRRoundToPlaces([measurement doubleValue], 5), [measurement doubleValue]);
}

@end
