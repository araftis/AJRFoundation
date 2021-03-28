/*
NSArray+Extensions.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "NSArray+Extensions.h"

#import "AJRCollection.h"
#import "AJRLogging.h"
#import "AJRPropertyListCoding.h"
#import "AJRXMLArchiver.h"
#import "AJRXMLCoder.h"
#import "AJRXMLCollectionPlaceholder.h"
#import "NSError+Extensions.h"
#import "NSObject+Extensions.h"

@interface NSObject ()

+ (id)createFromPropertyList:(id)propertyList;

@end

#define ObjectType id

@implementation NSArray (AJRFoundationExtensions)

#pragma mark - Convenience Initializers

+ (instancetype)arrayWithCollection:(id <AJRCollection>)collection {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[collection count]];
    for (id object in collection) {
        [array addObject:object];
    }
    return array;
}

#pragma mark - Set Math

- (NSArray *)differencesFromArray:(NSArray *)other {
    NSMutableArray *differences = [NSMutableArray array];
    
    for (id object in self) {
        if (![other containsObject:object]) {
            [differences addObject:object];
        }
    }
    
    for (id object in other) {
        if (![self containsObject:object]) {
            [differences addObject:object];
        }
    }
    
    return differences;
}

#pragma mark - Searching

NSUInteger _ajrBinarySearch(NSArray *array, id key, NSComparator comparator, NSUInteger idxBottom, NSUInteger idxTop, NSUInteger *insertIndex) {
    NSInteger idxMiddle;
    NSInteger result;
    
    if ([array count] == 0) {
        if (insertIndex) *insertIndex = 0;
        return NSNotFound;
    }
    
    if (idxBottom == idxTop) {
        result = comparator(key, [array objectAtIndex:idxBottom]);
        if (result == NSOrderedSame) {
            if (insertIndex) *insertIndex = idxBottom;
            return idxBottom;
        }
        if (insertIndex) *insertIndex = idxBottom;
        return NSNotFound;
    }
    
    idxMiddle = (idxBottom + idxTop) / 2;
    if (idxMiddle == idxBottom) {
        result = comparator(key, [array objectAtIndex:idxMiddle]);
        if (result == NSOrderedSame) {
            if (insertIndex) *insertIndex = idxMiddle;
            return idxMiddle;
        } else if (result < NSOrderedSame) {
            if (insertIndex) *insertIndex = idxMiddle;
        } else if (result > NSOrderedSame) {
            if (insertIndex) *insertIndex = idxMiddle + 1;
        }
        return NSNotFound;
    }
    
    result = comparator(key, [array objectAtIndex:idxMiddle]);
    if (result < NSOrderedSame) {
        return _ajrBinarySearch(array, key, comparator, idxBottom, idxMiddle, insertIndex);
    } else if (result > NSOrderedSame) {
        return _ajrBinarySearch(array, key, comparator, idxMiddle, idxTop, insertIndex);
    }
    
    // result == NSOrderedSame. We don't put this in the if/else blocks above, because the compile can't correctly recognize that this code in unreachable, because NSComparisonResult isn't actually defined as an enum.
    if (insertIndex) *insertIndex = idxMiddle;
    return idxMiddle;
}

const NSComparator AJRSimpleCompare = ^NSComparisonResult(id first, id second) {
    return [(NSString *)first compare:second];
};

- (NSUInteger)findIndexOfObject:(id)object {
    return [self findIndexOfObject:object usingComparator:AJRSimpleCompare];
}

- (NSUInteger)findIndexOfObject:(id)object usingComparator:(NSComparator)comparator {
    return _ajrBinarySearch(self, object, comparator, 0, [self count], NULL);
}

- (NSUInteger)findInsertionIndexForObject:(id)object {
    return [self findInsertionIndexForObject:object usingComparator:AJRSimpleCompare];
}

- (NSUInteger)findInsertionIndexForObject:(id)object usingComparator:(NSComparator)comparator {
    NSUInteger index = NSNotFound;
    _ajrBinarySearch(self, object, comparator, 0, [self count], &index);
    return index;
}

- (BOOL)containsObjectIdenticalTo:(id)anObject {
    return [self indexOfObjectIdenticalTo:anObject] != NSNotFound;
}

- (void)makeObjectsPerformSelector:(SEL)selector withInvocationInitializer:(void (^)(NSInvocation *))block {
    for (id object in self) {
        NSMethodSignature *signature = nil;
        NSInvocation *invocation = nil;
        Class lastClass = Nil;
        Class currentClass = [object class];
        if (signature == nil || lastClass != currentClass) {
            signature = [object methodSignatureForSelector:selector];
            if (signature) {
                invocation = [NSInvocation invocationWithMethodSignature:signature];
                invocation.selector = selector;
                block(invocation);
            } else {
                invocation = nil;
            }
            lastClass = currentClass;
        }

        if (invocation) {
            @try {
                [invocation invokeWithTarget:object];
            } @catch (NSException *exception) {
                AJRLog(NULL, AJRLogLevelWarning, @"An exception occurred while performing invocation: %@:\n%@\n", exception, [exception callStackSymbols]);
            }
        }
    }
}

- (void)makeObjectsPerformSelectorIfImplemented:(SEL)selector withObject:(id)object1 {
    [self makeObjectsPerformSelector:selector withInvocationInitializer:^(NSInvocation *invocation) {
        [invocation setArgument:(void *)&object1 atIndex:2];
    }];
}

- (void)makeObjectsPerformSelectorIfImplemented:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    [self makeObjectsPerformSelector:selector withInvocationInitializer:^(NSInvocation *invocation) {
        [invocation setArgument:(void *)&object1 atIndex:2];
        [invocation setArgument:(void *)&object2 atIndex:3];
    }];
}

- (void)makeObjectsSetIntegerValue:(NSInteger)aValue withSelector:(SEL)selector {
    [self makeObjectsPerformSelector:selector withInvocationInitializer:^(NSInvocation *invocation) {
        [invocation setArgument:(void *)&aValue atIndex:2];
    }];
}

- (void)makeObjectsSetFloatValue:(float)aValue withSelector:(SEL)selector {
    [self makeObjectsPerformSelector:selector withInvocationInitializer:^(NSInvocation *invocation) {
        [invocation setArgument:(void *)&aValue atIndex:2];
    }];
}

- (void)makeObjectsSetDoubleValue:(double)aValue withSelector:(SEL)selector {
    [self makeObjectsPerformSelector:selector withInvocationInitializer:^(NSInvocation *invocation) {
        [invocation setArgument:(void *)&aValue atIndex:2];
    }];
}

- (void)makeObjectsSetBOOLValue:(BOOL)aValue withSelector:(SEL)selector {
    [self makeObjectsPerformSelector:selector withInvocationInitializer:^(NSInvocation *invocation) {
        [invocation setArgument:(void *)&aValue atIndex:2];
    }];
}

- (void)makeObjectsPerformInvocation:(NSInvocation *)invocation {
    NSInteger x;
    
    for (x = 0; x < (const NSInteger)[self count]; x++) {
        NSObject *anObject = [self objectAtIndex:x];
        
        @try {
            [invocation invokeWithTarget:anObject];
        } @catch (NSException *exception) {
            AJRLog(NULL, AJRLogLevelWarning, @"An exception occurred while performing invocation: %@:\n%@\n", exception, [exception callStackSymbols]);
        }
    }
}

- (NSArray*)arraySplitIntoBatchedArrayWithItemsPerBatch:(NSUInteger)numberOfItemsInBatch {
    NSMutableArray *result = [NSMutableArray array];
    NSRange range = {0,numberOfItemsInBatch};
    while ((range.location + range.length) < self.count) {
        NSArray *subList = [self subarrayWithRange:range];
        range.location = range.location + range.length;
        [result addObject:subList];
    }
    
    NSRange finalRange = NSMakeRange(range.location, self.count - range.location);
    NSArray *finalSubList = [self subarrayWithRange:finalRange];
    [result addObject:finalSubList];
    
    return result;
}

+ (id)createFromPropertyList:(id)propertyList class:(Class)class error:(NSError **)error {
    NSError *localError = nil;
    NSMutableArray *temp = nil;

    if (![class conformsToProtocol:@protocol(AJRPropertyListCoding)]) {
        localError = [NSError errorWithDomain:NSInvalidArgumentException format:@"Class %C does not conform to AJRPropertyListCoding protocol.", class];
    } else {
        temp = [[NSMutableArray alloc] initWithCapacity:[propertyList count]];
        @autoreleasepool {
            for (id sublist in propertyList) {
                id object = [[class alloc] initWithPropertyListValue:sublist error:&localError];
                if (object == nil) {
                    temp = nil;
                    break;
                } else {
                    [temp addObject:object];
                }
            }
        }
    }

    return AJRAssertOrPropagateError(temp, error, localError);
}

- (id)propertyListValue {
    NSMutableArray *propertyList = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (id child in self) {
        [propertyList addObject:[child propertyListValue]];
    }
    
    return propertyList;
}

#pragma mark - AJRXMLCoding

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLCollectionPlaceholder alloc] initWithFinalClass:[self ajr_classForXMLArchiving]];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [self enumerateObjectsUsingBlock:^(id <AJRXMLCoding> object, NSUInteger index, BOOL *stop) {
        [coder encodeObject:object forKey:[(NSObject *)object ajr_nameForXMLArchiving]];
    }];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"array";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSArray class];
}

#pragma mark - Filtering and Mapping

- (NSArray<id> *)filteredArrayUsingBlock:(BOOL (^)(id object))filter {
    return [self filteredAndMappedArrayUsingBlock:^id _Nullable(id  _Nonnull object) {
        return filter(object) ? object : nil;
    }];
}

- (NSArray<id> *)mappedArrayUsingBlock:(id (^)(id object))map {
    return [self filteredAndMappedArrayUsingBlock:^id _Nullable(id  _Nonnull object) {
        return map(object);
    }];
}

- (NSArray *)filteredAndMappedArrayUsingBlock:(id (^)(id object))mapAndfilter {
    NSArray *newArray = nil;
    
    if ([self count] < 100) {
        id __strong objects[[self count]];
        NSInteger count = 0;
        for (id object in self) {
            id mappedAndFilteredObject = mapAndfilter(object);
            if (mappedAndFilteredObject) {
                objects[count++] = mappedAndFilteredObject;
            }
        }
        newArray = [NSArray arrayWithObjects:objects count:count];
    } else {
        NSMutableArray *buildArray = [NSMutableArray array];
        for (id object in self) {
            id mappedAndFilteredObject = mapAndfilter(object);
            if (mappedAndFilteredObject) {
                [buildArray addObject:mappedAndFilteredObject];
            }
        }
        newArray = buildArray;
    }
    return newArray;
}

- (NSSet *)ajr_uniqueObjects {
    return [NSSet setWithArray:self];
}

- (NSArray *)ajr_orderedUniqueObjects {
    NSMutableArray *unique = [NSMutableArray array];
    for (id object in self) {
        if ([unique indexOfObject:object] == NSNotFound) {
            [unique addObject:object];
        }
    }
    return unique;
}

#pragma mark - Searching

- (ObjectType)ajr_firstObjectPassingTest:(BOOL (^)(ObjectType object))test {
    __block id foundObject = nil;
    for (id object in self) {
        if (test(object)) {
            foundObject = object;
            break;
        }
    }
    return foundObject;
}

- (ObjectType)ajr_lastObjectPassingTest:(BOOL (^)(ObjectType object))test {
    __block id foundObject = nil;
    for (id object in [self reverseObjectEnumerator]) {
        if (test(object)) {
            foundObject = object;
            break;
        }
    }
    return foundObject;
}

#pragma mark - Copying

- (id)deepCopy {
    return [self deepCopyWithZone:NULL];
}

- (id)deepCopyWithZone:(NSZone *)zone {
    id __strong *buffer = (id __strong *)calloc(self.count, sizeof(id));

    for (NSInteger x = 0, max = [self count]; x < max; x++) {
        id <NSCopying,NSObject> object = [self objectAtIndex:x];
        if ([object respondsToSelector:@selector(copyWithZone:)]) {
            buffer[x] = [object copyWithZone:zone];
        } else {
            buffer[x] = object;
        }
    }

    NSArray *array = [[NSArray alloc] initWithObjects:buffer count:self.count];
    free(buffer);
    return array;
}

- (id)mutableDeepCopy {
    return [self mutableDeepCopyWithZone:NULL];
}

/*! Copies the array by sending -[id<NSCopying> copy] to each element. */
- (id)mutableDeepCopyWithZone:(NSZone *)zone {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];

    for (id <NSCopying,NSObject> object in self) {
        if ([object respondsToSelector:@selector(mutableCopyWithZone:)]) {
            // This is a little jinky, but there's no NSMutableCopying protocol, so we're just using NSString as a stand in to make the compiler recognize this selector.
            [array addObject:[(NSString *)object mutableCopyWithZone:zone]];
        } else if ([object respondsToSelector:@selector(copyWithZone:)]) {
            [array addObject:[object copyWithZone:zone]];
        } else {
            [array addObject:object];
        }
    }

    return array;
}

#pragma mark - Joining

- (NSString *)componentsJoinedByString:(NSString *)separator twoValueSeparator:(NSString *)twoValueSeparator finalSeparator:(NSString *)finalSeparator {
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger x = 0; x < [self count]; x++) {
        id object = [self objectAtIndex:x];
        if ([string length] == 0) {
            [string appendString:[object description]];
        } else {
            if ([self count] == 2 && twoValueSeparator != nil) {
                [string appendString:twoValueSeparator];
            } else if (x == [self count] - 1 && finalSeparator != nil) {
                [string appendString:finalSeparator];
            } else {
                [string appendString:separator];
            }
            [string appendString:[object description]];
        }
    }

    return string;
}


@end
