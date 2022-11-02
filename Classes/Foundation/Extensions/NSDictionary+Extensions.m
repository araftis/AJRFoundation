/*
 NSDictionary+Extensions.m
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

#import "NSDictionary+ExtensionsP.h"

#import "AJRConversions.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "NSArray+Extensions.h"
#import "NSMutableDictionary+Extensions.h"
#import "NSObject+Extensions.h"
#import "NSString+Extensions.h"

#import <objc/runtime.h>

typedef id ObjectType;
typedef id KeyType;

@implementation AJRXMLDictionaryPlaceholder

- (id)initWithFinalClass:(Class)finalClass {
    if ((self = [super init])) {
        _finalClass = finalClass;
        _max = 16;
        _index = 0;
        _objects = (id __strong *)NSZoneCalloc(NULL, _max, sizeof(id));
        _keys = (id __strong *)NSZoneCalloc(NULL, _max, sizeof(id));
    }
    return self;
}

- (void)dealloc {
    // Make sure these are freed. They usually are down in the finalizeXMLDecoding method, but if an error occurred, they could be sticking around.
    for (NSInteger x = 0; x < _index; x++) {
        _keys[x] = nil;
        _objects[x] = nil;
    }
    _index = 0;
    NSZoneFree(NULL, _keys);
    NSZoneFree(NULL, _objects);
}

- (void)appendKey:(id)key andObject:(id)object {
    if (_index >= _max) {
        NSInteger oldMax = _max;
        if (_max < 256) {
            _max = _max + _max;
        } else {
            _max += 128;
        }
        _keys = (id __strong *)NSZoneRealloc(NULL, _keys, _max * sizeof(id));
        _objects = (id __strong *)NSZoneRealloc(NULL, _objects, _max * sizeof(id));
        // Make sure to zero these, or we're going to crash when ARC tries to release a random pointer.
        memset(_keys + oldMax, 0, sizeof(id) * (_max - oldMax));
        memset(_objects + oldMax, 0, sizeof(id) * (_max - oldMax));
    }
    _keys[_index] = key;
    _objects[_index] = object;
    //AJRPrintf(@"%d: key: %@, object: %@\n", (int)_index, key, object);
    _index += 1;
    _key = nil;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeGroupForKey:@"entry" usingBlock:^{
        [coder decodeObjectForKey:@"key" setter:^(id object) {
            self->_key = object;
        }];
        [coder decodeObjectForKey:@"object" setter:^(id object) {
            [self appendKey:self->_key andObject:object];
        }];
    } setter:NULL];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    NSDictionary *result = [[_finalClass alloc] initWithObjects:_objects forKeys:_keys count:_index];
    // For now, give up ownership of the objects immediately. This can help with tracking down bugs.
    for (NSInteger x = 0; x < _index; x++) {
        _keys[x] = nil;
        _objects[x] = nil;
    }
    _index = 0;
    return result;
}

@end


@implementation AJRDictionaryLoader

typedef void (*AJRSetObjectForKeyIMP)(id self, SEL _cmd, id object, id <NSCopying>);
static AJRSetObjectForKeyIMP originalSetObjectForKey = NULL;

+ (void)load {
#if defined (AJR_DEBUG) || defined (AJR_UNIT_TESTING)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method1 = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:));
        if (method1) {
            Method method2 = class_getInstanceMethod(self, @selector(setObject:forKey:));
            if (method2) {
                originalSetObjectForKey = (AJRSetObjectForKeyIMP)method_getImplementation(method1);
                method_setImplementation(method1, method_getImplementation(method2));
            }
        }

        //AJRSwizzleMethods2(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:), self, @selector(ajr_setObject:forKey:));
    });
#endif
}

static void _AJRSetObjectNilObjectOrKey(id self, id object, id key) {
    AJRLog(nil, AJRLogLevelWarning, @"Attempt to insert nil object or key into dictionary. Break on _AJRSetObjectNilObjectOrKey() to debug.");
}

- (void)setObject:(id)object forKey:(id)key {
    if (object == nil || key == nil) {
        _AJRSetObjectNilObjectOrKey(self, object, key);
    }
    originalSetObjectForKey(self, _cmd, object, key);
}

@end


@implementation NSDictionary (Extensions)

- (id)objectForKey:(NSString *)key defaultValue:(id)defaultValue {
    id value = [self objectForKey:key];
    return value ? value : defaultValue;
}

- (id)objectForKeyPath:(NSString *)key defaultValue:(id)defaultValue {
    id value = [self valueForKeyPath:key];
    return value ? value : defaultValue;
}

- (CGRect)rectForKey:(NSString *)key defaultValue:(CGRect)value {
    NSString *string = [self objectForKey:key];
    if (string == nil) return value;
    return AJRRectFromString(string);
}

- (CGRect)rectForKeyPath:(NSString *)key defaultValue:(CGRect)value {
    NSString *string = [self valueForKeyPath:key];
    if (string == nil) return value;
    return AJRRectFromString(string);
}

- (CGSize)sizeForKey:(NSString *)key defaultValue:(CGSize)value {
    NSString *string = [self objectForKey:key];
    if (string == nil) return value;
    return AJRSizeFromString(string);
}

- (CGSize)sizeForKeyPath:(NSString *)key defaultValue:(CGSize)value {
    NSString *string = [self valueForKeyPath:key];
    if (string == nil) return value;
    return AJRSizeFromString(string);
}

- (CGPoint)pointForKey:(NSString *)key defaultValue:(CGPoint)value {
    NSString *string = [self objectForKey:key];
    if (string == nil) return value;
    return AJRPointFromString(string);
}

- (CGPoint)pointForKeyPath:(NSString *)key defaultValue:(CGPoint)value {
    NSString *string = [self valueForKeyPath:key];
    if (string == nil) return value;
    return AJRPointFromString(string);
}

- (NSRange)rangeForKey:(NSString *)key defaultValue:(NSRange)value {
    NSString *string = [self objectForKey:key];
    if (string == nil) return value;
    return NSRangeFromString(string);
}

- (NSRange)rangeForKeyPath:(NSString *)key defaultValue:(NSRange)value {
    NSString *string = [self valueForKeyPath:key];
    if (string == nil) return value;
    return NSRangeFromString(string);
}

- (id)arrayForKey:(NSString *)key {
    return [self arrayForKey:key defaultValue:nil];
}

- (id)arrayForKey:(NSString *)key defaultValue:(id)defaultValue {
    id value = [self objectForKey:key];
    if (value == nil) value = defaultValue;
    if (value != nil && ![value isKindOfClass:[NSArray class]]) {
        AJRLog(nil, AJRLogLevelWarning, @"Expected array value for key \"%@\" wasn't an array, but a %C.", key, value);
        value = defaultValue;
    }
    return value;
}

- (id)arrayForKeyPath:(NSString *)key defaultValue:(id)defaultValue {
    id value = [self valueForKeyPath:key];
    if (value == nil) value = defaultValue;
    if (value != nil && ![value isKindOfClass:[NSArray class]]) {
        AJRLog(nil, AJRLogLevelWarning, @"Expected array value for key \"%@\" wasn't an array, but a %C.", key, value);
        value = defaultValue;
    }
    return value;
}

- (id)dictionaryForKey:(NSString *)key {
    return [self dictionaryForKey:key defaultValue:nil];
}

- (id)dictionaryForKey:(NSString *)key defaultValue:(id)defaultValue {
    id value = [self objectForKey:key];
    if (value == nil) value = defaultValue;
    if (value != nil && ![value isKindOfClass:[NSDictionary class]]) {
        AJRLog(nil, AJRLogLevelWarning, @"Expected dictionary value for key \"%@\" wasn't a dictionary, but a %C.", key, value);
        value = defaultValue;
    }
    return value;
}

- (id)dictionaryForKeyPath:(NSString *)key defaultValue:(id)defaultValue {
    id value = [self valueForKeyPath:key];
    if (value == nil) value = defaultValue;
    if (value != nil && ![value isKindOfClass:[NSDictionary class]]) {
        AJRLog(nil, AJRLogLevelWarning, @"Expected dictionary value for key \"%@\" wasn't a dictionary, but a %C.", key, value);
        value = defaultValue;
    }
    return value;
}

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    return [self objectForKey:key] ?: defaultValue;
}

- (NSString *)stringForKeyPath:(NSString *)key defaultValue:(NSString *)defaultValue {
    return [self valueForKeyPath:key] ?: defaultValue;
}

- (NSTimeInterval)timeIntervalForKey:(NSString *)key defaultValue:(NSTimeInterval)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.doubleValue;
    }
    return [value description].timeIntervalValue;
}

- (NSTimeInterval)timeIntervalForKeyPath:(NSString *)key defaultValue:(NSTimeInterval)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    if ([value isKindOfClass:[NSNumber class]]) {
        return value.doubleValue;
    }
    return [[value description] timeIntervalValue];
}

- (long long)millisecondsForKey:(NSString *)key defaultValue:(long long)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value millisecondsValue];
}

- (long long)millisecondsForKeyPath:(NSString *)key defaultValue:(long long)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value millisecondsValue];
}

- (NSNumber *)numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    return [value numberValue];
}

- (NSNumber *)numberForKeyPath:(NSString *)key defaultValue:(NSNumber *)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    return [value numberValue];
}

- (char)charForKey:(NSString *)key defaultValue:(char)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return (char)[value integerValue];
}

- (char)charForKeyPath:(NSString *)key defaultValue:(char)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return (char)[value integerValue];
}

- (unsigned char)unsignedCharForKey:(NSString *)key defaultValue:(unsigned char)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return (unsigned char)[value unsignedIntegerValue];
}

- (unsigned char)unsignedCharForKeyPath:(NSString *)key defaultValue:(unsigned char)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return (unsigned char)[value unsignedIntegerValue];
}

- (short)shortForKey:(NSString *)key defaultValue:(short)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return (short)[value integerValue];
}

- (short)shortForKeyPath:(NSString *)key defaultValue:(short)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return (short)[value integerValue];
}

- (unsigned short)unsignedShortForKey:(NSString *)key defaultValue:(unsigned short)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return (unsigned short)[value unsignedIntegerValue];
}

- (unsigned short)unsignedShortForKeyPath:(NSString *)key defaultValue:(unsigned short)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return (unsigned short)[value unsignedIntegerValue];
}

- (int)intForKey:(NSString *)key defaultValue:(int)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value intValue];
}

- (int)intForKeyPath:(NSString *)key defaultValue:(int)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value intValue];
}

- (unsigned int)unsignedIntForKey:(NSString *)key defaultValue:(unsigned int)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value unsignedIntValue];
}

- (unsigned int)unsignedIntForKeyPath:(NSString *)key defaultValue:(unsigned int)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value unsignedIntValue];
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value integerValue];
}

- (NSInteger)integerForKeyPath:(NSString *)key defaultValue:(NSInteger)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value integerValue];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue
{
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value unsignedIntegerValue];
}

- (NSUInteger)unsignedIntegerForKeyPath:(NSString *)key defaultValue:(NSUInteger)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value unsignedIntegerValue];
}

- (long)longForKey:(NSString *)key defaultValue:(long)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value longValue];
}

- (long)longForKeyPath:(NSString *)key defaultValue:(long)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value longValue];
}

- (unsigned long)unsignedLongForKey:(NSString *)key defaultValue:(unsigned long)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value unsignedLongValue];
}

- (unsigned long)unsignedLongForKeyPath:(NSString *)key defaultValue:(unsigned long)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value unsignedLongValue];
}

- (long long)longLongForKey:(NSString *)key defaultValue:(long long)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value longLongValue];
}

- (long long)longLongForKeyPath:(NSString *)key defaultValue:(long long)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value longLongValue];
}

- (unsigned long long)unsignedLongLongForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value unsignedLongLongValue];
}

- (unsigned long long)unsignedLongLongForKeyPath:(NSString *)key defaultValue:(unsigned long long)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value unsignedLongLongValue];
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value boolValue];

}

- (BOOL)boolForKeyPath:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value boolValue];

}

- (float)floatForKey:(NSString *)key defaultValue:(float)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value floatValue];
}

- (float)floatForKeyPath:(NSString *)key defaultValue:(float)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value floatValue];
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value doubleValue];
}

- (double)doubleForKeyPath:(NSString *)key defaultValue:(double)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value doubleValue];
}

- (long double)longDoubleForKey:(NSString *)key defaultValue:(long double)defaultValue {
    NSString *value = [self objectForKey:key];
    if (!value) return defaultValue;
    return [value longDoubleValue];
}

- (long double)longDoubleForKeyPath:(NSString *)key defaultValue:(long double)defaultValue {
    NSString *value = [self valueForKeyPath:key];
    if (!value) return defaultValue;
    return [value longDoubleValue];
}

- (NSCharacterSet *)characterSetForKey:(NSString *)key defaultValue:(NSCharacterSet *)defaultValue {
    id raw = [self objectForKey:key];
    if (!raw) return defaultValue;
    if ([raw isKindOfClass:[NSCharacterSet class]]) {
        return (NSCharacterSet *)raw;
    }
    return [NSCharacterSet characterSetWithCharactersInString:[raw description]];
}

- (NSCharacterSet *)characterSetForKeyPath:(NSString *)key defaultValue:(NSCharacterSet *)defaultValue {
    id raw = [self valueForKeyPath:key];
    if (!raw) return defaultValue;
    if ([raw isKindOfClass:[NSCharacterSet class]]) {
        return (NSCharacterSet *)raw;
    }
    return [NSCharacterSet characterSetWithCharactersInString:[raw description]];
}

- (NSDictionary *)subdictionaryForKeys:(NSArray *)keys {
    return [self subdictionaryForKeys:keys missingValue:nil];
}

- (NSDictionary *)subdictionaryForKeys:(NSArray *)keys missingValue:(id)missingValue {
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:[keys count]];

    for (NSString *key in keys) {
        [returnDictionary setObjectIfNotNil:[self objectForKey:key] ?: missingValue forKey:key];
    }

    return returnDictionary;
}

- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)fromDictionary {
    if (!fromDictionary) {
        return self;
    }

    NSMutableDictionary *mutableDictionary = [self mutableCopy];
    [mutableDictionary addEntriesFromDictionary:fromDictionary];

    return mutableDictionary;
}

- (NSDictionary *)dictionaryByRemovingObjectForKey:(NSString *)key {
    NSMutableDictionary *mutableDictionary = [self mutableCopy];
    [mutableDictionary removeObjectForKey:key];
    return mutableDictionary;
}

- (NSDictionary *)dictionaryBySettingObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *mutableDict = [self mutableCopy];
    [mutableDict setObject:object forKey:key];
    return mutableDict;
}

- (id)objectForKey:(id)childKey inDictionaryForKey:(KeyType<NSCopying>)topKey {
    return [[self objectForKey:topKey] objectForKey:childKey];
}

#pragma mark - AJRXMLCoding

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLDictionaryPlaceholder alloc] initWithFinalClass:[self ajr_classForXMLArchiving]];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        [coder encodeGroupForKey:@"entry" usingBlock:^{
            [coder encodeObject:key forKey:@"key"];
            [coder encodeObject:object forKey:@"object"];
        }];
    }];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"dictionary";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSDictionary class];
}

#pragma mark - Invalidation

- (void)invalidateObjects {
    for (id <AJRInvalidation> object in self.objectEnumerator) {
        if ([object conformsToProtocol:@protocol(AJRInvalidation)]) {
            [object invalidate];
        }
    }
}

@end

@implementation NSMutableDictionary (AJRXMLCoding)

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-dictionary";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSMutableDictionary class];
}

@end
