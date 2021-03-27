
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
