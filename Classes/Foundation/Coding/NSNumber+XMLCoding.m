//
//  NSNumber+XMLCoding.m
//  AJRFoundation
//
//  Created by AJ Raftis on 9/22/19.
//

#import "AJRXMLArchiver.h"
#import "AJRXMLCoder.h"
#import "AJRXMLCoding.h"
#import "NSString+Extensions.h"

@interface AJRXMLNumberPlaceholder : NSObject <AJRXMLDecoding>
@property (nonatomic,strong) NSNumber *value;
@end

@implementation AJRXMLNumberPlaceholder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"value" setter:^(NSString *value) {
        self->_value = [value numberValue];
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    return _value;
}

@end

@implementation NSNumber (XMLCoding)

+ (NSString *)ajr_nameForXMLArchiving {
    return @"number";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSNumber class];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLNumberPlaceholder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeString:[self description] forKey:@"value"];
}

@end
