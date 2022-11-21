/*
 AJRUnitsFormatter.m
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

#import "AJRUnitsFormatter.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRFractionFormatter.h"
#import "NSUnit+Extensions.h"

@implementation AJRUnitsFormatter {
    NSNumberFormatter *_formatter;
}

// MARK: - Utilities

- (NSNumberFormatter *)createNumberFormatter {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"#,##0.###"];
    [formatter setNegativeFormat:@"-#,##0.###"];
    return formatter;
}

- (NSNumberFormatter *)createFractionFormatter {
    return [[AJRFractionFormatter alloc] init];
}

- (NSUnit *)unitForLocale:(NSLocale *)locale {
    if (locale == nil) {
        locale = NSLocale.currentLocale;
    }
    if (locale == nil) {
        locale = NSLocale.systemLocale;
    }
    if ([[locale objectForKey:NSLocaleUsesMetricSystem] boolValue]) {
        return [NSUnitLength centimeters];
    }
    return [NSUnitLength inches];
}

// MARK: - Creation

- (id)init {
    if ((self = [super init])) {
        _units = [NSUnitLength points];
        _displayUnits = [self unitForLocale:NSLocale.currentLocale];
    }
    return self;
}

- (id)initWithUnits:(NSUnit *)units {
    if ((self = [super init])) {
        _units = units;
        _displayUnits = nil;
    }
    return self;
}

- (id)initWithUnits:(NSUnit *)units displayUnits:(NSUnit *)displayUnits {
    if ((self = [super init])) {
        _units = units;
        _displayUnits = displayUnits;
    }
    return self;
}

// MARK: - Properties

- (NSUnit *)displayUnits {
    return _displayUnits ?: _units;
}

- (NSNumberFormatter *)numberFormatter {
    if (_formatter == nil) {
        if (_displayInchesAsFrations && [self.displayUnits.identifier isEqualToString:@"inches"]) {
            _formatter = [self createFractionFormatter];
        } else {
            _formatter = [self createNumberFormatter];
        }
    }
    return _formatter;
}

// MARK: - Formatter

- (NSString *)stringForObjectValue:(id)obj {
    double value = [(NSNumber *)obj doubleValue];
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:self.units];
    measurement = [measurement measurementByConvertingToUnit:self.displayUnits];
    return AJRFormat(@"%@ %@", [self.numberFormatter stringFromNumber:@([measurement doubleValue])], [self.displayUnits symbol]);
}

- (BOOL)getObjectValue:(out id *)object forString:(NSString *)string errorDescription:(out NSString **)error {
    NSNumber *number = [self.numberFormatter numberFromString:string];

    if (number) {
        double value = number.doubleValue;
        NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:self.displayUnits];
        measurement = [measurement measurementByConvertingToUnit:self.units];
        *object = @([measurement doubleValue]);
        return YES;
    }
    return NO;
}

// MARK: - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %p: baseUnits: %@, displayUnits: %@>", self, self, [self.units identifier], [self.displayUnits identifier]);
}

@end
