/*
AJRPropertyListCoding.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "AJRPropertyListCoding.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSString+Extensions.h"
#import "NSData+Base64.h"
#import "NSDictionary+Extensions.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"

@implementation NSNumber (AJRPropertyListCoding)

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error
{
    NSError *localError = nil;
    self = [self init]; // Pretty much going to be ingored.
    NSNumber *result;
    const char *encoding = [[value stringForKey:@"encoding" defaultValue:@"i"] UTF8String];
    NSString *rawValue = [value objectForKey:@"value"];
    switch (encoding[0]) {
        case 'c': result = [NSNumber numberWithChar:[rawValue charValue]]; break;
        case 'C': result = [NSNumber numberWithUnsignedChar:[rawValue unsignedCharValue]]; break;
        case 's': result = [NSNumber numberWithShort:[rawValue shortValue]]; break;
        case 'S': result = [NSNumber numberWithUnsignedShort:[rawValue unsignedShortValue]]; break;
        case 'i': result = [NSNumber numberWithInt:[rawValue intValue]]; break;
        case 'I': result = [NSNumber numberWithUnsignedInt:[rawValue unsignedIntValue]]; break;
        case 'q': result = [NSNumber numberWithLongLong:[rawValue longLongValue]]; break;
        case 'Q': result = [NSNumber numberWithUnsignedLongLong:[rawValue unsignedLongLongValue]]; break;
        case 'f': {
            NSData *data = [NSData ajr_dataWithBase64EncodedString:rawValue error:NULL];
            NSSwappedFloat swappedFloat;
            memcpy(&swappedFloat, [data bytes], sizeof(NSSwappedFloat));
            result = [NSNumber numberWithFloat:NSSwapBigFloatToHost(swappedFloat)];
            break;
        }
        case 'd':{
            NSData *data = [NSData ajr_dataWithBase64EncodedString:rawValue error:NULL];
            NSSwappedDouble swappedDouble;
            memcpy(&swappedDouble, [data bytes], sizeof(NSSwappedDouble));
            result = [NSNumber numberWithDouble:NSSwapBigDoubleToHost(swappedDouble)];
            break;
        }
        default:
            // Punt;
            result = nil;
            localError = [NSError errorWithDomain:NSInvalidArgumentException format:@"Unknown number encoding: %s", encoding];
            break;
    }
    return AJRAssertOrPropagateError(result, error, localError);
}

- (id)propertyListValue
{
    id value = [self description];
    char encoding[2];
    strncpy(encoding, [self objCType], 1);
    if (encoding[0] == 'f') {
        NSSwappedFloat floatValue = NSSwapHostFloatToBig([self floatValue]);
        value = [NSData dataWithBytes:&floatValue length:sizeof(NSSwappedFloat)];
        value = [value ajr_base64EncodedString];
    } else if (encoding[0] == 'd') {
        NSSwappedDouble doubleValue = NSSwapHostDoubleToBig([self doubleValue]);
        value = [NSData dataWithBytes:&doubleValue length:sizeof(NSSwappedDouble)];
        value = [value ajr_base64EncodedString];
    } else if (encoding[0] == 's') {
        if ([self unsignedShortValue] <= UCHAR_MAX) {
            encoding[0] = 'C';
        }
    } else if (encoding[0] == 'i') {
        if ([self unsignedIntValue] <= USHRT_MAX) {
            encoding[0] = 'S';
        }
    } else if (encoding[0] == 'q') {
        if ([self unsignedLongLongValue] <= UINT_MAX) {
            encoding[0] = 'I';
        }
    }
    // Numbers don't necessarily encode to property lists correctly, so return a string representation of ourself.
    return @{@"type":@"NSNumber", @"value":value, @"encoding":[NSString stringWithUTF8String:encoding]};
}

@end

@implementation NSString (AJRPropertyListCoding)

- (id)initWithPropertyListValue:(id)value error:(NSError *__autoreleasing  _Nullable *)error
{
    if ([value isKindOfClass:[NSString class]]) {
        return [self initWithString:value];
    }
    return [self initWithString:[value objectForKey:@"value"]];
}

- (id)propertyListValue
{
    return @{@"type":@"NSString", @"value":self};
}

@end
