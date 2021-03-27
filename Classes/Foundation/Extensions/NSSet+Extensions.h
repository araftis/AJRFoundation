
#import <AJRFoundation/AJRXMLCoding.h>
#import <AJRFoundation/AJRCollection.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSet <ObjectType> (Extensions) <AJRXMLEncoding>

#pragma mark - Convenience Initializers

+ (instancetype)setWithCollection:(id <AJRCollection>)collection;

#pragma mark - Filtering and Mapping

- (NSSet<ObjectType> *)setByRemovingObjects:(id <AJRCollection>)collection;

- (NSSet<id> *)mappedSetUsingBlock:(id (^)(ObjectType object))map;
- (NSSet<ObjectType> *)filteredSetUsingBlock:(BOOL (^)(ObjectType object))map;
- (NSSet<id> *)filteredAndMappedSetUsingBlock:(nullable id (^)(ObjectType object))mapAndfilter;

@end

NS_ASSUME_NONNULL_END
