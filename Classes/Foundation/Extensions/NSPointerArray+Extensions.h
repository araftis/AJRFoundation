
#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPointerArray (Extensions)

// Only really useable when using an object pointer implementation.
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeObjectIdenticalTo:(id)object;

- (NSUInteger)indexOfObject:(id)object;
- (NSUInteger)indexOfObjectIdenticalTo:(id)object;

- (void)enumerateObjectsUsingBlock:(void (^)(id _Nullable object, NSUInteger index, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
