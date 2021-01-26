//
//  AJRMutableCountedDictionary.m
//  AJRFoundation
//
//  Created by AJ Raftis on 5/15/19.
//

#import "AJRMutableCountedDictionary.h"

@implementation AJRMutableCountedDictionary {
    NSCountedSet *_keys;
    NSMutableDictionary *_dictionary;
}

- (id)init {
    if ((self = [super init])) {
        _keys = [[NSCountedSet alloc] init];
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if ((self = [super init])) {
        _keys = [[NSCountedSet alloc] initWithCapacity:numItems];
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys count:(NSUInteger)count {
    if ((self = [super init])) {
        _keys = [[NSCountedSet alloc] init];
        _dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:count];
        for (NSInteger x = 0; x < count; x++) {
            [_keys addObject:keys[x]];
        }
    }
    return self;
}

#pragma mark - NSDictionary

- (NSUInteger)count {
    return [_dictionary count];
}

- (id)objectForKey:(id)key {
    return [_dictionary objectForKey:key];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    [_dictionary setObject:object forKey:key];
    [_keys addObject:key];
}

- (void)removeObjectForKey:(id)key {
    id object = [self objectForKey:key];
    if (object != nil) {
        [_keys removeObject:key];
        if ([_keys countForObject:key] == 0) {
            [_dictionary removeObjectForKey:key];
        }
    }
}

- (NSEnumerator *)keyEnumerator {
    return [_dictionary keyEnumerator];
}

#pragma mark - Additional

- (NSUInteger)countForKey:(id <NSCopying>)key {
    return [_keys countForObject:key];
}

@end
