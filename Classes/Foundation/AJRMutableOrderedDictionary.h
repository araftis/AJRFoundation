
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRMutableOrderedDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

+ (instancetype)dictionary;
- (instancetype)init;

#pragma mark - Searching

- (nullable ObjectType)ajr_firstObjectPassingTest:(BOOL (^)(ObjectType object))test;
- (nullable ObjectType)ajr_lastObjectPassingTest:(BOOL (^)(ObjectType object))test;

@end

NS_ASSUME_NONNULL_END
