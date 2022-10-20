/*
AJREditingContext.m
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
    BOOL _delegateRespondsToShouldRegisterUndo;
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
    _delegateRespondsToShouldRegisterUndo = [_delegate respondsToSelector:@selector(editingContext:shouldRegisterUndoOfValue:forKey:onObject:)];
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

    if ((_undoManager || _delegateRespondsToShouldRegisterUndo) && key != nil) { // Only changes with keys can be undone.
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];

        if (oldValue == (id)[NSNull null]) oldValue = nil;

        if (!_delegateRespondsToShouldRegisterUndo || [_delegate editingContext:self shouldRegisterUndoOfValue:oldValue forKey:key onObject:object]) {
            [[_undoManager prepareWithInvocationTarget:object] undoValue:oldValue forKey:key];
        }
    }
}

@end
