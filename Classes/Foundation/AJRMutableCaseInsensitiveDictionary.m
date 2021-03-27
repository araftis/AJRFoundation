
#import "AJRMutableCaseInsensitiveDictionary.h"

#import <Foundation/NSEnumerator.h>
#import <Foundation/NSString.h>

#import <AJRFoundation/AJRCaseInsensitiveString.h>

@implementation AJRMutableCaseInsensitiveDictionary {
   NSMutableDictionary *_dictionary;
}

- (instancetype)init {
	if ((self = [super init])) {
		_dictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
	if ((self = [super init])) {
		_dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
	}
	return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys count:(NSUInteger)count {
	if ((self = [super init])) {
		_dictionary = [[NSMutableDictionary alloc] init];
		for (NSInteger x = 0; x < count; x++) {
			id<NSCopying,NSObject> key = (id<NSCopying,NSObject>)keys[x];
			if ([key isKindOfClass:[NSString class]]) {
				key = [[AJRCaseInsensitiveString allocWithZone:nil] initWithString:(NSString *)key];
			}
			[_dictionary setObject:objects[x] forKey:key];
		}
	}
    
    return self;
}


- (id)objectForKey:(id)key {
    if ([key isKindOfClass:[NSString class]]) {
        return [_dictionary objectForKey:[AJRCaseInsensitiveString stringWithString:key]];
    }
    return [_dictionary objectForKey:key];
}

- (NSEnumerator *)keyEnumerator {
    return [_dictionary keyEnumerator];
}

- (NSUInteger)count {
    return [_dictionary count];
}

- (void)removeObjectForKey:(id)key {
    if ([key isKindOfClass:[NSString class]]) {
        [_dictionary removeObjectForKey:[AJRCaseInsensitiveString stringWithString:key]];
        return;
    }
    [_dictionary removeObjectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key {
    if ([key isKindOfClass:[NSString class]]) {
        [_dictionary setObject:object forKey:[[AJRCaseInsensitiveString alloc] initWithString:key]];
        return;
    }
    [_dictionary setObject:object forKey:key];
}

@end
