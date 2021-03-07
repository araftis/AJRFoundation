//
//  EditingContext.m
//  iTunes Movie Importer
//
//  Created by A.J. Raftis on 2/26/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJREditingContext.h"

#import "AJREditableObject.h"
#import "AJRLogging.h"

@interface AJREditableObject ()

- (void)undoValue:(id)value forKey:(NSString *)key;

@end


@implementation AJREditingContext {
    NSHashTable *_objects;
    NSHashTable *_editedObjects;
    NSMutableDictionary *_recentlyEditedObjects;

    BOOL _delegateRespondsToDidObserveEdit;
}

#pragma mark Creation

- (id)init {
    if ((self = [super init])) {
        _objects = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:1000];
        _editedObjects = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:100];
        _recentlyEditedObjects = [[NSMutableDictionary alloc] init];
        _undoManager = [[NSUndoManager alloc] init];
    }
    return self;
}

#pragma mark Destruction

- (void)dealloc {
    for (AJREditableObject *object in _objects) {
        [object removeObserver:self];
    }

}

#pragma mark - Extended Properties

- (NSHashTable *)objects {
    return _objects;
}

- (NSHashTable *)editedObjects {
    return _editedObjects;
}

- (NSArray *)editedObjectsOfType:(Class)objectType {
    NSMutableArray	*objects = [NSMutableArray array];

    for (id object in _editedObjects) {
        if ([object isKindOfClass:objectType]) {
            [objects addObject:object];
        }
    }

    return objects;
}

- (void)setDelegate:(id <AJREditingContextDelegate>)delegate {
    _delegate = delegate;
    _delegateRespondsToDidObserveEdit = [_delegate respondsToSelector:@selector(editingContext:didObserveEditsForKeys:onObject:)];
}

#pragma mark Object Management

- (void)addObject:(AJREditableObject *)object {
    if (![_objects containsObject:object]) {
        if ([object editingContext] == nil) {
            [_objects addObject:object];
            [object setEditingContext:self];
            [object addObserver:self];
        } else if ([object editingContext] != self) {
            AJRLogError(@"Attempt to add object %@ to two different editing contexts", object);
        }
    }
}

- (BOOL)containsObject:(AJREditableObject *)object {
    return [_objects containsObject:object];
}

- (void)forgetObject:(AJREditableObject *)object {
    if ([_objects containsObject:object]) {
        [self willChangeValueForKey:@"editedObjects"];
        [self willChangeValueForKey:@"hasEdits"];
        [_objects removeObject:object];
        [_editedObjects removeObject:object];
        [object setEditingContext:nil];
        [object removeObserver:self];
        [self didChangeValueForKey:@"hasEdits"];
        [self didChangeValueForKey:@"editedObjects"];
    }
}

- (void)forgetEdits:(AJREditableObject *)object {
    if ([_editedObjects containsObject:object]) {
        [self willChangeValueForKey:@"editedObjects"];
        [self willChangeValueForKey:@"hasEdits"];
        [_editedObjects removeObject:object];
        [object clearEdits];
        [self didChangeValueForKey:@"hasEdits"];
        [self didChangeValueForKey:@"editedObjects"];
    }
}

- (BOOL)hasEdits {
    return [_editedObjects count] != 0;
}

#pragma mark EditObserver

- (void)notifyDelegateOfRecentlyEditedObjects {
    for (NSValue *pointer in _recentlyEditedObjects) {
        id object = (__bridge_transfer id)[pointer pointerValue];
        NSSet *keys = [_recentlyEditedObjects objectForKey:pointer];
        [_delegate editingContext:self didObserveEditsForKeys:keys onObject:object];
    }
    [_recentlyEditedObjects removeAllObjects];
}

- (void)object:(id)object didEditKey:(NSString *)key withChange:(NSDictionary *)change {
    AJRLogDebug(@"edit: %@", key);

    if (_delegateRespondsToDidObserveEdit) {
        if (key) {
            NSValue *localKey;
            NSMutableSet *keys;

            if ([_recentlyEditedObjects count] == 0) {
                [self performSelector:@selector(notifyDelegateOfRecentlyEditedObjects) withObject:nil afterDelay:0.0];
            }

            localKey = [NSValue valueWithPointer:(__bridge_retained void *)object];
            keys = [_recentlyEditedObjects objectForKey:localKey];
            if (keys == nil) {
                keys = [[NSMutableSet alloc] init];
                [_recentlyEditedObjects setObject:keys forKey:localKey];
            }
            [keys addObject:key];
        }
    }

    if (![_editedObjects containsObject:object]) {
        [self willChangeValueForKey:@"editedObjects"];
        [self willChangeValueForKey:@"hasEdits"];
        [_editedObjects addObject:object];
        [self didChangeValueForKey:@"hasEdits"];
        [self didChangeValueForKey:@"editedObjects"];
    }

    if (_undoManager && key != nil) { // Only changes with keys can be undone.
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];

        if (oldValue == (id)[NSNull null]) oldValue = nil;

        [[_undoManager prepareWithInvocationTarget:object] undoValue:oldValue forKey:key];
    }
}

@end
