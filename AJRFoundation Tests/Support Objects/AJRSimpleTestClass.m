//
//  AJRSimpleTestClass.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/29/19.
//

#import "AJRSimpleTestClass.h"

@implementation AJRSimpleTestClass

+ (id)objectWithStringValue:(NSString *)stringValue {
    return [(AJRSimpleTestClass *)[self alloc] initWithStringValue:stringValue];
}

+ (id)objectWithIntegerValue:(NSInteger)integerValue {
    return [(AJRSimpleTestClass *)[self alloc] initWithIntegerValue:integerValue];
}

+ (id)objectWithFloatValue:(float)floatValue {
    return [(AJRSimpleTestClass *)[self alloc] initWithFloatValue:floatValue];
}

+ (id)objectWithDoubleValue:(double)doubleValue {
    return [(AJRSimpleTestClass *)[self alloc] initWithDoubleValue:doubleValue];
}

+ (id)objectWithBOOLValue:(BOOL)boolValue {
    return [(AJRSimpleTestClass *)[self alloc] initWithBOOLValue:boolValue];
}

- (id)initWithStringValue:(NSString *)stringValue {
    if ((self = [super init])) {
        _stringValue = stringValue;
    }
    return self;
}

- (id)initWithIntegerValue:(NSInteger)integerValue {
    if ((self = [super init])) {
        _integerValue = integerValue;
    }
    return self;
}

- (id)initWithFloatValue:(float)floatValue {
    if ((self = [super init])) {
        _floatValue = floatValue;
    }
    return self;
}

- (id)initWithDoubleValue:(double)doubleValue {
    if ((self = [super init])) {
        _doubleValue = doubleValue;
    }
    return self;
}

- (id)initWithBOOLValue:(BOOL)boolValue {
    if ((self = [super init])) {
        _boolValue = boolValue;
    }
    return self;
}

- (void)setStringByConcatenating:(NSString *)first with:(NSString *)second {
    _stringValue = [first stringByAppendingString:second];
}

- (nonnull id)initWithPropertyListValue:(nonnull NSDictionary *)value error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (value[@"string"]) {
        if ([value[@"string"] isEqualToString:@"Three"]) {
            *error = [NSError errorWithDomain:NSInvalidArgumentException message:@"We don't like 'Three'. He's shifty."];
            return nil;
        }
        return [self initWithStringValue:value[@"string"]];
    }
    if (value[@"integer"]) {
        return [self initWithIntegerValue:[value[@"string"] integerValue]];
    }
    if (value[@"float"]) {
        return [self initWithFloatValue:[value[@"float"] floatValue]];
    }
    if (value[@"double"]) {
        return [self initWithDoubleValue:[value[@"double"] doubleValue]];
    }
    if (value[@"bool"]) {
        return [self initWithBOOLValue:[value[@"bool"] boolValue]];
    }
    return nil;
}

- (id)propertyListValue {
    NSMutableDictionary *value = [NSMutableDictionary dictionary];
    if (_stringValue) value[@"string"] = _stringValue;
    if (_integerValue != 0) value[@"integer"] = @(_integerValue);
    if (_floatValue != 0) value[@"float"] = @(_floatValue);
    if (_doubleValue != 0) value[@"double"] = @(_doubleValue);
    if (_boolValue) value[@"bool"] = @(_boolValue);
    return value;
}

- (BOOL)isEqual:(id)other {
    return ([self class] == [other class]
            && [_stringValue isEqual:((AJRSimpleTestClass *)other)->_stringValue]);
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"simpleTestClass";
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if (_stringValue) {
        [coder encodeString:_stringValue forKey:@"string"];
    }
    if (_integerValue != 0) {
        [coder encodeInteger:_integerValue forKey:@"integer"];
    }
    if (_floatValue != 0) {
        [coder encodeFloat:_floatValue forKey:@"float"];
    }
    if (_doubleValue != 0) {
        [coder encodeDouble:_doubleValue forKey:@"double"];
    }
    if (_boolValue) {
        [coder encodeBool:_boolValue forKey:@"bool"];
    }
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeStringForKey:@"string" setter:^(NSString *string) {
        self->_stringValue = string;
    }];
    [coder decodeIntegerForKey:@"integer" setter:^(NSInteger value) {
        self->_integerValue = value;
    }];
    [coder decodeFloatForKey:@"float" setter:^(float value) {
        self->_floatValue = value;
    }];
    [coder decodeDoubleForKey:@"double" setter:^(double value) {
        self->_doubleValue = value;
    }];
    [coder decodeBoolForKey:@"bool" setter:^(BOOL value) {
        self->_boolValue = value;
    }];
}

- (id)copyWithZone:(NSZone *)zone {
    AJRSimpleTestClass *copy = [[AJRSimpleTestClass alloc] init];
    
    copy->_stringValue = [_stringValue copyWithZone:zone];
    copy->_integerValue = _integerValue;
    copy->_floatValue = _floatValue;
    copy->_doubleValue = _doubleValue;
    copy->_boolValue = _boolValue;

    return copy;
}

@end

