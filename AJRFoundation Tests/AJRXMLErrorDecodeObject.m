//
//  AJRXMLErrorDecodeObject.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/30/19.
//

#import "AJRXMLErrorDecodeObject.h"

@implementation AJRXMLErrorDecodeObject

- (id)initWithValue:(NSInteger)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"error-decode-object";
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeInteger:_value forKey:@"value"];
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeIntegerForKey:@"value" setter:^(NSInteger value) {
        if (value >= 16) {
            @throw [NSException exceptionWithName:@"ErrorException" reason:@"To force a failure in my unit tests." userInfo:nil];
        }
        self->_value = value;
    }];
}

- (BOOL)isEqual:(id)otherIn {
    AJRXMLErrorDecodeObject *other = AJRObjectIfKindOfClass(otherIn, AJRXMLErrorDecodeObject);
    return other != nil && _value == other->_value;
}

- (NSUInteger)hash {
    return @(_value).hash;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p: %d>", self, self, (int)_value);
}

@end
