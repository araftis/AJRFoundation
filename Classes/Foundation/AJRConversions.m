
#import "AJRConversions.h"

#import "NSDate+Extensions.h"

NSArray *AJRArrayFromValue(id value) {
    NSArray *arrayValue;
    
    if ([value isKindOfClass:[NSArray class]]) {
        arrayValue = value;
    } else if ([value isKindOfClass:[NSString class]] && [value hasPrefix:@"("]) {
        arrayValue = [value propertyList];
    } else if (!value) {
        arrayValue = [NSArray array];
    } else {
        arrayValue = [NSArray arrayWithObject:value];
    }
    
    return arrayValue;
}

NSDictionary *AJRDictionaryFromValue(id value) {
    NSDictionary *dictionaryValue;
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        dictionaryValue = value;
    } else if ([value isKindOfClass:[NSString class]] && [value hasPrefix:@"{"]) {
        dictionaryValue = [value propertyList];
    } else if (!value) {
        dictionaryValue = [NSDictionary dictionary];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"%s value's class is '%@' not the required NSDictionary class", __PRETTY_FUNCTION__, [value class]];
        dictionaryValue = nil;
    }
    
    return dictionaryValue;
}

NSTimeInterval AJRTimeIntervalFromValue(id value, NSTimeInterval defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    NSTimeInterval timeInterval = defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        timeInterval = [value doubleValue];
    } else if (value) {
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        NSRange dotRange = [value rangeOfString:@"."];
        BOOL keepChecking = YES;
        
        if (dotRange.location != NSNotFound) {
            NSScanner *scanner = [NSScanner scannerWithString:value];
            double scannerTest;
            if ([scanner scanDouble:&scannerTest]) {
                timeInterval = scannerTest;
                keepChecking = NO;
            }
        }
        
        if (keepChecking) {
            NSScanner *scanner = [NSScanner scannerWithString:value];
            long long scannerTest;
            if ([scanner scanLongLong:&scannerTest]) {
                timeInterval = (double)scannerTest;
            }
        }
    }
    
    return timeInterval;
}

BOOL AJRBoolFromValue(id value, BOOL defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    BOOL boolValue = defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        boolValue = [value boolValue];
    } else if (value) {
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        boolValue = [(NSString *)value boolValue];
    }
    
    return boolValue;
}

NSString *AJRStringFromValue(id value, NSString * defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    NSString *stringValue = defaultValue;
    
    if ([value isKindOfClass:[NSString class]]) {
        stringValue = value;
    } else if (value) {
        stringValue = [value description];
    }
    
    return stringValue;
}

NSInteger AJRIntegerFromValue(id value, NSInteger defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    NSInteger integerValue = defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        integerValue = [value integerValue];
    } else if (value) {
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        if (![[NSScanner scannerWithString:value] scanInteger:&integerValue]) {
            integerValue = defaultValue;
        }
    }
    
    return integerValue;
}

long AJRLongFromValue(id value, long defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    long longValue = defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        longValue = [value longValue];
    } else if (value) {
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        long long temp;
        if (![[NSScanner scannerWithString: value] scanLongLong:&temp]) {
            longValue = defaultValue;
        } else {
            longValue = (long)temp;
        }
    }
    
    return longValue;
}

long long AJRLongLongFromValue(id value, long long defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    long long longLongValue = defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        longLongValue = [value longLongValue];
    } else if (value) {
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        if (![[NSScanner scannerWithString: value] scanLongLong:&longLongValue]) {
            longLongValue = defaultValue;
        }
    }
    
    return longLongValue;
}

long long AJRMillisecondsFromValue(id value, long long defaultValue) {
    if (!value) {
        return defaultValue;
    }
    
    long long longLongValue = defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        longLongValue = [value longLongValue];
    } else if ([value isKindOfClass:[NSDate class]]) {
        longLongValue = (long long)([value timeIntervalSince1970] * 1000);
    } else if (value) {
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        longLongValue = [NSDate millisecondsForTimePeriodString:value defaultValue:defaultValue];
    }
    
    return longLongValue;
}

