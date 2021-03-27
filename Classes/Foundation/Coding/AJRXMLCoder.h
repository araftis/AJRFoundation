
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRXMLCodingException;
extern NSString * const AJRXMLCodingErrorDomain;
extern NSString * const AJRXMLCodingLogDomain;

typedef void (^AJRXMLUnarchiverFinalizer)(void);
typedef BOOL (^AJRXMLUnarchiverGenericSetter)(id _Nullable rawValue, NSError * _Nullable * _Nullable error);

@interface NSObject (AJRXMLCoding)

@property (nonatomic,class,readonly) NSString *ajr_nameForXMLArchiving;
@property (nonatomic,readonly) NSString *ajr_nameForXMLArchiving;
@property (nonatomic,class,readonly) Class ajr_classForXMLArchiving;
@property (nonatomic,readonly) Class ajr_classForXMLArchiving;

@end

@interface AJRXMLCoder : NSObject

- (id)initWithStream:(NSStream *)stream;

@property (nonatomic,readonly) NSStream *stream;

- (void)encodeRootObject:(id)object forKey:(nullable NSString *)key;

- (void)encodeObject:(id)object;
- (void)encodeObject:(nullable id)object forKey:(NSString *)key;
- (void)encodeBool:(BOOL)number forKey:(NSString *)key;
- (void)encodeInteger:(NSInteger)number forKey:(NSString *)key;
- (void)encodeInt:(int)number forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)number forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)number forKey:(NSString *)key;
- (void)encodeUInteger:(NSUInteger)number forKey:(NSString *)key;
- (void)encodeUInt:(unsigned int)number forKey:(NSString *)key;
- (void)encodeUInt32:(uint32_t)number forKey:(NSString *)key;
- (void)encodeUInt64:(uint64_t)number forKey:(NSString *)key;
- (void)encodeFloat:(float)number forKey:(NSString *)key;
- (void)encodeDouble:(double)number forKey:(NSString *)key;
- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length;
- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length forKey:(NSString *)key;
- (void)encodeRange:(NSRange)range forKey:(NSString *)key;
// Additional conveniences that produce slightly nicer results than the default implementations
- (void)encodeObjectIfNotNil:(nullable id)object forKey:(NSString *)key;
- (void)encodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block;
- (void)encodeString:(NSString *)value forKey:(NSString *)key;
- (void)encodeCString:(const char *)value forKey:(NSString *)key;
- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format arguments:(va_list)args;
- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format, ...;
- (void)encodeText:(NSString *)text;
- (void)encodeText:(NSString *)text forKey:(NSString *)key;
- (void)encodeComment:(NSString *)text;
- (void)encodeURL:(NSURL *)url forKey:(NSString *)key;
- (void)encodeURLBookmark:(NSURL *)url forKey:(NSString *)key;

- (void)finalizeDecodeWithBlock:(AJRXMLUnarchiverFinalizer)finalizer;
- (void)decodeObjectForKey:(NSString *)key setter:(nullable void (^)(id _Nullable object))setter;
- (void)decodeObjectUsingSetter:(nullable void (^)(id object))setter;
- (void)decodeStringForKey:(NSString *)key setter:(nullable void (^)(NSString *string))setter;
- (void)decodeCStringForKey:(NSString *)key setter:(nullable void (^)(const char *string))setter;
- (void)decodeBoolForKey:(NSString *)key setter:(nullable void (^)(BOOL value))setter;
- (void)decodeIntegerForKey:(NSString *)key setter:(nullable void (^)(NSInteger value))setter;
- (void)decodeIntForKey:(NSString *)key setter:(nullable void (^)(int value))setter;
- (void)decodeInt32ForKey:(NSString *)key setter:(nullable void (^)(int32_t value))setter;
- (void)decodeInt64ForKey:(NSString *)key setter:(nullable void (^)(int64_t value))setter;
- (void)decodeUIntegerForKey:(NSString *)key setter:(nullable void (^)(NSUInteger value))setter;
- (void)decodeUIntForKey:(NSString *)key setter:(nullable void (^)(unsigned int value))setter;
- (void)decodeUInt32ForKey:(NSString *)key setter:(nullable void (^)(uint32_t value))setter;
- (void)decodeUInt64ForKey:(NSString *)key setter:(nullable void (^)(uint64_t value))setter;
- (void)decodeFloatForKey:(NSString *)key setter:(nullable void (^)(float value))setter;
- (void)decodeDoubleForKey:(NSString *)key setter:(nullable void (^)(double value))setter;
- (void)decodeBytesForKey:(NSString *)key setter:(nullable void (^)(uint8_t *, NSUInteger length))setter;
- (void)decodeBytesUsingSetter:(nullable void (^)(uint8_t *, NSUInteger length))setter;
- (void)decodeRangeForKey:(NSString *)key setter:(void (^)(NSRange range))setter;
// Additional conveniences that produce slightly nicer results than the default implementations
- (void)decodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block setter:(nullable void (^)(void))setter;
- (void)decodeTextUsingSetter:(void (^)(NSString *))setter;
- (void)decodeURLForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter;
- (void)decodeURLBookmarkForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter;

@end

extern NSNumberFormatter *AJRXMLCoderGetDoubleFormatter(void); // Formatter with 10 places after decimal.
extern NSNumberFormatter *AJRXMLCoderGetFloatFormatter(void); // Formatter with 5 places after decimal.

NS_ASSUME_NONNULL_END
