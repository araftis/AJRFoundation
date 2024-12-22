/*
 NSDate+XMLCoding.m
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

#import "NSDate+XMLCoding.h"

#import "AJRFunctions.h"
#import "AJRXMLCoder.h"
#import "NSError+Extensions.h"

static NSISO8601DateFormatter *AJRXMLDateFormatter(void) {
    static NSISO8601DateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSISO8601DateFormatter alloc] init];
        dateFormatter.formatOptions = NSISO8601DateFormatWithInternetDateTime;
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
    });
    return dateFormatter;
}

@interface AJRXMLDatePlaceHolder : NSObject <AJRXMLDecoding>

@property (nonatomic,strong) NSString *rawDate;

@end

@implementation NSDate (XMLCoding)

+ (NSString *)ajr_nameForXMLArchiving {
    return @"date";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSDate class];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLDatePlaceHolder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeString:[AJRXMLDateFormatter() stringFromDate:self] forKey:@"iso8601"];
}

@end

@implementation AJRXMLDatePlaceHolder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"iso8601" setter:^(NSString * _Nonnull string) {
        self->_rawDate = string;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    NSDate *date = nil;
    NSError *localError = nil;

    if (_rawDate != nil) {
        NSString *errorDescription;
        if (![AJRXMLDateFormatter() getObjectValue:&date forString:_rawDate errorDescription:&errorDescription]) {
            localError = [NSError errorWithDomain:AJRXMLCodingErrorDomain message:errorDescription];
        }
    }
    return AJRAssertOrPropagateError(date, error, localError);
}

@end
