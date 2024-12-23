/*
 AJRPlugInManager.h
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

#import <AJRFoundation/AJRLogging.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPlugInAttribute, AJRPlugInElement, AJRPlugInExtensionPoint, AJRPlugInExtension;

extern const AJRLoggingDomain AJRLoggingDomainPlugInManager;
extern NSString * const AJRPlugInManagerErrorDomain;

typedef id _Nullable (^AJRPlugInValueTransformer)(NSString *rawValue, NSBundle * _Nullable bundle, NSError * _Nullable * _Nullable error);

extern void AJRRegisterPluinTransformer(NSString *type, AJRPlugInValueTransformer transformer);

@interface AJRPlugInManager : NSObject

/*! Does the initial setup of the plugin manager. */
+ (void)initializePlugInManager;

@property (nonatomic,class,readonly) AJRPlugInManager *sharedPlugInManager NS_SWIFT_NAME(shared);

- (void)registerExtensionPoint:(NSString *)factoryClassName
                      withName:(NSString *)name
        registrySelectorString:(nullable NSString *)registrySelectorString
                    attributes:(NSDictionary<NSString *, AJRPlugInAttribute *> *)attributes
                      elements:(NSDictionary<NSString *, AJRPlugInElement *> *)elements;

- (nullable AJRPlugInExtensionPoint *)extensionPointForClass:(Class)aClass;
- (nullable AJRPlugInExtensionPoint *)extensionPointForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
