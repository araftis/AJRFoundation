//
//  AJRFractionFormatter.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 8/24/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import "AJRFractionFormatter.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSError+Extensions.h"

@implementation AJRFractionFormatter

- (id)init {
    if ((self = [super init])) {
        _minimumDenominator = 32;
    }
    return self;
}

#pragma mark - NSFormatter

- (NSString *)stringForObjectValue:(id)object {
    NSMutableString *string = [NSMutableString string];
    
    if (_prefix) {
        [string appendString:_prefix];
    }
    [string appendString:AJRFractionFromDouble([object doubleValue], (double)_minimumDenominator)];
    if (_suffix) {
        [string appendString:_suffix];
    }

    return string;
}

- (BOOL)getObjectValue:(__autoreleasing id *)obj forString:(NSString *)string errorDescription:(NSString *__autoreleasing *)error {
    static NSCharacterSet *dividerCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dividerCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"/⁄"];
    });
    NSScanner *scanner;
    NSInteger initial = 0, whole = 0, numerator = 0, denominator = 0;
    
    if (_prefix && [string hasPrefix:_prefix]) {
        string = [string substringFromIndex:[_prefix length]];
    }
    if (_suffix && [string hasSuffix:_suffix]) {
        string = [string substringToIndex:[string length] - [_suffix length]];
    }
    
    scanner = [[NSScanner alloc] initWithString:string];
    if ([scanner scanInteger:&initial]) {
        NSNumber *value;
        BOOL hadWhole = NO;
        
        if ([scanner scanCharactersFromSet:dividerCharacterSet intoString:NULL]) {
            // We didn't have a whole portion.
            numerator = initial;
            // This might not scan a number, which is OK, because then denominator will be 0, and we won't try to turn that into a value.
            [scanner scanInteger:&denominator];
        } else {
            // We did have a whole portion, apparently.
            whole = initial;
            hadWhole = YES;
            // We're only doing limited error checking in that as long as we scan an integer followed by the divider set, then we'll just try and scan the demominator. If that fails, the denominator is 0, which we won't try to change into a value.
            if ([scanner scanInteger:&numerator] && [scanner scanCharactersFromSet:dividerCharacterSet intoString:NULL]) {
                [scanner scanInteger:&denominator];
            }
        }
        
        if (denominator) {
            if (hadWhole) {
                value = @(copysign(fabs((double)whole) + ((double)numerator / (double)denominator), whole));
            } else {
                value = @(copysign(fabs((double)numerator / (double)denominator), numerator));
            }
        } else if (numerator == 0 && denominator == 0) {
            value = @(whole);
        }
                   
        if (value) {
            AJRSetOutParameter(obj, value);
            return YES;
        }
    }
    
    NSString *errorDescription = AJRFormat(@"Did find a valid fraction in string: %@", string);
    AJRSetOutParameter(error, errorDescription);
    
    return NO;
}

- (double)valueFromFraction:(NSString *)fraction error:(NSError **)error {
    NSNumber *value = nil;
    NSString *errorDescription;
    
    if ([self getObjectValue:&value forString:fraction errorDescription:&errorDescription]) {
        return value.doubleValue;
    } else {
        AJRSetOutParameter(error, [NSError errorWithDomain:NSCocoaErrorDomain message:errorDescription]);
        return NAN;
    }
}

- (NSString *)fractionFromValue:(double)value {
    return [self stringForObjectValue:@(value)];
}

@end
