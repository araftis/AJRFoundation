/*
 NSSet+Extensions.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

#import "NSSet+ExtensionsP.h"

#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "AJRRuntime.h"
#import "AJRXMLArchiver.h"
#import "AJRXMLCollectionPlaceholder.h"

@implementation NSSet (Extensions)

#pragma mark - Convenience Initializers

+ (instancetype)setWithCollection:(id <AJRCollection>)collection {
    NSMutableSet *set = [NSMutableSet setWithCapacity:[collection count]];
    for (id object in collection) {
        [set addObject:object];
    }
    return set;
}

#pragma mark - Filtering and Mapping

- (NSSet *)setByRemovingObjects:(id <AJRCollection>)collection {
    if ([collection isKindOfClass:[NSSet class]]) {
        NSMutableSet *result = [self mutableCopy];
        [result minusSet:(NSSet *)collection];
        return result;
    } else {
        NSMutableSet *result = [self mutableCopy];
        for (id object in collection) {
            [result removeObject:object];
        }
        return result;
    }
}

- (NSSet<id> *)mappedSetUsingBlock:(id (^)(id object))map {
    return [self filteredAndMappedSetUsingBlock:^id (id object) {
        return map(object);
    }];
}

- (NSSet<id> *)filteredSetUsingBlock:(BOOL (^)(id object))map {
    return [self filteredAndMappedSetUsingBlock:^id _Nonnull(id  _Nonnull object) {
        return map(object) ? object : nil;
    }];
}

- (NSSet<id> *)filteredAndMappedSetUsingBlock:(id (^)(id object))mapAndfilter {
    NSSet<id> *newSet = nil;

    if ([self count] < 100) {
        id __strong objects[[self count]];
        NSInteger count = 0;
        for (id object in self) {
            id mappedAndFilteredObject = mapAndfilter(object);
            if (mappedAndFilteredObject) {
                objects[count++] = mappedAndFilteredObject;
            }
        }
        newSet = [NSSet setWithObjects:objects count:count];
    } else {
        NSMutableSet *buildSet = [NSMutableSet set];
        for (id object in self) {
            id mappedAndFilteredObject = mapAndfilter(object);
            if (mappedAndFilteredObject) {
                [buildSet addObject:mappedAndFilteredObject];
            }
        }
        newSet = buildSet;
    }
    return newSet;
}

#pragma mark - AJRXMLCoding

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLCollectionPlaceholder alloc] initWithFinalClass:[self ajr_classForXMLArchiving]];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [self enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        [coder encodeObject:object forKey:[(NSObject *)object ajr_nameForXMLArchiving]];
    }];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"set";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSSet class];
}

@end

#if defined(AJR_DEBUG)

@interface NSMutableSet (AJRFoundationExtensions)

@end

@implementation NSMutableSet (AJRFoundationExtensions)

// Use this to catch *** -[NSMutableSet addObjectsFromArray:]: array argument is not an NSArray
+ (void)load {
    AJRSwizzleMethods(self, @selector(addObjectsFromArray:), self, @selector(ajr_addObjectsFromArray:));
}

- (void)ajr_addObjectsFromArray:(NSArray *)array {
    if (![array isKindOfClass:[NSArray class]]) {
        NSArray<NSString *> *callStack = NSThread.callStackSymbols;
        if ((callStack.count > 2 && [callStack[1] containsString:@"CalLogMaster"])
            || (callStack.count > 3 && [callStack[2] containsString:@"DebugHierarchyHelpers"])
            || (callStack.count > 2 && [callStack[1] containsString:@"_accessibilityPropertiesWithAssociatedObjects"])
            || (callStack.count > 2 && [callStack[1] containsString:@"_accessibilityConvenienceSupportedAttributes"])) {
            // Don't call if CalLogMaster is present, because that's Apple's code, and they're calling us with a nil value, which is defined as illegal, but won't techinically break anything.
        } else {
            AJRLog(nil, AJRLogLevelWarning, @"Called -[%C addObjectsFromArray:] with a (%C), which isn't an array:\n", self, array);
            AJRLog(nil, AJRLogLevelWarning, @"%@\n", NSThread.callStackSymbols);
        }
    }
    [self ajr_addObjectsFromArray:array];
}

@end

#endif
