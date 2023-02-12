/*
 AJRCollection.m
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
