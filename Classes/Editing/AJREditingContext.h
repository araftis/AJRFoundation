/*
AJREditingContext.h
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

#import <Foundation/Foundation.h>

#import <AJRFoundation/AJREditableObject.h>

@class AJREditableObject;

@protocol AJREditingContextDelegate <NSObject>

@optional - (void)editingContext:(AJREditingContext *)editingContext didObserveEditsForKeys:(NSSet *)keys onObject:(id)object;
@optional - (BOOL)editingContext:(AJREditingContext *)editingContext shouldRegisterUndoOfValue:(id)value forKey:(NSString *)key onObject:(id)object;

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

