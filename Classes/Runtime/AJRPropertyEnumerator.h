/*
 AJRPropertyEnumerator.h
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

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRPropertyEnumerator : NSEnumerator<NSValue *>

+ (instancetype)propertyEnumeratorWithClass:(Class)enumeratedClass;

@property (nullable,nonatomic,readonly) Protocol *enumeratorProtocol;
@property (nullable,nonatomic,readonly) Class enumeratedClass;
@property (nonatomic,assign) BOOL enumeratesSuperclasses;

- (nullable id)nextObject;
- (nullable objc_property_t)nextProperty;

// MARK: - Querying the Property

/// Returns the name of the property.
@property (nonatomic,readonly,nullable) NSString *propertyName;
/// Returns `YES` if the class is a class property.
@property (nonatomic,readonly) BOOL propertyIsClassProperty;
/// Returns `YES` if the property is copy on assign.
@property (nonatomic,readonly) BOOL propertyIsCopy;
/// Returns `YES` if the property is a strong (retain) reference.
@property (nonatomic,readonly) BOOL propertyIsStrong;
/// Returns `YES` for read only properties.
@property (nonatomic,readonly) BOOL propertyIsReadOnly;
/// Returns `YES` for weakly declared properties.
@property (nonatomic,readonly) BOOL propertyIsWeak;
/// Returns `YES` if the property is atomic.
@property (nonatomic,readonly) BOOL propertyIsNonatomic;
/// Returns `YES` if the property is declared dynamic.
@property (nonatomic,readonly) BOOL propertyIsDynamic;
/// Returns `YES` if the property is garbage collectable. Will always be `NO`, but here for legacy's sake.
@property (nonatomic,readonly) BOOL propertyIsGarbageCollectable;
/// The encoding of the type. This is what's produced by `&at;encode()`.
@property (nonatomic,readonly,nullable) NSString *propertyType;
/// If the type is an object, this returns the class of the object.
@property (nonatomic,readonly,nullable) Class propertyClass;
/// Returns the getter selector.
@property (nonatomic,readonly,nullable) SEL propertyGetter;
/// Returns the setter selector.
@property (nonatomic,readonly,nullable) SEL propertySetter;

@end

NS_ASSUME_NONNULL_END
