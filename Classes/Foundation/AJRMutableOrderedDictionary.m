/*
 AJRMutableOrderedDictionary.m
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

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-ordered-dictionary";
}

@end
