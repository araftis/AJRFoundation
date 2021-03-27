
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableSet<ObjectType> (Extensions)

- (void)addObjectIfNotNil:(nullable ObjectType)object;

@end

NS_ASSUME_NONNULL_END
