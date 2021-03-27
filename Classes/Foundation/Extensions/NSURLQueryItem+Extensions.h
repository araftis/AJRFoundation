
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLQueryItem (Extensions)

+ (NSArray<NSURLQueryItem *> *)queryItemsFromDictionary:(NSDictionary<NSString *, NSString *> *)items;

@end

NS_ASSUME_NONNULL_END
