/*
 AJRMutableCountedDictionary.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-counted-dictionary";
}

@end
