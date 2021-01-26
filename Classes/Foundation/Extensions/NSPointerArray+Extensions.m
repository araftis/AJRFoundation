//
//  NSPointerArray+Extensions.m
//  AJRFoundation
//
//  Created by AJ Raftis on 12/6/19.
//

#import "NSPointerArray+Extensions.h"

#import <AppKit/AppKit.h>

@implementation NSPointerArray (Extensions)

- (void)addObject:(id)object {
    [self addPointer:(__bridge void *)object];
}

- (void)removeObject:(id)object {
    NSUInteger index = [self indexOfObject:object];
    if (index != NSNotFound) {
        [self removePointerAtIndex:index];
    }
}

- (void)removeObjectIdenticalTo:(id)object {
    NSUInteger index = [self indexOfObjectIdenticalTo:object];
    if (index != NSNotFound) {
        [self removePointerAtIndex:index];
    }
}

- (NSUInteger)indexOfObject:(id)object {
    for (NSInteger x = 0; x < self.count; x++) {
        if ([(__bridge id)[self pointerAtIndex:x] isEqual:object]) {
            return x;
        }
    }
    return NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)object {
    for (NSInteger x = 0; x < self.count; x++) {
        if ([self pointerAtIndex:x] == (__bridge void *)object) {
            return x;
        }
    }
    return NSNotFound;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id _Nullable object, NSUInteger index, BOOL *stop))block {
    for (NSInteger x = 0; x < self.count; x++) {
        BOOL stop = NO;
        block((__bridge id)[self pointerAtIndex:x], x, &stop);
        if (stop) {
            break;
        }
    }
}

@end
