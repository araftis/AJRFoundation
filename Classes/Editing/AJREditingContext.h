//
//  EditingContext.h
//  iTunes Movie Importer
//
//  Created by A.J. Raftis on 2/26/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AJRFoundation/AJREditableObject.h>

@class AJREditableObject;

@protocol AJREditingContextDelegate <NSObject>

@optional - (void)editingContext:(AJREditingContext *)editingContext didObserveEditsForKeys:(NSSet *)keys onObject:(id)object;

@end


@interface AJREditingContext : NSObject <AJREditObserver>

@property (nonatomic,strong) NSUndoManager *undoManager;
@property (nonatomic,weak) id <AJREditingContextDelegate> delegate;

@property (nonatomic,readonly) NSHashTable *objects;
@property (nonatomic,readonly) NSHashTable *editedObjects;
- (NSArray *)editedObjectsOfType:(Class)objectType;

#pragma mark - Object Management

- (void)addObject:(AJREditableObject *)object;
- (BOOL)containsObject:(AJREditableObject *)object;
- (void)forgetObject:(AJREditableObject *)object;
- (void)forgetEdits:(AJREditableObject *)object;

@property (nonatomic,readonly) BOOL hasEdits;

@end

