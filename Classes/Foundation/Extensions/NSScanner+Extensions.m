/*
 NSScanner+Extensions.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import "NSScanner+Extensions.h"

#import "AJRFunctions.h"

// These are used by the date scanning stuff.
typedef struct __ajr_date_spellings {
    __unsafe_unretained NSString *month;
    NSInteger index;
    AJRDateSegmentStringType type;
} _ajrDateSpellings;

static _ajrDateSpellings dateSpellings[] = {
    { @"jan", 1, AJRDateSegmentStringTypeMonth }, { @"ja", 1, AJRDateSegmentStringTypeMonth }, { @"jna", 1, AJRDateSegmentStringTypeMonth },
    { @"feb", 2, AJRDateSegmentStringTypeMonth }, { @"fe", 2, AJRDateSegmentStringTypeMonth }, { @"fbe", 2, AJRDateSegmentStringTypeMonth }, { @"fb", 2, AJRDateSegmentStringTypeMonth },
    { @"mar", 3, AJRDateSegmentStringTypeMonth }, { @"mra", 3, AJRDateSegmentStringTypeMonth }, { @"mr", 3, AJRDateSegmentStringTypeMonth },
    { @"apr", 4, AJRDateSegmentStringTypeMonth }, { @"ap", 4, AJRDateSegmentStringTypeMonth }, { @"arp", 4, AJRDateSegmentStringTypeMonth }, { @"ar", 4, AJRDateSegmentStringTypeMonth },
    { @"may", 5, AJRDateSegmentStringTypeMonth }, { @"my", 5, AJRDateSegmentStringTypeMonth }, { @"mya", 5, AJRDateSegmentStringTypeMonth }, { @"my", 5, AJRDateSegmentStringTypeMonth },
    { @"jun", 6, AJRDateSegmentStringTypeMonth }, { @"jn", 6, AJRDateSegmentStringTypeMonth }, { @"jnu", 6, AJRDateSegmentStringTypeMonth },
    { @"jul", 7, AJRDateSegmentStringTypeMonth }, { @"jl", 7, AJRDateSegmentStringTypeMonth }, { @"jlu", 7, AJRDateSegmentStringTypeMonth }, { @"jly", 7, AJRDateSegmentStringTypeMonth },
    { @"aug", 8, AJRDateSegmentStringTypeMonth }, { @"au", 8, AJRDateSegmentStringTypeMonth }, { @"agu", 8, AJRDateSegmentStringTypeMonth }, { @"ag", 8, AJRDateSegmentStringTypeMonth },
    { @"sep", 9, AJRDateSegmentStringTypeMonth }, { @"se", 9, AJRDateSegmentStringTypeMonth }, { @"spe", 9, AJRDateSegmentStringTypeMonth }, { @"sp", 9, AJRDateSegmentStringTypeMonth },
    { @"oct", 10, AJRDateSegmentStringTypeMonth }, { @"oc", 10, AJRDateSegmentStringTypeMonth }, { @"otc", 10, AJRDateSegmentStringTypeMonth }, { @"ot", 10, AJRDateSegmentStringTypeMonth },
    { @"nov", 11, AJRDateSegmentStringTypeMonth }, { @"no", 11, AJRDateSegmentStringTypeMonth }, { @"nvo", 11, AJRDateSegmentStringTypeMonth }, { @"nv", 11, AJRDateSegmentStringTypeMonth },
    // 8/25/99 AJR (4932) Somehow a '1' got entered where the '12' should be.
    { @"dec", 12, AJRDateSegmentStringTypeMonth }, { @"de", 12, AJRDateSegmentStringTypeMonth }, { @"dce", 12, AJRDateSegmentStringTypeMonth }, { @"dc", 12, AJRDateSegmentStringTypeMonth },
    
    { @"mon", 1, AJRDateSegmentStringTypeDayOfWeek }, { @"mo", 1, AJRDateSegmentStringTypeDayOfWeek }, { @"mno", 1, AJRDateSegmentStringTypeDayOfWeek },
    { @"tue", 2, AJRDateSegmentStringTypeDayOfWeek }, { @"tu", 2, AJRDateSegmentStringTypeDayOfWeek }, { @"teu", 2, AJRDateSegmentStringTypeDayOfWeek },
    { @"wed", 3, AJRDateSegmentStringTypeDayOfWeek }, { @"we", 3, AJRDateSegmentStringTypeDayOfWeek }, { @"wde", 3, AJRDateSegmentStringTypeDayOfWeek },
    { @"thu", 4, AJRDateSegmentStringTypeDayOfWeek }, { @"th", 4, AJRDateSegmentStringTypeDayOfWeek }, { @"tuh", 4, AJRDateSegmentStringTypeDayOfWeek },
    { @"fri", 5, AJRDateSegmentStringTypeDayOfWeek }, { @"fr", 5, AJRDateSegmentStringTypeDayOfWeek }, { @"fir", 5, AJRDateSegmentStringTypeDayOfWeek },
    { @"sat", 6, AJRDateSegmentStringTypeDayOfWeek }, { @"sa", 6, AJRDateSegmentStringTypeDayOfWeek }, { @"sta", 6, AJRDateSegmentStringTypeDayOfWeek },
    { @"sun", 7, AJRDateSegmentStringTypeDayOfWeek }, { @"su", 7, AJRDateSegmentStringTypeDayOfWeek }, { @"snu", 7, AJRDateSegmentStringTypeDayOfWeek }
};

@implementation NSScanner (AJRExtensions)

- (BOOL)scanStringDelimitedBy:(NSString *)delimiter into:(NSString * _Nullable * _Nullable)string {
    NSCharacterSet *skippedSave = [self charactersToBeSkipped];
    NSString *substring = nil;
    
    if (self.isAtEnd) {
        // If we're at the of the string, just return NO, since there's nothing to scan. This allows the caller to set up a fairly simple while loop to scan all the fields of a CSV file.
        return NO;
    }
    
    // Try to scan a quote, and if we do, treat the field as quoted.
    if ([self scanString:@"\"" intoString:nil]) {
        NSMutableString *build = [NSMutableString string];
        
        // We'll have (maybe) ignored whitespace up to the point, but now that we're in the quoted string, we don't want to ignore it, as all characters within the quotes are relevant, whether we're being permissive or not.
        [self setCharactersToBeSkipped:nil];
        while (1) {
            if ([self scanUpToString:@"\"" intoString:&substring]) {
                [build appendString:substring];
            }
            // Skip over the quote we just scanned up to.
            [self scanString:@"\"" intoString:nil];
            // But check and see if we can scan another quote.
            if ([self scanString:@"\"" intoString:nil]) {
                // We did have a second quote, so append it to the output and try to scan another fragment.
                [build appendString:@"\""];
            } else {
                // We didn't have a second quote, so we're done.
                break;
            }
        }
        // We're going to be permissive, and scan over anything trailing the quote. The spec says this shouldn't necessary, but it also says we should be forgiving of CSV from the outside world.
        [self scanUpToString:delimiter intoString:NULL];
        // And scan the delimiter, which means we're up for the next character.
        [self scanString:delimiter intoString:nil];
        
        // And set the substring...
        substring = build;
    } else {
        // We're not quoted, so we'll just scan up to the next comma. CSV considers whitespace as part of the field, so set the skip set to nil.
        [self setCharactersToBeSkipped:nil];
        // And then scan up to the next delimiter, or the end of the string.
        if ([self scanUpToString:delimiter intoString:&substring]) {
        } else {
            // The field was empty.
            substring = @"";
        }
        if (![self isAtEnd]) {
            // And if we're not at the end of the string, then scan the delimiter.
            [self scanString:delimiter intoString:nil];
        }
    }
    
    // Be nice and restore the developer's previous skip set.
    [self setCharactersToBeSkipped:skippedSave];
    
    AJRSetOutParameter(string, substring == nil ? @"" : substring);
    return YES;
}

- (BOOL)scanCommaDelimitedString:(NSString * _Nullable * _Nullable)string {
    return [self scanStringDelimitedBy:@"," into:string];
}

- (BOOL)scanDateSegment:(NSInteger *)number {
    return [self scanDateSegment:number segmentType:NULL];
}

- (BOOL)scanDateSegment:(NSInteger *)number segmentType:(AJRDateSegmentStringType *)segmentType {
    static NSCharacterSet *goodSet = nil;
    static NSCharacterSet *skipSet = nil;
    static NSCharacterSet *numberSet = nil;
    static NSCharacterSet *alphaSet = nil;
    static NSCharacterSet *emptySet = nil;
    NSCharacterSet *origSkipSet = [self charactersToBeSkipped];
    NSUInteger location, x;
    NSString *work;
    NSString *current = [self string];
    NSUInteger max = [current length];
    
    // These are the character sets we're gunna need. There are all declared static, so we
    // won't need to recreate them each time. Course, we gotta retain them.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alphaSet = [NSCharacterSet letterCharacterSet];
        numberSet = [NSCharacterSet decimalDigitCharacterSet];
        goodSet = [NSCharacterSet alphanumericCharacterSet];
        skipSet = [goodSet invertedSet];
        emptySet = [[NSCharacterSet alloc] init];
    });
    
    AJRSetOutParameter(segmentType, AJRDateSegmentStringTypeNumeric);
    AJRSetOutParameter(number, NSNotFound);
    
    [self setCharactersToBeSkipped:emptySet];
    while (![self isAtEnd]) {
        // First, let's skip over any comma or white space.
        [self scanCharactersFromSet:skipSet intoString:NULL];
        location = [self scanLocation];
        if (location >= max) break;
        if ([alphaSet characterIsMember:[current characterAtIndex:location]]) {
            AJRSetOutParameter(segmentType, AJRDateSegmentStringTypeInvalid);
            [self scanCharactersFromSet:goodSet intoString:&work];
            work = [work lowercaseString];
            for (x = 0; x < sizeof(dateSpellings) / sizeof(_ajrDateSpellings); x++) {
                if ([work hasPrefix:dateSpellings[x].month]) {
                    AJRSetOutParameter(number, dateSpellings[x].index);
                    [self setCharactersToBeSkipped:origSkipSet];
                    if (segmentType) *segmentType = dateSpellings[x].type;
                    return YES;
                }
            }
            AJRSetOutParameter(segmentType, AJRDateSegmentStringTypeInvalid);
            return YES;
        } else {
            if ([self scanInteger:number]) {
                [self setCharactersToBeSkipped:origSkipSet];
                return YES;
            }
        }
    }
    
    [self setCharactersToBeSkipped:origSkipSet];
    
    return NO;
}

static NSCharacterSet *_ajrOctalDigitSet = nil;

- (BOOL)scanOctalInteger:(NSInteger *)octal {
    NSCharacterSet *skippers;
    NSString *string;
    NSInteger length, location;
    NSInteger result = 0;
    unichar character;
    BOOL returnValue = NO, negate = NO;
    
    if (!_ajrOctalDigitSet) {
        _ajrOctalDigitSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567"];
    }
    
    string = [self string];
    length = [string length];
    location = [self scanLocation];
    skippers = [self charactersToBeSkipped];
    if (skippers) {
        while ((location < length) && [skippers characterIsMember:[string characterAtIndex:location]]) {
            location++;
        }
    }
    
    if (location < length) {
        character = [string characterAtIndex:location];
        if (character == '-') {
            negate = YES;
            location++;
        } else if (character == '+') {
            location++;
        }
    }
    while ((location < length) && [_ajrOctalDigitSet characterIsMember:character = [string characterAtIndex:location]]) {
        result = (result * 8) + (character - '0');
        returnValue = YES;
        location++;
    }
    
    [self setScanLocation:location];
    if (octal) {
        *octal = result * (negate ? -1 : 1);
    }
    
    return returnValue;
}

- (BOOL)scanSize:(out CGSize *)sizeOut {
    CGSize size = CGSizeZero;
    BOOL success = NO;

#if defined(AJRFoundation_MacOSX)
    success = ([self scanString:@"{" intoString:NULL] &&
               [self scanDouble:&size.width] &&
               [self scanString:@"," intoString:NULL] &&
               [self scanDouble:&size.height] &&
               [self scanString:@"}" intoString:NULL]);
#elif defined (AJRFoundation_iOS)
    double width = 0.0, height = 0.0;
    success = ([self scanString:@"{" intoString:NULL] &&
               [self scanDouble:&width] &&
               [self scanString:@"," intoString:NULL] &&
               [self scanDouble:&height] &&
               [self scanString:@"}" intoString:NULL]);
#endif
    if (success) {
        AJRSetOutParameter(sizeOut, size);
    }
    return success;
}

- (BOOL)scanPoint:(out CGPoint *)pointOut {
    CGPoint point = CGPointZero;
    BOOL success = NO;
    
#if defined(AJRFoundation_MacOSX)
    success = ([self scanString:@"{" intoString:NULL] &&
               [self scanDouble:&point.x] &&
               [self scanString:@"," intoString:NULL] &&
               [self scanDouble:&point.y] &&
               [self scanString:@"}" intoString:NULL]);
#elif defined (AJRFoundation_iOS)
    double x = 0.0, y = 0.0;
    success = ([self scanString:@"{" intoString:NULL] &&
               [self scanDouble:&x] &&
               [self scanString:@"," intoString:NULL] &&
               [self scanDouble:&y] &&
               [self scanString:@"}" intoString:NULL]);
#endif
    if (success) {
        AJRSetOutParameter(pointOut, point);
    }
    return success;
}

- (BOOL)scanRect:(CGRect *)rectOut {
    CGRect rect = CGRectZero;
    BOOL result = ([self scanString:@"{" intoString:NULL] &&
                   [self scanPoint:&rect.origin] &&
                   [self scanString:@"," intoString:NULL] &&
                   [self scanSize:&rect.size] &&
                   [self scanString:@"}" intoString:NULL]);

    if (result) {
        AJRSetOutParameter(rectOut, rect);
    }
    
    return result;
}

@end
