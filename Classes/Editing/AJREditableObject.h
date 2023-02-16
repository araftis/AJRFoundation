/*
 AJREditableObject.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AJREditObserver

- (void)object:(id)object didEditKey:(NSString *)key withChange:(NSDictionary *)change;

@end

@class AJREditingContext;

@interface AJREditableObject : NSObject <NSCopying>

@property (nonatomic,weak) AJREditingContext *editingContext;

/*!
 @methodgroup Identity
 */

/*!
 Returns the object's primary key. This should be a unique key that identifies the object. If you
 wish to have full object tracking with uniqueness, you'd want to override this method in your
 subclasses to return a unique value. Otherwise, this method simple returns [NSValue valueWithPointer:self].
 
 Whatever is returned for the primary key should respond to -[NSObject hash] and
 -[NSObject isEqual:] in a valid and reasonable manner, or strange things will happen.
 
 @result By default, returns [NSValue valueWithPointer:self]. Subclasses may override to return
 something more useful.
 */
- (id)primaryKey;

- (void)startTrackingEdits;
- (void)stopTrackingEdits;

- (void)pauseObservation;
- (void)resumeObservation;

/*!
 Synchronizes `friend` with the receiver's tracking and observation states. This is mostly useful when a friend is changed, as the new friend will get the current state of the receiver. You shouldn't normally need to call this method, as it'll generally be called for you.
 
 @param friend The object to sync to our state.
 */
- (void)synchronizeObservationStateWithFriend:(AJREditableObject *)friend;

/*!
 Subclasses can override this method to provide a set of properties that should not be tracked.
 Otherwise, anything declared as a property will be tracked.
 
 @result The set of properties to ignore. May be nil.
 */
@property (nullable,nonatomic,class,readonly) NSSet<NSString *> *propertiesToIgnore;
/*!
 This represents an additional subset, beyond `propertiesToIgnore`, that should be ignored as far as automating adding or removing from the receivers editing context. This is `nil` by default.
 */
@property (nullable,nonatomic,class,readonly) NSSet<NSString *> *editableFriendPropertiesToIgnore;
/*!
 Overridden by some subclasses to populate additional properties for observation. Generally needed by Swift objects, which don't necessarily follow Obj-C rules for properties.

 @param propertiesSet The properties that can be observered.
 @param editableFriends Properties that refer to AJREditableObject.
 */
+ (void)populatePropertiesToObserve:(NSMutableSet<NSString *> *)propertiesSet editableFriends:(NSMutableSet<NSString *> *)editableFriends;
/*!
 A set of properties that should be observed on the receiver.
 */
@property (nonatomic,class,readonly) NSSet<NSString *> *propertiesToObserve;
/*!
 A set of properties that should be managed as friends. "Friends" are basically object's that need to be managed in the receiver's editing context, but which aren't otherwise managed externally. This often represents a parent/child relationship in your object graph, where the child also needs to be managed. By default, this will be populated with all properties that are:
 
 1. Not weak (since we properties are generally managed somewhere else),
 2. Are not in the set `editableFriendPropertiesToIgnore`.
 3. Are properties to an object that is a subclass of AJREditableObject.
 */
@property (nonatomic,class,readonly) NSSet<NSString *> *editableFriendProperties;

/*! When inserting a new object into an editing context, you may want to call this, to indicate that all the keys on the objects, at the time of insert, should be considered edited. This doesn't happen by default, because it can create a bunch of extra work when it's sometimes not necessary. */
- (void)noteAllKeysEdited;
@property (nonatomic,readonly) NSSet<NSString *> *editedKeys;
@property (nonatomic,readonly) BOOL hasEdits;
/*! Allows the receiver to validate itself for save. This method is called prior to calling hasEdits, so if the it chooses, the receiver may make modifications to itself, even it it previously had no edits. This allows the receiver to potentially "fix" things in itself. For example, if the "artist" tag of movie isn't set, it could copy over the first director into the artist tag.
 
 @param context Information about what's being saved. The contents are dictacted by the receiver's type and the caller.
 @param error If a validation error occurs, the error parameter should be set, and NO returned.
 @return YES if the object is valid and ready to be saved.
 */
- (BOOL)validateForSaveWithContext:(NSDictionary *)context error:(NSError **)error NS_SWIFT_NAME(validateForSave(context:));
- (BOOL)saveWithContext:(NSDictionary *)context error:(NSError **)error; // Called by user of the object to save the object.
- (BOOL)performSaveWithContext:(NSDictionary *)context error:(NSError **)error; // Overridden by subclasses to do their actual saving
- (BOOL)revertWithError:(NSError **)error;
- (void)clearEdits;

@property (nonatomic,readonly) NSArray<id <AJREditObserver>> *observers;
- (void)addObserver:(id <AJREditObserver>)observer;
- (void)removeObserver:(id <AJREditObserver>)observer;

/*!Allows a subclass to substitute a different class during copy. Normally, this would have to be a subclass, or bad might happen. */
- (Class)classForCopy;

#pragma mark - Undo Management

/*!
 This is used as part of undo management, and will be called when the receiver should undo a change. Normally this just called setValue:forKey: on the receiver, but if your object needs to do something special, you can override this method. If you do override, and wind up doing nothing, then you should generally call super.
 
 @param value The old value that should be reset.
 @param key The key of the property to reset.
 */
- (void)undoValue:(id)value forKey:(NSString *)key;

#pragma mark - Lifecycle

- (void)willAddToEditingContext:(AJREditingContext *)context;
- (void)didAddToEditingContext:(AJREditingContext *)context;
- (void)willRemoveFromEditingContext:(AJREditingContext *)context;
- (void)didRemoveFromEditingContext:(AJREditingContext *)context;

@end

NS_ASSUME_NONNULL_END
