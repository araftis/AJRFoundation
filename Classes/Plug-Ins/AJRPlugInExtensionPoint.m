/*
AJRPlugInExtensionPoint.m
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

#import "AJRPlugInExtensionPoint.h"

#import "AJRFormat.h"
#import "AJRLogging.h"
#import "AJRPlugInElement.h"
#import "AJRPlugInExtension.h"

#import <objc/runtime.h>

typedef void (*AJRRegistryIMP)(id class, SEL _cmd);
typedef void (*AJRRegistryClassIMP)(id class, SEL _cmd, Class extension);
typedef void (*AJRRegistryPropertiesIMP)(id class, SEL _cmd, NSDictionary *properties);
typedef void (*AJRRegistryNameAndPropertiesIMP)(id class, SEL _cmd, NSString *name, NSDictionary *properties);
typedef void (*AJRRegistryClassAndPropertiesIMP)(id class, SEL _cmd, Class extension, NSDictionary *properties);

@interface AJRPlugInExtensionPoint ()

@property (nonatomic,strong) NSMapTable<Class, AJRPlugInExtension *> *extensionsByClass;
@property (nonatomic,strong) NSMutableDictionary<NSString *, AJRPlugInExtension *> *extensionsByName;
@property (nonatomic,strong) NSMutableDictionary<NSString *, AJRPlugInElement *> *elementsByKey;

@end

@implementation AJRPlugInExtensionPoint

- (instancetype)init {
    if ((self = [super init])) {
        _extensions = [[NSMutableArray alloc] init];
        _extensionsByClass = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:16];
        _extensionsByName = [NSMutableDictionary dictionary];
        _elementsByKey = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setRegistered:(BOOL)registered {
    if (_registered == NO && registered == YES) {
        _registered = YES;
        for (AJRPlugInExtension *extension in _extensions) {
            [self _registerExtension:extension];
        }
    } else if (_registered == YES && registered == NO) {
        AJRLogWarning(@"%@: A factory may not go from registered to unregistered.", _name);
    }
}

- (void)_registerExtension:(AJRPlugInExtension *)extension {
    BOOL warn = NO;
    NSDictionary *properties = [extension properties];
    Class class = [extension extensionClass];
    
    if ([self registrySelector]) {
        if (class && properties) {
            AJRRegistryClassAndPropertiesIMP implementation = (AJRRegistryClassAndPropertiesIMP)[[self extensionPointClass] methodForSelector:[self registrySelector]];
            if (implementation) {
                implementation([self extensionPointClass], [self registrySelector], class, properties);
            } else {
                warn = YES;
            }
        } else if (class && !properties) {
            AJRRegistryClassIMP implementation = (AJRRegistryClassIMP)[[self extensionPointClass] methodForSelector:[self registrySelector]];
            if (implementation) {
                implementation([self extensionPointClass], [self registrySelector], class);
            } else {
                warn = YES;
            }
        } else if (!class && properties) {
			Method method = class_getClassMethod([self extensionPointClass], [self registrySelector]);
            if (method) {
				switch (method_getNumberOfArguments(method)) {
					case 3: {
						AJRRegistryPropertiesIMP implementation = (AJRRegistryPropertiesIMP)[[self extensionPointClass] methodForSelector:[self registrySelector]];
						implementation([self extensionPointClass], [self registrySelector], properties);
						break;
					}
					case 4: {
						AJRRegistryNameAndPropertiesIMP implementation = (AJRRegistryNameAndPropertiesIMP)[[self extensionPointClass] methodForSelector:[self registrySelector]];
						implementation([self extensionPointClass], [self registrySelector], properties[@"name"], properties);
						break;
					}
					default:
						AJRLogWarning(@"Factory registry method is expected to have one or two arguments, but has %d instead.", method_getNumberOfArguments(method) - 2);
				}
            } else {
                warn = YES;
            }
        } else if (!class && !properties) {
            AJRRegistryIMP implementation = (AJRRegistryIMP)[[self extensionPointClass] methodForSelector:[self registrySelector]];
            if (implementation) {
                implementation([self extensionPointClass], [self registrySelector]);
            } else {
                warn = YES;
            }
        }
        if (warn) {
            AJRLogWarning(@"Factory %@ is registered, but does not implement it's registry selector \"%S\".", _name, _registrySelector);
        }
    }
}

- (void)addExtension:(AJRPlugInExtension *)extension {
    [(NSMutableArray *)_extensions addObject:extension];
    if ([extension class]) {
        [_extensionsByClass setObject:extension forKey:[extension extensionClass]];
    }
    if ([extension name]) {
        [_extensionsByName setObject:extension forKey:[extension name]];
    }
    
    if (_registered) {
        [self _registerExtension:extension];
    }
}

#pragma mark - Properties

- (void)setElements:(NSDictionary<NSString *,AJRPlugInElement *> *)elements {
    _elements = [elements copy];
    _elementsByKey = [NSMutableDictionary dictionary];
    [_elements enumerateKeysAndObjectsUsingBlock:^(NSString *key, AJRPlugInElement *object, BOOL *stop) {
        [self->_elementsByKey setObject:object forKey:[object key]];
    }];
}

#pragma mark - Extension values

- (id)valueForProperty:(NSString *)property onExtensionForClass:(Class)extensionClass {
    return [self valueForProperty:property onExtension:NSStringFromClass(extensionClass)];
}

- (id)valueForProperty:(NSString *)property onExtension:(NSString *)extensionNameOrClassName {
    id value = nil;
    AJRPlugInExtension *extension = [self extensionForName:extensionNameOrClassName];
    if (extension) {
        value = [extension valueForKey:property];
    } else {
        AJRLogWarning(@"valueForProperty:onExtension: for extension \"%@\" called on non-existant property \"%@\".", extensionNameOrClassName, property);
    }
    return value;
}

#pragma mark - Extensions

- (AJRPlugInExtension *)extensionForClass:(Class)class {
    return [_extensionsByClass objectForKey:class];
}

- (AJRPlugInExtension *)extensionForClassName:(NSString *)className {
    return [self extensionForClass:NSClassFromString(className)];
}
            
- (AJRPlugInExtension *)extensionForName:(NSString *)name {
    return [_extensionsByName objectForKey:name] ?: [self extensionForClassName:name];
}

#pragma mark - AJRPlugInSchemaObject

- (id)propertyForName:(NSString *)name {
    return (id)[_attributes objectForKey:name] ?: (id)[_elementsByKey objectForKey:name];
}

- (AJRPlugInAttribute *)attributeForName:(NSString *)attributeName {
    return [_attributes objectForKey:attributeName];
}

- (AJRPlugInElement *)elementForName:(NSString *)elementName {
    return [_elements objectForKey:elementName];
}

#pragma mark - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %p: %@: %ld extension%@ registered>", self, self, _name, (long)[_extensions count], [_extensions count] == 1 ? @"" : @"s");
}

@end
