//
//  NSMutableDictionary+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/4/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRFoundationOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary<KeyType, ObjectType> (Extensions)

- (void)setBool:(BOOL)value forKey:(KeyType<NSCopying>)key;
- (void)setInteger:(NSInteger)value forKey:(KeyType<NSCopying>)key;
- (void)setUnsignedInteger:(NSUInteger)value forKey:(KeyType<NSCopying>)key;
- (void)setChar:(char)value forKey:(KeyType<NSCopying>)key;
- (void)setUnsignedChar:(unsigned char)value forKey:(KeyType<NSCopying>)key;
- (void)setShort:(short)value forKey:(KeyType<NSCopying>)key;
- (void)setUnsignedShort:(unsigned short)value forKey:(KeyType<NSCopying>)key;
- (void)setInt:(int)value forKey:(KeyType<NSCopying>)key;
- (void)setUnsignedInt:(unsigned int)value forKey:(KeyType<NSCopying>)key;
- (void)setLong:(long)value forKey:(KeyType<NSCopying>)key;
- (void)setUnsignedLong:(unsigned long)value forKey:(KeyType<NSCopying>)key;
- (void)setLongLong:(long long)value forKey:(KeyType<NSCopying>)key;
- (void)setUnsignedLongLong:(unsigned long long)value forKey:(KeyType<NSCopying>)key;
- (void)setFloat:(float)value forKey:(KeyType<NSCopying>)key;
- (void)setDouble:(double)value forKey:(KeyType<NSCopying>)key;
- (void)setLongDouble:(long double)value forKey:(KeyType<NSCopying>)key;

- (void)setRect:(CGRect)value forKey:(KeyType<NSCopying>)key;
- (void)setSize:(CGSize)value forKey:(KeyType<NSCopying>)key;
- (void)setPoint:(CGPoint)value forKey:(KeyType<NSCopying>)key;
- (void)setRange:(NSRange)value forKey:(KeyType<NSCopying>)key;

- (void)addInteger:(NSNumber *)integer toKey:(KeyType<NSCopying>)key;
- (void)addDouble:(NSNumber *)integer toKey:(KeyType<NSCopying>)key;

- (nullable ObjectType)objectForKey:(KeyType)key createIfAbsent:(ObjectType (^)(void))creationBlock;
- (void)setObjectIfNotNil:(nullable ObjectType)object forKey:(KeyType<NSCopying>)key;
- (void)addObject:(id)object toArrayForKey:(KeyType<NSCopying>)key arrayCreator:(NSMutableArray<ObjectType> * (^)(void))creationBlock;
- (void)addObject:(id)object toArrayForKey:(KeyType<NSCopying>)key;
- (void)addObject:(id)object toSetForKey:(KeyType<NSCopying>)key setCreator:(NSMutableSet<ObjectType> * (^)(void))creationBlock;
- (void)addObject:(id)object toSetForKey:(KeyType<NSCopying>)key;
- (void)setObject:(id)object forKey:(id<NSCopying>)childKey inDictionaryForKey:(KeyType<NSCopying>)topKey dictionaryCreator:(NSMutableDictionary * (^)(void))creator;
- (void)setObject:(id)object forKey:(id<NSCopying>)childKey inDictionaryForKey:(KeyType<NSCopying>)topKey;

@end

NS_ASSUME_NONNULL_END
