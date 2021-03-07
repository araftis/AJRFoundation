//
//  EditableObject.h
//  iTunes Movie Importer
//
//  Created by A.J. Raftis on 2/12/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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
 Subclasses can override this method to provide a set of properties that should not be tracked.
 Otherwise, anything declared as a property will be tracked.
 
 @result The set of properties to ignore. May be nil.
 */
@property (nonatomic,class,readonly) NSSet<NSString *> *propertiesToIgnore;
/*!
 Overridden by some subclasses to populate additional properties for observation. Generally needed by Swift objects, which don't necessarily follow Obj-C rules for properties.
 */
+ (void)populatePropertiesToObserve:(NSMutableSet<NSString *> *)propertiesSet;
@property (nonatomic,class,readonly) NSSet<NSString *> *propertiesToObserve;

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

@end
