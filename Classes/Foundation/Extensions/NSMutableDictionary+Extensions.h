/*
NSMutableDictionary+Extensions.h
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
