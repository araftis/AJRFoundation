
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRDataErrorDomain;

@interface NSData (Base64)

+ (nullable instancetype)ajr_dataWithBase64EncodedString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;
- (nullable instancetype)ajr_initWithBase64EncodedString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;

- (NSString *)ajr_base64EncodedString;
- (NSString *)ajr_base64EncodedStringInRange:(NSRange)range;
- (NSString *)ajr_base64EncodedStringWithLineBreakAtPosition:(NSInteger)position;
- (NSString *)ajr_base64EncodedStringInRange:(NSRange)range withLineBreakAtPosition:(NSInteger)position;

@end

extern const NSInteger AJRBase64NoLineBreak;
extern NSString *AJRBase64EncodedString(const uint8_t *bytes, NSInteger length, NSRange subrange, NSInteger lineBreakPosition);
extern NSError * _Nullable AJRBase64DecodedBytes(NSString * _Nonnull string, uint8_t * _Nonnull * _Nullable bytesOut, NSInteger * _Nonnull lengthOut);

NS_ASSUME_NONNULL_END
