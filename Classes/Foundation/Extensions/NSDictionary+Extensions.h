
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

@end

NS_ASSUME_NONNULL_END
