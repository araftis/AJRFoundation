//
//  NSDate+XMLCoding.m
//  AJRFoundation
//
//  Created by AJ Raftis on 1/15/21.
//

#import "NSDate+XMLCoding.h"

#import "AJRFunctions.h"
#import "AJRXMLCoder.h"
#import "NSError+Extensions.h"

static NSISO8601DateFormatter *AJRXMLDateFormatter() {
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
