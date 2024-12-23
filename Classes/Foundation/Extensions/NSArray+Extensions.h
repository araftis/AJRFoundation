/*
 NSArray+Extensions.h
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

#import <AJRFoundation/AJRXMLArchiver.h>
#import <AJRFoundation/AJRXMLCoding.h>
#import <AJRFoundation/AJRCollection.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRVariable;

extern const NSComparator AJRSimpleCompare;

@interface NSArray<ObjectType> (AJRFoundationExtensions) <AJRXMLEncoding>

#pragma mark - Convenience Initializers

+ (instancetype)arrayWithCollection:(id <AJRCollection>)collection;

#pragma mark - Set Math

- (NSArray *)differencesFromArray:(NSArray *)other;

#pragma mark - Searching

- (NSUInteger)findIndexOfObject:(id)object;
- (NSUInteger)findIndexOfObject:(id)object usingComparator:(NSComparator)comparator;
- (NSUInteger)findInsertionIndexForObject:(id)object;
- (NSUInteger)findInsertionIndexForObject:(id)object usingComparator:(NSComparator)comparator;

- (BOOL)containsObjectIdenticalTo:(id)anObject;

- (void)makeObjectsPerformSelectorIfImplemented:(SEL)selector withObject:(id)object;
- (void)makeObjectsPerformSelectorIfImplemented:(SEL)selector withObject:(id)object withObject:(id)object2;
- (void)makeObjectsSetIntegerValue:(NSInteger)value withSelector:(SEL)selector;
- (void)makeObjectsSetFloatValue:(float)value withSelector:(SEL)selector;
- (void)makeObjectsSetDoubleValue:(double)value withSelector:(SEL)selector;
- (void)makeObjectsSetBOOLValue:(BOOL)value withSelector:(SEL)selector;
- (void)makeObjectsPerformInvocation:(NSInvocation *)invocation;

- (NSArray*)arraySplitIntoBatchedArrayWithItemsPerBatch:(NSUInteger)numberOfItemsInBatch;

+ (id)createFromPropertyList:(id)propertyList class:(Class)aClass error:(NSError **)error;
- (id)propertyListValue;

#pragma mark - Filtering and Mapping

- (NSArray<__kindof ObjectType> *)filteredArrayUsingBlock:(BOOL (^)(ObjectType object))filter;
- (NSArray<__kindof ObjectType> *)mappedArrayUsingBlock:(ObjectType (^)(ObjectType object))map;
- (NSArray *)filteredAndMappedArrayUsingBlock:(id _Nullable (^)(ObjectType object))mapAndfilter;

/*!
 @discussion Returns only the unique objects in the receiver. This method is relatively quick, as it returns the results as a set. This method may not work as expected if the objects in the array do not correctly implement isEqual:.
 
 @return A set of unique objects.
 */
- (NSSet<ObjectType> *)ajr_uniqueObjects;
/*!
 @discussion This method works much like ajr_uniqueObjects, except the order of the objects is preserved in the returned array. This method is likely to be much slower than calling ajr_uniqueObjects, but if order is important, you may need to call it.
 
 @return The receiver's objects with each object appearing at most one time, and in the order the objects appear in the original array. Note that the order in the output array will be ordered by the object's first appearance in the array, so if the input is [1, 2, 3, 2], then the output will be [1, 2, 3] rather than [1, 3, 2].
*/
- (NSArray<ObjectType> *)ajr_orderedUniqueObjects;

#pragma mark - Searching

- (nullable ObjectType)ajr_firstObjectPassingTest:(BOOL (^)(ObjectType object))test;
- (nullable ObjectType)ajr_lastObjectPassingTest:(BOOL (^)(ObjectType object))test;

#pragma mark - Copying

/*! Copies the array by sending -[id<NSCopying> copy] to each element. */
- (id)deepCopy;
- (id)deepCopyWithZone:(nullable NSZone *)zone;

- (id)mutableDeepCopy;
- (id)mutableDeepCopyWithZone:(nullable NSZone *)zone;

#pragma mark - Joining

/**
 Joins the values of a collection into a string.
 
 Joins the components of the collection using `separator` between the objects. If `twoValueSeparator` and `finalSeparator` are supplied this are used between the values when there's only two, or between the last two values. For example, if you call:
 
 ````
 [1].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
 ````
 
 you'd get:
 
 ````
 "1"
 ````
 
 If you call:
 
 ````
 [1, 2].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
 ````
 
 you'd get:
 
 ````
 "1 and 2"
 ````
 
 And if you call:
 
 ````
 [1, 2, 3].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
 ````
 
 you'd get:
 
 ````
 "1, 2, and 3"
 ````
 
 Either one or both of `twoValueSeparator` and `finalSeparator` may be omitted parameters, in which case their values are `nil`.
 
 - parameter separator: The primary string to use between values.
 - parameter twoValueSeparator: The string to use between values when there are exactly two values in the collection. May be nil, in which case `separator` is used.
 - parameter finalSeparator: The tring to use between the final two values of the collection when the collection has three or more values. If `twoValueSeparator` is nil, but `finalSeparator` is not, then the `finalSeparator` will be used between the values in a two value collection.
 
 - returns: The constructed string. See above for examples.
 */
- (NSString *)componentsJoinedByString:(NSString *)separator twoValueSeparator:(nullable NSString *)twoValueSeparator finalSeparator:(nullable NSString *)finalSeparator;

#pragma mark - Invalidation Conveniences

/**
 @discussion Calls -[AJRInvalidation invalidate] on all objects in the receiver.
 */
- (void)invalidateObjects;

#pragma mark - Variables

- (BOOL)containsVariable:(AJRVariable *)variable;

@end

NS_ASSUME_NONNULL_END
