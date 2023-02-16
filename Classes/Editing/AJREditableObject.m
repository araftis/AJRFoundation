/*
 AJREditableObject.m
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

#import "AJREditableObject.h"

#import "AJREditingContext.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "AJRMutableCountedDictionary.h"
#import "AJRRuntime.h"
#import "NSPointerArray+Extensions.h"

#if !defined(AJRFoundation_iOS)
#import <objc/objc-class.h>
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#endif

static NSMutableDictionary<Class, NSSet<NSString *> *> *_propertiesToIgnoreByClass = nil;
static NSMutableDictionary<Class, NSSet<NSString *> *> *_propertiesToObserveByClass = nil;
static NSMutableDictionary<Class, NSSet<NSString *> *> *_editableFriendsPropertiesByClass = nil;

@interface AJREditableObject ()

- (void)_notifyObserversOfChange:(NSDictionary *)change forKey:(NSString *)key;

@end


@implementation AJREditableObject {
    AJRMutableCountedDictionary *_keyValueObserverInitialValues;
}

#pragma mark - Initialization

+ (void)initialize {
    if (_propertiesToIgnoreByClass == nil) {
        _propertiesToIgnoreByClass = [[NSMutableDictionary alloc] init];
        _propertiesToObserveByClass = [[NSMutableDictionary alloc] init];
        _editableFriendsPropertiesByClass = [[NSMutableDictionary alloc] init];
    }
}

#pragma mark - Creation

- (id)init {
    if ((self = [super init])) {
        [self setEditedKeys:[NSSet set]];
        objc_setAssociatedObject(self, @selector(editedKeys), [NSMutableSet set], OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(self, @selector(observers), [NSPointerArray weakObjectsPointerArray], OBJC_ASSOCIATION_RETAIN);
        _keyValueObserverInitialValues = [AJRMutableCountedDictionary dictionary];
        [self setSuppressCount:0];
        [self setPauseCount:0];
    }
    return self;
}

#pragma mark - Destruction

- (void)dealloc {
    if ([self suppressCount] > 0) {
        [self stopTrackingEdits];
    }
}


#pragma mark - Properties

@synthesize editingContext = _editingContext;

+ (NSSet *)propertiesToIgnore {
    return [NSSet setWithObjects:@"ajr_nameForXMLArchiving", @"superclass", @"description", @"debugDescription", @"hash", nil];
}

+ (NSSet<NSString *> *)editableFriendPropertiesToIgnore {
    return nil;
}

+ (NSSet *)propertiesToIgnoreForClass:(Class)class {
    NSSet<NSString *> *set = nil;

    @synchronized (_propertiesToIgnoreByClass) {
        set = [_propertiesToIgnoreByClass objectForKey:class];
        if (set == nil) {
            set = [class propertiesToIgnore];
            if (set == nil) {
                set = [NSSet set];
            }
            [_propertiesToIgnoreByClass setObject:set forKey:(id)class];
        }
    }

    return set;
}

+ (void)populatePropertiesToObserve:(NSMutableSet *)propertiesSet editableFriends:(NSMutableSet<NSString *> *)editableFriends {
    // First, let's see if we've already populated for the given class. If we have, we can just add the what we've already found. This is definitely worth while to short circuit, because scanning the properties can be a little expensive.
    NSSet<NSString *> *p1 = _propertiesToObserveByClass[self];
    NSSet<NSString *> *f1 = _editableFriendsPropertiesByClass[self];
    if (p1 != nil || f1 != nil) {
        if (p1 != nil) {
            [propertiesSet unionSet:p1];
        }
        if (f1 != nil) {
            [editableFriends unionSet:f1];
        }
        return;
    }
    
    // Otherwise, we need to do things the hard way.
    unsigned int count;
    objc_property_t	*properties;
    NSSet *ignore = [self propertiesToIgnore];
    NSSet *ignoreFriends = [self editableFriendPropertiesToIgnore];

    properties = class_copyPropertyList([self class], &count);

    for (NSInteger x = 0; x < count; x++) {
        NSString *name = [NSString stringWithUTF8String:property_getName(properties[x])];
        if (![ignore containsObject:name]) {
            [propertiesSet addObject:name];
            if (![ignoreFriends containsObject:name]) {
                const char *props = property_getAttributes(properties[x]);
                if (props != NULL) {
                    if (strlen(props) > 2 && props[1] == '@' && props[2] == '"') {
                        // This means we have an object type, and we've been returned it's actual class name.
                        BOOL isReadOnly = strstr(props, ",R") != NULL;
                        BOOL isWeak = strstr(props, ",W") != NULL;
                        if (!isWeak && !isReadOnly) {
                            // We're not going to track weak references as friends, so again, short circuit here if the property is weak, without even checking its class. We ignore weak, because we assume we're not allowing full circular references, but instead we'll have a parent and child relationship where the parent will have a strong reference to the child, but the child a weak reference to the parent. As such, the parent will add the child to its editing context, but the child will not try to do the same with its parent.
                            char *stop = strchr(props + 3, '"');
                            if (stop != NULL) {
                                NSInteger length = stop - props - 3;
                                char buffer[1024];
                                strncpy(buffer, props + 3, MIN(length, 1023));
                                buffer[length] = '\0';
                                Class found = objc_getClass(buffer);
                                if (found != Nil && AJRIsKindOfClass(found, [AJREditableObject class])) {
                                    [editableFriends addObject:name];
                                    AJRPrintf(@"%@: %@: %s: %s\n", self, isWeak ? @"Weak" : @"Strong", property_getName(properties[x]), props);
                                }
                            } // stop != NULL
                        } // !isWeak && !isReadonly
                    } // property defines class
                } // props != NULL (property attributes)
            } // ![ignoreFriends containsObject:name]
        } // ![ignore containsObject:name]
    } // foreach property.

    free(properties);
    
    Class superclass = self;
    while ((superclass = [superclass superclass]) && superclass != [AJREditableObject class]) {
        NSMutableSet<NSString *> *newClassProperties = [NSMutableSet set];
        NSMutableSet<NSString *> *newFriendsProperties = [NSMutableSet set];
        [superclass populatePropertiesToObserve:newClassProperties editableFriends:newFriendsProperties];
        _propertiesToObserveByClass[(id)superclass] = newClassProperties;
        _editableFriendsPropertiesByClass[(id)superclass] = newFriendsProperties;
        [propertiesSet unionSet:newClassProperties];
        [editableFriends unionSet:newFriendsProperties];
    }
}

+ (NSSet<NSString *> *)propertiesToObserve {
    NSSet<NSString *> *set = nil;
    NSSet<NSString *> *friendsSet = nil;
    
    @synchronized (_propertiesToObserveByClass) {
        set = [_propertiesToObserveByClass objectForKey:[self class]];
        friendsSet = [_editableFriendsPropertiesByClass objectForKey:[self class]];

        if (set == nil) {
            set = [NSMutableSet set];
            friendsSet = [NSMutableSet set];
            [self populatePropertiesToObserve:(NSMutableSet *)set editableFriends:(NSMutableSet *)friendsSet];
            [_propertiesToObserveByClass setObject:set forKey:(id)[self class]];
            [_editableFriendsPropertiesByClass setObject:friendsSet forKey:(id)[self class]];
        }
    }

    return set;
}

+ (NSSet<NSString *> *)editableFriendProperties {
    // Force the population of editableFriends.
    [self propertiesToObserve];
    
    return [_editableFriendsPropertiesByClass objectForKey:[self class]];
}


#pragma mark - Identity

- (id)primaryKey {
    id primaryKey = nil;
    @synchronized (self) {
        primaryKey = objc_getAssociatedObject(self, @selector(primaryKey));
        if (primaryKey == nil) {
            primaryKey = [NSValue valueWithPointer:(__bridge const void *)(self)];
            objc_setAssociatedObject(self, @selector(primaryKey), primaryKey, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return primaryKey;
}

#pragma mark - Friends

- (void)enumerateFriendsUsingBlock:(void (^)(AJREditableObject *friend))block {
    for (NSString *property in [self.class editableFriendProperties]) {
        AJREditableObject *friend = AJRObjectIfKindOfClass([self valueForKey:property], AJREditableObject);
        if (friend != nil) {
            block(friend);
        }
    }
}

#pragma mark - Tracking

- (void)setSuppressCount:(NSInteger)count {
    objc_setAssociatedObject(self, @selector(suppressCount), @(count), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)suppressCount {
    return [objc_getAssociatedObject(self, @selector(suppressCount)) integerValue];
}

- (void)startTrackingEdits {
    @synchronized (self) {
        [self setSuppressCount:[self suppressCount] + 1];
        // Start tracking edits on our friends, too.
        [self enumerateFriendsUsingBlock:^(AJREditableObject *friend) {
            [friend startTrackingEdits];
        }];
    }
}

- (void)stopTrackingEdits {
    @synchronized (self) {
        [self setSuppressCount:[self suppressCount] - 1];
        // Stop tracking edits on our friends, too.
        [self enumerateFriendsUsingBlock:^(AJREditableObject *friend) {
            [friend stopTrackingEdits];
        }];
    }
}

- (void)setPauseCount:(NSInteger)count {
    objc_setAssociatedObject(self, @selector(pauseCount), @(count), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)pauseCount {
    return [objc_getAssociatedObject(self, @selector(pauseCount)) integerValue];
}

- (void)pauseObservation {
    @synchronized (self) {
        [self setPauseCount:[self pauseCount] + 1];
        [self enumerateFriendsUsingBlock:^(AJREditableObject *friend) {
            [friend pauseObservation];
        }];
    }
}

- (void)resumeObservation {
    @synchronized (self) {
        NSInteger pauseCount = [self pauseCount];
        if (pauseCount > 0) {
            [self setPauseCount:[self pauseCount] - 1];
        }
        [self enumerateFriendsUsingBlock:^(AJREditableObject *friend) {
            [friend resumeObservation];
        }];
    }
}

- (void)synchronizeObservationStateWithFriend:(AJREditableObject *)friend {
    [friend setPauseCount:[self pauseCount]];
    [friend setSuppressCount:[self suppressCount]];
}

- (NSMutableSet<NSString *> *)mutableEditedKeys {
    return AJRObjectIfKindOfClass(self.editedKeys, NSMutableSet);
}

- (NSSet<NSString *> *)editedKeys {
    return objc_getAssociatedObject(self, @selector(editedKeys));
}

- (void)setEditedKeys:(NSSet<NSString *> *)keys {
    objc_setAssociatedObject(self, @selector(editedKeys), [keys mutableCopy], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)hasEdits {
    return [self.editedKeys count] != 0;
}

- (BOOL)validateForSaveWithContext:(NSDictionary *)context error:(NSError **)error {
    return YES;
}

- (BOOL)saveWithContext:(NSDictionary *)context error:(NSError **)error {
    NSError *localError = nil;
    
    @try {
        if ([self validateForSaveWithContext:context error:&localError] && [self performSaveWithContext:context error:&localError]) {
            [self clearEdits];
        }
    } @catch (NSException *exception) {
        localError = [NSError errorWithDomain:@"MP4ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unexpected exception: %@", [exception description]]}];
    }
    return AJRAssertOrPropagateError(localError == nil, error, localError);
}

- (BOOL)performSaveWithContext:(NSDictionary *)context error:(NSError **)error {
    // Just succeed. We don't actually expect to get called.
    return YES;
}

- (BOOL)revertWithError:(NSError **)error {
    return NO;
}

- (void)clearEdits {
    AJRRunSyncOnMainThread(^{
        [self willChangeValueForKey:@"hasEdits"];
        [[self mutableEditedKeys] removeAllObjects];
        [self->_editingContext forgetEdits:self];
        [self didChangeValueForKey:@"hasEdits"];
    });
}

- (void)noteAllKeysEdited {
    [self willChangeValueForKey:@"hasEdits"];
    [[self mutableEditedKeys] unionSet:[self.class propertiesToObserve]];
    [self _notifyObserversOfChange:nil forKey:nil];
    [self didChangeValueForKey:@"hasEdits"];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([self pauseCount] == 0 && object == self) {
        if ([[[self class] propertiesToObserve] containsObject:keyPath]) {
            // Only add some keys. For example, we don't want to observe has edits as an editable key.
            [self willChangeValueForKey:@"hasEdits"];
            [[self mutableEditedKeys] addObject:keyPath];
            [self didChangeValueForKey:@"hasEdits"];
            //AJRLogDebug(@"%@ <0x%x>: edit %@", NSStringFromClass([self class]), self, keyPath);
            [self _notifyObserversOfChange:change forKey:keyPath];
        }
    }
}

#pragma mark - Observation

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    if ([self suppressCount] > 0 && [[self class] propertiesToObserve]) {
        id value = [self valueForKeyPath:key];
        if (value) {
            if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSSet class]]) {
                value = [value copy];
            }
            [_keyValueObserverInitialValues setObject:value forKey:key];
//        } else {
//        [_keyValueObserverInitialValues removeObjectForKey:key];
        }
    }
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    if ([self suppressCount] > 0 && [[self class] propertiesToObserve]) {
        id oldValue = [_keyValueObserverInitialValues objectForKey:key];
        id newValue = [self valueForKeyPath:key];
        NSDictionary *change;
        if (oldValue && !newValue) {
            change = @{NSKeyValueChangeOldKey:oldValue};
        } else if (!oldValue && newValue) {
            change = @{NSKeyValueChangeNewKey:newValue};
        } else if (oldValue && newValue) {
            change = @{NSKeyValueChangeOldKey:oldValue, NSKeyValueChangeNewKey:newValue};
        } else {
            change = @{};
        }
        [self observeValueForKeyPath:key ofObject:self change:change context:NULL];
        [_keyValueObserverInitialValues removeObjectForKey:key];
    }
}

- (void)_notifyObserversOfChange:(NSDictionary *)change forKey:(NSString *)key {
    for (id <AJREditObserver> observer in self.observers) {
        [observer object:self didEditKey:key withChange:change];
    }
}

- (NSPointerArray *)mutableObservers {
    return AJRObjectIfKindOfClassOrNilOrAssert(self.observers, NSPointerArray);
}

- (NSArray<id <AJREditObserver>> *)observers {
    return objc_getAssociatedObject(self, @selector(observers));
}

- (void)addObserver:(id <AJREditObserver>)observer {
    @synchronized (self) {
        [self.mutableObservers addObject:observer];
    }
}

- (void)removeObserver:(id <AJREditObserver>)observer {
    @synchronized (self) {
        [self.mutableObservers removeObjectIdenticalTo:observer];
    }
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return [[self primaryKey] hash];
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (![other isKindOfClass:[AJREditableObject class]]) return NO;
    
    return [[self primaryKey] isEqual:[other primaryKey]];
}

#pragma mark - Undo Management

- (void)undoValue:(id)value forKey:(NSString *)key {
    [self setValue:value forKeyPath:key];
}

#pragma mark - NSCopying

- (Class)classForCopy {
    return [self class];
}

- (id)copyWithZone:(NSZone *)zone {
    AJREditableObject *copy = [[[self class] allocWithZone:zone] init];

    [copy setEditedKeys:self.editedKeys];

    return copy;
}

#pragma mark - Lifecycle

- (void)willAddToEditingContext:(AJREditingContext *)context {
}

- (void)didAddToEditingContext:(AJREditingContext *)context {
}

- (void)willRemoveFromEditingContext:(AJREditingContext *)context {
    // Do nothing by default
}

- (void)didRemoveFromEditingContext:(AJREditingContext *)context {
    // Do nothing by default
}

@end
