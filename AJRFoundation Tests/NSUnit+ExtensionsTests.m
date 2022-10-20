/*
NSUnit+ExtensionsTests.m
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
