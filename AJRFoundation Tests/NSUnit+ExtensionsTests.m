
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSUnit_ExtensionsTests : XCTestCase

@end

@implementation NSUnit_ExtensionsTests

- (void)testClasses {
    NSSet<Class> *classes = NSUnit.unitClasses;
    
    XCTAssert(classes.count != 0);
    for (Class class in classes) {
        while (class != Nil && class != NSUnit.class) {
            class = [class superclass];
        }
        XCTAssert(class == NSUnit.class);
    }
    
    NSArray<Class> *expected = @[[NSUnitAcceleration class], [NSUnitAngle class], [NSUnitArea class], [NSUnitConcentrationMass class], [NSUnitDispersion class], [NSUnitDuration class], [NSUnitElectricCharge class], [NSUnitElectricCurrent class], [NSUnitElectricPotentialDifference class], [NSUnitElectricResistance class], [NSUnitEnergy class], [NSUnitFrequency class], [NSUnitFuelEfficiency class], [NSUnitLength class], [NSUnitIlluminance class], [NSUnitMass class], [NSUnitPower class], [NSUnitPressure class], [NSUnitSpeed class], [NSUnitTemperature class], [NSUnitVolume class]];
    for (Class class in expected) {
        XCTAssert([classes containsObject:class]);
    }
}

- (void)testIdentifiers {
    NSMutableSet<NSString *> *allUnits = [NSUnit.unitIdentifiers mutableCopy];
    
    for (Class unitClass in NSUnit.unitClasses) {
        if ([unitClass isSubclassOfClass:[NSDimension class]]) {
            NSUnit *unit = [unitClass baseUnit];
            AJRPrintf(@"%C: %@\n", unitClass, unit.identifier);
            XCTAssert(unit.identifier != nil);
            XCTAssert([NSUnit unitForIdentifier:unit.identifier] == unit);
        }
        
        NSSet<NSString *> *subunits = [unitClass unitIdentifiers];
        XCTAssert(subunits.count != 0);
        for (NSString *subunit in subunits) {
            NSUnit *unit = [NSUnit unitForIdentifier:subunit];
            XCTAssert(unit != nil);
            XCTAssert(unit.localizedName != nil);
            XCTAssert([allUnits containsObject:subunit]);
            [allUnits removeObject:subunit];
        }
    }
    XCTAssert(allUnits.count == 0, @"We expected no remaining units, but we still have: %@", [[allUnits allObjects] componentsJoinedByString:@", " twoValueSeparator:@" and " finalSeparator:@", and "]);
}

@end
