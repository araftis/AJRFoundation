/*
NSDictionary+Extensions.h
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
#import <AJRFoundation/AJRXMLCoding.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType,ObjectType> (Extensions) <AJRXMLEncoding>

- (nullable ObjectType)objectForKey:(KeyType<NSCopying>)key defaultValue:(nullable id)value;
- (nullable ObjectType)objectForKeyPath:(KeyType<NSCopying>)key defaultValue:(nullable id)value;
- (nullable id)arrayForKey:(KeyType<NSCopying>)key;
- (nullable id)arrayForKey:(KeyType<NSCopying>)key defaultValue:(nullable id)value;
- (nullable id)arrayForKeyPath:(NSString *)key defaultValue:(nullable id)value;
- (nullable id)dictionaryForKey:(KeyType<NSCopying>)key;
- (nullable id)dictionaryForKey:(KeyType<NSCopying>)key defaultValue:(nullable id)value;
- (nullable id)dictionaryForKeyPath:(NSString *)key defaultValue:(nullable id)value;
- (nullable NSString *)stringForKey:(KeyType<NSCopying>)key defaultValue:(nullable NSString *)defaultValue;
- (nullable NSString *)stringForKeyPath:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSTimeInterval)timeIntervalForKey:(KeyType<NSCopying>)key defaultValue:(NSTimeInterval)defaultValue;
- (NSTimeInterval)timeIntervalForKeyPath:(NSString *)key defaultValue:(NSTimeInterval)defaultValue;
- (long long)millisecondsForKey:(KeyType<NSCopying>)key defaultValue:(long long)defaultValue;
- (long long)millisecondsForKeyPath:(NSString *)key defaultValue:(long long)defaultValue;
- (nullable NSNumber *)numberForKey:(KeyType<NSCopying>)key defaultValue:(NSNumber *)defaultValue;
- (nullable NSNumber *)numberForKeyPath:(NSString *)key defaultValue:(NSNumber *)defaultValue;
- (char)charForKey:(KeyType<NSCopying>)key defaultValue:(char)defaultValue;
- (char)charForKeyPath:(NSString *)key defaultValue:(char)defaultValue;
- (unsigned char)unsignedCharForKey:(KeyType<NSCopying>)key defaultValue:(unsigned char)defaultValue;
- (unsigned char)unsignedCharForKeyPath:(NSString *)key defaultValue:(unsigned char)defaultValue;
- (short)shortForKey:(KeyType<NSCopying>)key defaultValue:(short)defaultValue;
- (short)shortForKeyPath:(NSString *)key defaultValue:(short)defaultValue;
- (unsigned short)unsignedShortForKey:(KeyType<NSCopying>)key defaultValue:(unsigned short)defaultValue;
- (unsigned short)unsignedShortForKeyPath:(NSString *)key defaultValue:(unsigned short)defaultValue;
- (int)intForKey:(KeyType<NSCopying>)key defaultValue:(int)defaultValue;
- (int)intForKeyPath:(NSString *)key defaultValue:(int)defaultValue;
- (unsigned int)unsignedIntForKey:(KeyType<NSCopying>)key defaultValue:(unsigned int)defaultValue;
- (unsigned int)unsignedIntForKeyPath:(NSString *)key defaultValue:(unsigned int)defaultValue;
- (NSInteger)integerForKey:(KeyType<NSCopying>)key defaultValue:(NSInteger)defaultValue;
- (NSInteger)integerForKeyPath:(NSString *)key defaultValue:(NSInteger)defaultValue;
- (NSUInteger)unsignedIntegerForKey:(KeyType<NSCopying>)key defaultValue:(NSUInteger)defaultValue;
- (NSUInteger)unsignedIntegerForKeyPath:(NSString *)key defaultValue:(NSUInteger)defaultValue;
- (long)longForKey:(KeyType<NSCopying>)key defaultValue:(long)defaultValue;
- (long)longForKeyPath:(NSString *)key defaultValue:(long)defaultValue;
- (unsigned long)unsignedLongForKey:(KeyType<NSCopying>)key defaultValue:(unsigned long)defaultValue;
- (unsigned long)unsignedLongForKeyPath:(NSString *)key defaultValue:(unsigned long)defaultValue;
- (long long)longLongForKey:(KeyType<NSCopying>)key defaultValue:(long long)defaultValue;
- (long long)longLongForKeyPath:(NSString *)key defaultValue:(long long)defaultValue;
- (unsigned long long)unsignedLongLongForKey:(KeyType<NSCopying>)key defaultValue:(unsigned long long)defaultValue;
- (unsigned long long)unsignedLongLongForKeyPath:(NSString *)key defaultValue:(unsigned long long)defaultValue;
- (BOOL)boolForKey:(KeyType<NSCopying>)key defaultValue:(BOOL)defaultValue;
- (BOOL)boolForKeyPath:(NSString *)key defaultValue:(BOOL)defaultValue;
- (float)floatForKey:(KeyType<NSCopying>)key defaultValue:(float)defaultValue;
- (float)floatForKeyPath:(NSString *)key defaultValue:(float)defaultValue;
- (double)doubleForKey:(KeyType<NSCopying>)key defaultValue:(double)defaultValue;
- (double)doubleForKeyPath:(NSString *)key defaultValue:(double)defaultValue;
- (long double)longDoubleForKey:(KeyType<NSCopying>)key defaultValue:(long double)defaultValue;
- (long double)longDoubleForKeyPath:(NSString *)key defaultValue:(long double)defaultValue;
- (nullable NSCharacterSet *)characterSetForKey:(KeyType<NSCopying>)key defaultValue:(nullable NSCharacterSet *)defaultValue;
- (nullable NSCharacterSet *)characterSetForKeyPath:(NSString *)key defaultValue:(nullable NSCharacterSet *)defaultValue;
- (CGRect)rectForKey:(KeyType<NSCopying>)key defaultValue:(CGRect)value;
- (CGRect)rectForKeyPath:(NSString *)key defaultValue:(CGRect)value;
- (CGSize)sizeForKey:(KeyType<NSCopying>)key defaultValue:(CGSize)value;
- (CGSize)sizeForKeyPath:(NSString *)key defaultValue:(CGSize)value;
- (CGPoint)pointForKey:(KeyType<NSCopying>)key defaultValue:(CGPoint)value;
- (CGPoint)pointForKeyPath:(NSString *)key defaultValue:(CGPoint)value;
- (NSRange)rangeForKey:(KeyType<NSCopying>)key defaultValue:(NSRange)value;
- (NSRange)rangeForKeyPath:(NSString *)key defaultValue:(NSRange)value;

- (nullable NSDictionary<ObjectType,KeyType<NSCopying>> *)dictionaryByAddingEntriesFromDictionary:(nullable NSDictionary<ObjectType, KeyType<NSCopying>> *)fromDictionary;
- (nullable NSDictionary *)dictionaryByRemovingObjectForKey:(KeyType<NSCopying>)key;
- (nullable NSDictionary *)dictionaryBySettingObject:(id)object forKey:(KeyType<NSCopying>)key;

- (nullable NSDictionary *)subdictionaryForKeys:(NSArray<KeyType<NSCopying>> *)keys;
- (nullable NSDictionary *)subdictionaryForKeys:(NSArray<KeyType<NSCopying>> *)keys missingValue:(nullable ObjectType)value;

- (nullable id)objectForKey:(id)childKey inDictionaryForKey:(KeyType<NSCopying>)topKey;

#pragma mark - Invalidation

/**
 @discussion Enumerates all objects in the receiver and calls -[AJRInvalidation invalidate] if the object responds to the AJRInvalidation protocol.
 */
- (void)invalidateObjects;

@end

NS_ASSUME_NONNULL_END
