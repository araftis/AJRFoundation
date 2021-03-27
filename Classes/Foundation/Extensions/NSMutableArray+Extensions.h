
#import <Foundation/Foundation.h>

#import <AJRFoundation/NSArray+Extensions.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray<ObjectType> (AJRExtensions)

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)otherIndex;

- (BOOL)insertObjectIfNotNil:(nullable ObjectType)object atIndex:(NSUInteger)index;
- (BOOL)addObjectIfNotNil:(nullable ObjectType)object;

// Adds an object at index, padding with NSNull if appropriate.
- (void)addObject:(id)object atIndex:(NSUInteger)index;

- (NSUInteger)addSortedObject:(id)object;
- (NSUInteger)addSortedObject:(id)object usingComparator:(NSComparator)comparator;

#pragma mark - Conveniences

- (void)insertObjects:(NSArray<ObjectType> *)children atIndex:(NSUInteger)index;
- (void)removeFirstObjectPassingTest:(BOOL (^)(ObjectType object))test;
- (void)removeObjectsPassingTest:(BOOL (^)(ObjectType object))test;

@end

NS_ASSUME_NONNULL_END
