/*
AJRConversions.m
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

