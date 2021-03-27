
#import "NSMutableArray+Extensions.h"

#import "AJRFunctions.h"
#import "AJRLogging.h"

#import <objc/runtime.h>

@interface AJRArrayLoader : NSObject

@end

typedef id ObjectType;

typedef void (*AJRInsertObjectIMP)(id, SEL, id, NSUInteger);

@implementation AJRArrayLoader

static AJRInsertObjectIMP originalIMP;

+ (void)load {
    // If you're having strange bugs with KVO, this might help you identify the problem, as it'll log a message each time didChangeValueForKey: is called, although only on the main thread.
#if defined (AJR_DEBUG)
	Method method = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(insertObject:atIndex:));
	Method replacementMethod = class_getInstanceMethod(self, @selector(ajr_insertObject:atIndex:));
	if (method && replacementMethod) {
		originalIMP = (AJRInsertObjectIMP)method_getImplementation(method);
		method_setImplementation(method, method_getImplementation(replacementMethod));
	}
#endif
}

static void _AJRInsertNilObjectAtIndex(id self, id object, NSUInteger index) {
    AJRLog(nil, AJRLogLevelWarning, @"Attempt to insert nil object into array. Break on _AJRInsertNilObjectAtIndex() to debug.");
}

- (void)ajr_insertObject:(id)object atIndex:(NSUInteger)index {
    if (object == nil) {
        _AJRInsertNilObjectAtIndex(self, object, index);
    }
	originalIMP(self, @selector(insertObject:atIndex:), object, index);
}

@end


@implementation NSMutableArray (AJRExtensions)

- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)otherIndex {
    if (index != otherIndex) {
        id temp = [self objectAtIndex:index];
        
        [self removeObjectAtIndex:index];
        
        if (index < otherIndex) {
            [self insertObject:temp atIndex:otherIndex - 1];
        } else {
            [self insertObject:temp atIndex:otherIndex];
        }
    }
}

- (BOOL)insertObjectIfNotNil:(nullable ObjectType)object atIndex:(NSUInteger)index {
	if (object != nil) {
		[self insertObject:object atIndex:index];
	}
	return object != nil;
}

- (BOOL)addObjectIfNotNil:(id)object {
	if (object != nil) {
		[self addObject:object];
	}
	return object != nil;
}

- (void)addObject:(id)object atIndex:(NSUInteger)index {
    while (index >= [self count]) {
        [self addObject:[NSNull null]];
    }
    [self replaceObjectAtIndex:index withObject:object];
}

- (NSUInteger)addSortedObject:(id)object {
    return [self addSortedObject:object usingComparator:AJRSimpleCompare];
}

- (NSUInteger)addSortedObject:(id)object usingComparator:(NSComparator)comparator {
    NSUInteger index = [self findInsertionIndexForObject:object usingComparator:(NSComparator)comparator];
    
	if (index != NSNotFound) {
		[self insertObject:object atIndex:index];
	}
	
	return index;
}

#pragma mark - Conveniences

- (void)insertObjects:(NSArray<ObjectType> *)children atIndex:(NSUInteger)index {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (NSInteger x = 0; x < children.count; x++) {
        [indexes addIndex:x + index];
    }
    [self insertObjects:children atIndexes:indexes];
}

- (void)removeFirstObjectPassingTest:(BOOL (^)(id object))test {
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        if (test(object)) {
            [self removeObjectAtIndex:index];
            *stop = YES;
        }
    }];
}

- (void)removeObjectsPassingTest:(BOOL (^)(id object))test {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        if (test(object)) {
            [indexes addIndex:index];
        }
    }];
    [self removeObjectsAtIndexes:indexes];
}

#pragma mark - AJRXMLCoding

+ (NSString *)ajr_nameForXMLArchiving {
	return @"mutable-array";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSMutableArray class];
}

@end
