
#import "AJRCollection.h"

@implementation NSArray (AJRCollection)

#pragma mark - Set operations

- (BOOL)ajr_containsObject:(id)object
{
    return [self containsObject:object];
}

- (void)ajr_enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id object, BOOL *stop))block
{
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
}

- (NSArray *)ajr_collectionByUnioningWithCollection:(id <AJRCollection>)collection
{
    NSMutableArray *result = [self mutableCopy];
    
    [collection ajr_enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        if (![self containsObject:object]) {
            [result addObject:object];
        }
    }];
    
    return result;
}

- (NSArray *)ajr_collectionByIntersectingWithCollection:(id <AJRCollection>)collection
{
    NSMutableArray *result = [NSMutableArray array];
    
    [self ajr_enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        if ([collection ajr_containsObject:object]) {
            [result addObject:object];
        }
    }];
    
    return result;
}

@end

@implementation NSSet (AJRCollection)

#pragma mark - Set operations

- (BOOL)ajr_containsObject:(id)object
{
    return [self containsObject:object];
}

- (void)ajr_enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id object, BOOL *stop))block
{
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(obj, stop);
    }];
}

- (NSSet *)ajr_collectionByUnioningWithCollection:(id <AJRCollection>)collection
{
    NSMutableSet *result = [self mutableCopy];
    
    [collection ajr_enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        if (![self containsObject:object]) {
            [result addObject:object];
        }
    }];
    
    return result;
}

- (NSSet *)ajr_collectionByIntersectingWithCollection:(id <AJRCollection>)collection
{
    NSMutableSet *result = [NSMutableSet set];
    
    [self ajr_enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        if ([collection ajr_containsObject:object]) {
            [result addObject:object];
        }
    }];
    
    return result;
}

@end

@implementation NSDictionary (AJRCollection)

#pragma mark - Set operations

- (BOOL)ajr_containsObject:(id)object
{
    return [[self allKeysForObject:object] count] != 0;
}

- (void)ajr_enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id object, BOOL *stop))block
{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(obj, stop);
    }];
}

- (id <AJRCollection>)ajr_collectionByUnioningWithCollection:(id <AJRCollection>)collection
{
    id <AJRCollection> result = [self mutableCopy];
    if ([collection isKindOfClass:[NSDictionary class]]) {
        [(NSMutableDictionary *)result addEntriesFromDictionary:(NSDictionary *)collection];
    } else {
        result = [NSMutableSet setWithArray:[self allValues]];
        result = [result ajr_collectionByUnioningWithCollection:collection];
    }
    return result;
}

- (id <AJRCollection>)ajr_collectionByIntersectingWithCollection:(id <AJRCollection>)collection
{
    id <AJRCollection> result;
    if ([collection isKindOfClass:[NSDictionary class]]) {
        result = [NSMutableDictionary dictionary];
        [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSDictionary *)collection objectForKey:key]) {
                [(NSMutableDictionary *)result setObject:obj forKey:key];
            }
        }];
    } else {
        result = [NSMutableSet setWithArray:[self allValues]];
        result = [result ajr_collectionByIntersectingWithCollection:collection];
    }
    return result;
}

@end
