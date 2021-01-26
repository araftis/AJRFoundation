/* NSData-UU.h created by alex on Wed 05-Feb-1997 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (UU)

+ (nullable instancetype)ajr_dataWithUUEncodedString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;
+ (nullable instancetype)ajr_dataWithUUEncodedString:(NSString *)string filename:(NSString * _Nullable * _Nullable)filenameIO permissions:(nullable NSUInteger *)permission error:(NSError * _Nullable * _Nullable)error;
- (nullable instancetype)ajr_initWithUUEncodedString:(NSString *)string filename:(NSString * _Nullable * _Nullable)filenameIO permissions:(nullable NSUInteger *)permission error:(NSError **)error;

- (NSString *)ajr_uuEncodedString;
- (NSString *)ajr_uuEncodedStringWithFilename:(nullable NSString *)name;
- (NSString *)ajr_uuEncodedStringWithFilename:(nullable NSString *)name andPosixFilePermissions:(NSInteger)permissions;

@end

NS_ASSUME_NONNULL_END
