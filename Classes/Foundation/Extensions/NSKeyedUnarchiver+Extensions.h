
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (Extensions)

+ (nullable id)ajr_unarchivedObjectWithData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)ajr_unarchivedObjectWithPath:(NSString *)path error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)ajr_unarchivedObjectWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
