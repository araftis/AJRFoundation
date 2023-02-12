/*
 AJRPlugInExtensionPoint.h
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

@class AJRPlugInExtension, AJRPlugInAttribute, AJRPlugInElement, AJRPlugInElement;

@protocol AJRPlugInSchemaObject <NSObject>

@property (nonatomic,readonly) NSString *name;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInAttribute *> *attributes;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInElement *> *elements;

- (AJRPlugInAttribute *)attributeForName:(NSString *)attributeName;
- (AJRPlugInElement *)elementForName:(NSString *)elementName;

@end

@interface AJRPlugInExtensionPoint : NSObject <AJRPlugInSchemaObject>

@property (nonatomic,assign) BOOL registered;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) Class extensionPointClass;
@property (nonatomic,assign) SEL registrySelector;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInAttribute *> *attributes;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInElement *> *elements;
@property (nonatomic,strong) NSArray<AJRPlugInExtension *> *extensions;

- (void)addExtension:(AJRPlugInExtension *)extension;

- (nullable id)valueForProperty:(NSString *)property onExtensionForClass:(Class)extensionClass;
- (nullable id)valueForProperty:(NSString *)property onExtension:(NSString *)extensionNameOrClassName;

- (nullable AJRPlugInExtension *)extensionForClass:(Class)class;
- (nullable AJRPlugInExtension *)extensionForClassName:(NSString *)className;
- (nullable AJRPlugInExtension *)extensionForName:(NSString *)name;

/*! Returns an AJRPlugInAttribute or AJRPlugInElement. Maybe these should be merged? */
- (id)propertyForName:(NSString *)name;
- (AJRPlugInAttribute *)attributeForName:(NSString *)attributeName;
- (AJRPlugInElement *)elementForName:(NSString *)elementName;

@end

NS_ASSUME_NONNULL_END
