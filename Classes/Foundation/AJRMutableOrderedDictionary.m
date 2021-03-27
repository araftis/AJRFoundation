
#import "AJRMutableOrderedDictionary.h"

#define ObjectType id
#define KeyType id

@implementation AJRMutableOrderedDictionary {
    NSMutableOrderedSet *_orderedKeys;
    NSMutableDictionary *_dictionary;
}

+ (instancetype)dictionary {
    return [[self alloc] init];
}

- (instancetype)init {
    if ((self = [super init])) {
        _orderedKeys = [NSMutableOrderedSet orderedSet];
        _dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKey:(id)key {
    return [_dictionary objectForKey:key];
}

- (NSEnumerator *)keyEnumerator {
    return [_orderedKeys objectEnumerator];
}

- (NSUInteger)count {
    return [_dictionary count];
}

- (void)removeObjectForKey:(id)key {
    [_dictionary removeObjectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key {
    [_orderedKeys addObject:key];
    [_dictionary setObject:object forKey:key];
}

- (void)removeAllObjects {
    [_orderedKeys removeAllObjects];
    [_dictionary removeAllObjects];
}

#pragma mark - Searching

- (nullable ObjectType)ajr_firstObjectPassingTest:(BOOL (^)(ObjectType object))test {
    for (KeyType key in _orderedKeys) {
        ObjectType object = [_dictionary objectForKey:key];
        if (test(object)) {
            return object;
        }
    }
    return nil;
}

- (nullable ObjectType)ajr_lastObjectPassingTest:(BOOL (^)(ObjectType object))test {
    for (KeyType key in [_orderedKeys reverseObjectEnumerator]) {
        ObjectType object = [_dictionary objectForKey:key];
        if (test(object)) {
            return object;
        }
    }
    return nil;
}

@end
