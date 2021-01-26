//
//  NSMutableDictionary+Extensions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "NSMutableDictionary+Extensions.h"

#import "AJRConversions.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"

typedef id ObjectType;
typedef id KeyType;

extern BOOL _CFDictionaryIsMutable(CFDictionaryRef dictionary);

@implementation NSMutableDictionary (Extensions)

- (void)setBool:(BOOL)value forKey:(id)key {
    [self setObject:value ? @"YES" : @"NO" forKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(id)key {
    [self setObject:AJRFormat(@"%ld", value) forKey:key];
}

- (void)setUnsignedInteger:(NSUInteger)value forKey:(id)key {
    [self setObject:AJRFormat(@"%lu", value) forKey:key];
}

- (void)setChar:(char)value forKey:(id)key {
    [self setObject:AJRFormat(@"%d", value) forKey:key];
}

- (void)setUnsignedChar:(unsigned char)value forKey:(id)key {
    [self setObject:AJRFormat(@"%u", value) forKey:key];
}

- (void)setShort:(short)value forKey:(id)key {
    [self setObject:AJRFormat(@"%d", value) forKey:key];
}

- (void)setUnsignedShort:(unsigned short)value forKey:(id)key {
    [self setObject:AJRFormat(@"%u", value) forKey:key];
}

- (void)setInt:(int)value forKey:(id)key {
    [self setObject:AJRFormat(@"%d", value) forKey:key];
}

- (void)setUnsignedInt:(unsigned int)value forKey:(id)key {
    [self setObject:AJRFormat(@"%u", value) forKey:key];
}

- (void)setLong:(long)value forKey:(id)key {
    [self setObject:AJRFormat(@"%ld", value) forKey:key];
}

- (void)setUnsignedLong:(unsigned long)value forKey:(id)key {
    [self setObject:AJRFormat(@"%lu", value) forKey:key];
}

- (void)setLongLong:(long long)value forKey:(id)key {
    [self setObject:AJRFormat(@"%lld", value) forKey:key];
}

- (void)setUnsignedLongLong:(unsigned long long)value forKey:(id)key {
    [self setObject:AJRFormat(@"%llu", value) forKey:key];
}

- (void)setFloat:(float)value forKey:(id)key {
    [self setObject:AJRFormat(@"%g", value) forKey:key];
}

- (void)setDouble:(double)value forKey:(id)key {
    [self setObject:AJRFormat(@"%g", value) forKey:key];
}

- (void)setLongDouble:(long double)value forKey:(id)key {
    [self setObject:AJRFormat(@"%Lg", value) forKey:key];
}

- (void)setRect:(CGRect)value forKey:(id)key {
    [self setObject:AJRStringFromRect(value) forKey:key];
}

- (void)setSize:(CGSize)value forKey:(id)key {
    [self setObject:AJRStringFromSize(value) forKey:key];
}

- (void)setPoint:(CGPoint)value forKey:(id)key {
    [self setObject:AJRStringFromPoint(value) forKey:key];
}

- (void)setRange:(NSRange)value forKey:(id)key {
    [self setObject:NSStringFromRange(value) forKey:key];
}

- (void)addInteger:(NSNumber *)integer toKey:(NSString *)key {
    NSNumber *value = self[key];
    
    if (value == nil) {
		self[key] = @(integer.integerValue);
    } else {
		self[key] = @(integer.integerValue + value.integerValue);
    }
}

- (void)addDouble:(NSNumber *)doubleValue toKey:(NSString *)key {
    NSNumber *value = [self objectForKey:key];
    
    if (value == nil) {
		self[key] = @(doubleValue.doubleValue);
    } else {
		self[key] = @(value.doubleValue + doubleValue.doubleValue);
    }
}

- (void)setObjectIfNotNil:(ObjectType)object forKey:(KeyType<NSCopying>)key {
    if (object != 0) {
        [self setObject:object forKey:key];
    }
}

- (void)addObject:(id)object toArrayForKey:(id <NSCopying>)key {
	return [self addObject:object toArrayForKey:key arrayCreator:^NSMutableArray * _Nonnull{
		return [NSMutableArray array];
	}];
}

- (void)addObject:(ObjectType)object toArrayForKey:(KeyType<NSCopying>)key arrayCreator:(NSMutableArray<ObjectType> * (^)(void))creationBlock {
    NSMutableArray *array = self[key];
    if (array == nil) {
        array = creationBlock();
        self[key] = array;
    }
    [array addObject:object];
}

- (void)addObject:(id)object toSetForKey:(id <NSCopying>)key {
	[self addObject:object toSetForKey:key setCreator:^NSMutableSet * _Nonnull{
		return [NSMutableSet set];
	}];
}

- (void)addObject:(ObjectType)object toSetForKey:(KeyType<NSCopying>)key setCreator:(NSMutableSet<ObjectType> * (^)(void))creationBlock {
    NSMutableSet *set = self[key];
    if (set == nil) {
		set = creationBlock();
		self[key] = set;
    }
    [set addObject:object];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)childKey inDictionaryForKey:(KeyType<NSCopying>)topKey dictionaryCreator:(NSMutableDictionary * (^)(void))creator {
    NSMutableDictionary *childDictionary = [self objectForKey:topKey];
    if (childDictionary == nil) {
        childDictionary = creator();
        [self setObject:childDictionary forKey:topKey];
    }
    [childDictionary setObject:object forKey:childKey];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)childKey inDictionaryForKey:(KeyType<NSCopying>)topKey {
    [self setObject:object forKey:childKey inDictionaryForKey:topKey dictionaryCreator:^NSMutableDictionary * _Nonnull{
        return [NSMutableDictionary dictionary];
    }];
}

- (id)objectForKey:(id <NSCopying>)key createIfAbsent:(id (^)(void))creationBlock {
	id object = [self objectForKey:key];
	if (!object) {
		object = creationBlock();
		if (object) {
			[self setObject:object forKey:key];
		}
	}
	return object;
}

@end
