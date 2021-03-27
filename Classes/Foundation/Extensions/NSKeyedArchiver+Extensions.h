
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSKeyedArchiver (Extensions)

+ (nullable NSData *)ajr_archivedObject:(id <NSCoding>)object error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
