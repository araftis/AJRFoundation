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

#import "NSUnit+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>

@implementation AJRUnitsFormatter {
    NSNumberFormatter *_formatter;
}

- (void)ajr_commonInit {
    _formatter = [[NSNumberFormatter alloc] init];
    [_formatter setPositiveFormat:@"#,##0.###"];
    [_formatter setNegativeFormat:@"-#,##0.###"];
}

- (id)init {
    if ((self = [super init])) {
        [self ajr_commonInit];
        _units = [NSUnitLength points];
        _displayUnits = [NSUnitLength inches];
    }
    return self;
}

- (id)initWithUnits:(NSUnit *)units displayUnits:(NSUnit *)displayUnits {
    if ((self = [super init])) {
        [self ajr_commonInit];
        _units = units;
        _displayUnits = displayUnits;
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)obj {
    double value = [(NSNumber *)obj doubleValue];
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:_units];
    measurement = [measurement measurementByConvertingToUnit:_displayUnits];
    return AJRFormat(@"%@ %@", [_formatter stringFromNumber:@([measurement doubleValue])], [_displayUnits symbol]);
}

- (BOOL)getObjectValue:(out id *)object forString:(NSString *)string errorDescription:(out NSString **)error {
    double value = [string doubleValue];
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:value unit:_displayUnits];
    measurement = [measurement measurementByConvertingToUnit:_units];
    *object = @([measurement doubleValue]);
    return YES;
}

#pragma mark - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %p: baseUnits: %@, displayUnits: %@>", self, self, [_units identifier], [_displayUnits identifier]);
}

@end
