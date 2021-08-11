/*
AJRPlugInManager.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "AJRPlugInManager.h"

#import "AJRFormat.h"
#import "AJRLogging.h"
#import "AJRPlugInAttribute.h"
#import "AJRPlugInElement.h"
#import "AJRPlugInExtension.h"
#import "AJRPlugInExtensionPoint.h"
#import "NSMutableDictionary+Extensions.h"
#import "NSObject+AJRUserInfo.h"
#import <AJRFoundation/AJRFoundation-Swift.h>

#import <objc/runtime.h>

NSString * const AJRPlugInManagerLoggingDomain = @"AJRPlugInManager";
NSString * const AJRPlugInManagerErrorDomain = @"AJRPlugInManager";

static NSMutableDictionary<NSString *, AJRPlugInValueTransformer> *AJRGetValueTransformers(void) {
    static NSMutableDictionary<NSString *, AJRPlugInValueTransformer> *transformers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transformers = [NSMutableDictionary dictionary];
    });
    return transformers;
}

void AJRRegisterPluinTransformer(NSString *type, AJRPlugInValueTransformer transformer) {
    AJRGetValueTransformers()[type] = transformer;
}

static id AJRValueForString(NSString *raw, NSString *type, NSBundle *bundle, NSError **error) {
    id value = nil;
    NSError *localError = nil;
    
    if (raw == nil) {
        value = nil;
    } else if ([type isEqualToString:@"string"]) {
        value = raw;
    } else if ([type isEqualToString:@"boolean"]) {
        value = [NSNumber numberWithBool:[raw boolValue]];
    } else if ([type isEqualToString:@"integer"]) {
        value = [NSNumber numberWithLongLong:[raw longLongValue]];
    } else if ([type isEqualToString:@"float"]) {
        value = [NSNumber numberWithDouble:[raw doubleValue]];
    } else if ([type isEqualToString:@"bundle"]) {
        if ([raw isEqualToString:@"$xml-bundle"]) {
            value = bundle;
        } else if ([raw isEqualToString:@"$main-bundle"]) {
            value = [NSBundle mainBundle];
        } else {
            value = [NSBundle bundleWithIdentifier:raw];
        }
    } else if ([type isEqualToString:@"class"]) {
        value = NSClassFromString(raw);
        if (value == Nil) {
            AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Unable to find class: \"%@\"", raw);
        }
    } else if ([type isEqualToString:@"url"]) {
        value = [NSURL URLWithString:raw];
        if (value == nil) {
            AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Unable to create URL from: \"%@\"", raw);
        }
    } else if (AJRGetValueTransformers()[type] != nil) {
        value = AJRGetValueTransformers()[type](raw, bundle, &localError);
    } else {
        AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Asked to produce a value for an unknown type: %@, returning \"%@\" as string.\n", type, raw);
        value = raw;
    }
    
    return AJRAssertOrPropagateError(value, error, localError);
}

@interface AJRPlugInManager ()

@property (nonatomic,strong) NSMutableDictionary<NSString *, AJRPlugInExtensionPoint *> *extensionPoints;
@property (nonatomic,strong) NSMapTable<Class, AJRPlugInExtensionPoint *> *extensionPointsByClass;
@property (nonatomic,strong) NSMutableSet<NSURL *> *scannedBundleURLs;
@property (nonatomic,strong) NSMutableOrderedSet<NSXMLElement *> *extensionsToReprocess;

@end

@implementation AJRPlugInManager

static BOOL isInitializing = NO;

+ (void)initializePlugInManager {
    if (!isInitializing) {
        [self sharedPlugInManager];
    }
}

+ (id)sharedPlugInManager {
    static AJRPlugInManager  *sharedPlugInManager = nil;
    static dispatch_once_t  onceToken;
    
    AJRAssert(!isInitializing, @"+[AJRPlugInManager sharedInstance] cannot be safely called while the plug-in manager is initializing.");
    
    dispatch_once(&onceToken, ^{
        isInitializing = YES;
        sharedPlugInManager = [[AJRPlugInManager alloc] init];
        isInitializing = NO;
    });
    return sharedPlugInManager;
}

- (instancetype)init {
    if ((self = [super init])) {
        _extensionPoints = [[NSMutableDictionary alloc] init];
        _extensionPointsByClass = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
        _scannedBundleURLs = [NSMutableSet set];
        _extensionsToReprocess = [NSMutableOrderedSet orderedSet];
        
        [self _scanBundles];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleDidLoad:) name:NSBundleDidLoadNotification object:nil];
    }
    return self;
}

- (void)registerExtensionPoint:(NSString *)extensionPointClassName
                      withName:(NSString *)name
        registrySelectorString:(NSString *)registrySelectorString
                    attributes:(NSDictionary<NSString *, AJRPlugInAttribute *> *)attributes
                      elements:(NSDictionary<NSString *, AJRPlugInElement *> *)elements {
    AJRPlugInExtensionPoint *extensionPoint = [_extensionPoints objectForKey:name];
    
    if (extensionPoint && [extensionPoint registered]) {
        AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"There's already an extension-point named \"%@\" registered with the plug-in manager.", name);
    } else {
        if (!extensionPoint) {
            extensionPoint = [[AJRPlugInExtensionPoint alloc] init];
        }
        if (extensionPointClassName) {
            extensionPoint.extensionPointClass = NSClassFromString(extensionPointClassName);
            if (extensionPoint.extensionPointClass == Nil) {
                AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Couldn't find class named \"%@\" for extension-point \"%@\".", extensionPointClassName, name);
            }
        }
        extensionPoint.name = name;
        extensionPoint.registrySelector = NSSelectorFromString(registrySelectorString);
        extensionPoint.attributes = attributes;
        extensionPoint.elements = elements;
        extensionPoint.registered = YES;
        
        [_extensionPoints setObject:extensionPoint forKey:name];
        if ([extensionPoint extensionPointClass]) {
            [_extensionPointsByClass setObject:extensionPoint forKey:[extensionPoint extensionPointClass]];
        }
    }
}

- (AJRPlugInAttribute *)_attributeFromNode:(NSXMLElement *)child XMLIdentifier:(NSString *)XMLIdentifier sourceBundle:(NSBundle *)bundle failures:(NSMutableArray<NSString *> *)fails {
    AJRPlugInAttribute *attribute = nil;
    NSString *attributeName = [[child attributeForName:@"name"] stringValue];
    NSString *attributeType = [[child attributeForName:@"type"] stringValue];
    NSString *attributeDefaultValue = [[child attributeForName:@"defaultValue"] stringValue];
    BOOL attributeDefaultValueIsLazy = [child attributeForName:@"defaultValueIsLazy"].stringValue.boolValue;
    BOOL propertyRequired = [[[child attributeForName:@"required"] stringValue] boolValue];
    
    if (attributeName == nil) {
        [fails addObject:AJRFormat(@"Missing \"name\" for attribute in extension-point \"%@\"", XMLIdentifier)];
    }
    if (attributeType == nil) {
        [fails addObject:AJRFormat(@"Missing \"type\" for attribute in extension-point \"%@\"", XMLIdentifier)];
    }
    // NOTE: The extra compares against nil are to shut up the analyzer. It's usually pretty good, but in this case, if attributeName or attributeType are nil, we'll have generated a failure, which means fails.count would not be equal to 0.
    if ([fails count] == 0 && attributeName != nil && attributeType != nil) {
        NSError *localError = nil;
        attribute = [[AJRPlugInAttribute alloc] init];
        attribute.name = attributeName;
        attribute.type = attributeType;
        if (attributeDefaultValue) {
            if (attributeDefaultValueIsLazy) {
                attribute.rawDefaultValue = attributeDefaultValue;
            } else {
                attribute.defaultValue = AJRValueForString(attributeDefaultValue, attribute.type, bundle, &localError);
                if (attribute.defaultValue == nil) {
                    [fails addObject:[localError localizedDescription]];
                }
            }
        }
        attribute.required = propertyRequired;
    }
    
    return attribute;
}

- (AJRPlugInElement *)_elementFromNode:(NSXMLElement *)child
                          sourceBundle:(NSBundle *)bundle
                              failures:(NSMutableArray<NSString *> *)fails {
    AJRPlugInElement *element = nil;
    NSString *name = [[child attributeForName:@"name"] stringValue];
    NSString *key = [[child attributeForName:@"key"] stringValue];
    NSString *type = [[child attributeForName:@"type"] stringValue];
    NSMutableDictionary<NSString *, AJRPlugInAttribute *> *attributes = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, AJRPlugInElement *> *elements = [NSMutableDictionary dictionary];
    BOOL required = [[[child attributeForName:@"required"] stringValue] boolValue];
    
    if (name == nil) {
        [fails addObject:AJRFormat(@"No \"name\" attribute specified for node: %@", child)];
    }
    if (type == nil) {
        type = @"string";
    }
    if (([type isEqualToString:@"array"] || [type isEqualToString:@"set"]) && key == nil) {
        [fails addObject:AJRFormat(@"Elements of type \"array\" should also define the \"plural\" key: %@", child)];
    }
    if ([fails count] == 0 && name != nil) {
        [self _populateAttributes:attributes andElements:elements fromNode:child named:name sourceBundle:bundle failures:fails];

        element = [[AJRPlugInElement alloc] init];
        element.name = name;
        element.type = type;
        element.key = key;
        element.required = required;
        element.attributes = attributes;
        element.elements = elements;
    }
    
    return [fails count] == 0 ? element : nil;
}

- (void)_populateAttributes:(NSMutableDictionary<NSString *, AJRPlugInAttribute *> *)attributes
                andElements:(NSMutableDictionary<NSString *, AJRPlugInElement *> *)elements
                   fromNode:(NSXMLElement *)node named:(NSString *)name
               sourceBundle:(NSBundle *)bundle
                   failures:(NSMutableArray<NSString *> *)fails {
    for (NSXMLElement *child in [node children]) {
        NSString *childName = [child name];
        
        if ([childName isEqualToString:@"attribute"]) {
            AJRPlugInAttribute *attribute = [self _attributeFromNode:child XMLIdentifier:name sourceBundle:bundle failures:fails];
            if ([fails count] == 0) {
                [attributes setObject:attribute forKey:[attribute name]];
            } else {
                [fails addObject:AJRFormat(@"Unable to create attribute on extension-point \"%@\": %@", name, child)];
            }
        } else if ([childName isEqualToString:@"element"]) {
            AJRPlugInElement *element = [self _elementFromNode:child sourceBundle:bundle failures:fails];
            if ([fails count] == 0) {
                [elements setObject:element forKey:[element name]];
            } else {
                [fails addObject:AJRFormat(@"Unable to create element on extension-point \"%@\": %@", name, child)];
            }
        } else if (child.kind == NSXMLCommentKind) {
            // Ignore comments
        } else {
            [fails addObject:AJRFormat(@"Unknown child in extension-point definition: %@: %@", name, childName)];
        }
    }
}

- (void)_registerExtensionPointFromNode:(NSXMLElement *)node sourceBundle:(NSBundle *)bundle {
    NSString *name = [[node attributeForName:@"name"] stringValue];
    NSString *className = [[node attributeForName:@"class"] stringValue];
    NSMutableDictionary<NSString *, AJRPlugInAttribute *> *attributes = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, AJRPlugInElement *> *elements = [NSMutableDictionary dictionary];
    NSString *selectorName = [[node attributeForName:@"registrySelector"] stringValue];
    NSMutableArray *fails = [NSMutableArray array];
    
    if (name == nil) {
        [fails addObject:AJRFormat(@"No name property defined for extension-point in node: %@", node)];
    }
    if ([fails count] == 0 && selectorName != nil && className == nil) {
        [fails addObject:AJRFormat(@"Extension Point \"%@\" has a registrySelector @selector(%@), but no class defined.", name, selectorName)];
    }
    
    if ([fails count] == 0) {
        [self _populateAttributes:attributes andElements:elements fromNode:node named:name sourceBundle:bundle failures:fails];
        if ([fails count] == 0 && name != nil && className != nil) {
            [self registerExtensionPoint:className withName:name registrySelectorString:selectorName attributes:attributes elements:elements];
        }
    }
    
    if ([fails count]) {
        for (NSString *fail in fails) {
            AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"%@", fail);
        }
    }
}

- (NSDictionary<NSString *, id> *)_dictionaryFromNode:(NSXMLElement *)node
                                               schema:(id <AJRPlugInSchemaObject>)schema
                                     skipNameAndClass:(BOOL)skipNameAndClass
                                         sourceBundle:(NSBundle *)bundle {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    for (NSXMLNode *attribute in [node attributes]) {
        NSString *name = [attribute name];
        NSString *value = [attribute stringValue];
        
        // Skip, unless the schema excplicitly declares these values.
        if (skipNameAndClass && [name isEqualToString:@"class"] && ![schema attributeForName:@"class"]) {
            // Skip
        } else if (skipNameAndClass && [name isEqualToString:@"name"] && ![schema attributeForName:@"name"]) {
            // Skip
        } else {
            AJRPlugInAttribute *attribute = [schema attributeForName:name];
            if (attribute) {
                NSError *localError = nil;
                id convertedValue = AJRValueForString(value, [attribute type], bundle, &localError);
                if (convertedValue) {
                    [properties setObject:convertedValue forKey:name];
                } else {
                    AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Failed to convert value \"%@\" to \"%@\".", value, attribute.type);
                }
            } else {
                AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Unknown attribute \"%@\" on: %@", name, node);
            }
        }
    }
    // Verify we have all required attributes
    for (AJRPlugInAttribute *attribute in [[schema attributes] objectEnumerator]) {
        if ([attribute required] && [properties objectForKey:[attribute name]] == nil) {
            id possibleDefault;
            if (attribute.rawDefaultValue) {
                NSError *localError = nil;
                possibleDefault = AJRValueForString(attribute.rawDefaultValue, attribute.type, bundle, &localError);
                if (possibleDefault == nil) {
                    AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Failed to create attribute of type \"%@\" from rawValue \"%@\".", attribute.type, attribute.rawDefaultValue);
                }
            } else {
                possibleDefault = [attribute defaultValue];
            }
            if (possibleDefault) {
                [properties setObject:possibleDefault forKey:[attribute name]];
            } else {
                AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Missing required attribute \"%@\" in: %@", [attribute name], node);
            }
        }
    }
    
    for (NSXMLElement *child in [node children]) {
        NSString *name = [child name];
        AJRPlugInElement *element = [schema elementForName:name];
        
        if (element) {
            NSString *type = [element type];
            NSDictionary<NSString *, id> *subproperties = [self _dictionaryFromNode:child schema:element skipNameAndClass:NO sourceBundle:bundle];
            if ([type isEqualToString:@"array"]) {
                [properties addObject:subproperties toArrayForKey:[element key]];
            } else if ([type isEqualToString:@"set"]) {
                [properties addObject:subproperties toSetForKey:[element key]];
            } else {
                [properties setObject:subproperties forKey:[element key]];
            }
        } else {
            AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Unknown element \"%@\" on: %@", name, node);
        }
    }
    // Verify we have all required elements
    for (AJRPlugInElement *element in [[schema elements] objectEnumerator]) {
        if ([element required] && [properties objectForKey:[element key]] == nil) {
            AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Missing required element \"%@\" in: %@", [element name], node);
        }
    }
    
    return properties;
}

- (AJRPlugInExtension *)_extensionFromNode:(NSXMLElement *)node
                         forExtensionPoint:(AJRPlugInExtensionPoint *)extensionPoint
                              sourceBundle:(NSBundle *)bundle {
    NSDictionary<NSString *, id> *properties;
    Class extensionClass = Nil;
    NSString *extensionName = nil;
    NSString *value;
    
    value = [[node attributeForName:@"class"] stringValue];
    extensionClass = value ? NSClassFromString(value) : Nil;
    if (extensionClass == nil) {
        // If there's no class defined by the extension, let's see if there's a default value defined by the extenion point.
        extensionClass = [[extensionPoint attributeForName:@"class"] defaultValue];
    }
    if (value && extensionClass == Nil) {
        AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"Unable to find class \"%@\" specified by extension: %@", value, node);
    }

    extensionName = [[node attributeForName:@"name"] stringValue];
    if (extensionName == nil && extensionClass == nil) {
        AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelWarning, @"All extensions must define a name or a class, this node didn't: %@", node);
    }

    properties = [self _dictionaryFromNode:node schema:extensionPoint skipNameAndClass:YES sourceBundle:bundle];
    
    return (extensionName || extensionClass) ? [AJRPlugInExtension extensionWithName:extensionName class:extensionClass properties:properties owner:extensionPoint] : nil;
}

- (void)_processExtensionNode:(NSXMLElement *)element sourceBundle:(NSBundle *)bundle {
    NSString *name = [element name];
    
    if ([name isEqualToString:@"extension-point"]) {
        [self _registerExtensionPointFromNode:element sourceBundle:bundle];
    } else {
        AJRPlugInExtensionPoint *extensionPoint = [_extensionPoints objectForKey:name];
        
        if (extensionPoint == nil) {
            [element setInstanceObject:bundle forKey:@"bundle"];
            [_extensionsToReprocess addObject:element];
        } else {
            AJRPlugInExtension *extension = [self _extensionFromNode:element forExtensionPoint:extensionPoint sourceBundle:bundle];
            if (extension) {
                [extensionPoint addExtension:extension];
            }
            [_extensionsToReprocess removeObject:element];
        }
    }
}

- (void)_scanNodes:(NSArray *)nodes sourceBundle:(NSBundle *)bundle {
    for (NSXMLNode *node in nodes) {
        for (NSXMLElement *element in [node children]) {
            if ([element kind] == NSXMLElementKind) {
                [self _processExtensionNode:element sourceBundle:bundle];
            }
        }
    }
}

- (void)_scanBundles:(NSArray *)bundles {
    for (NSBundle *bundle in bundles) {
        //AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelDebug@"%@: %@", bundle, [bundle URLsForResourcesWithExtension:@"ajrplugindata" subdirectory:@""]);
        for (NSURL *url in [bundle URLsForResourcesWithExtension:@"ajrplugindata" subdirectory:@""]) {
            if (![_scannedBundleURLs containsObject:url]) {
                NSError *error = nil;
                NSXMLDocument *document;
                
                AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelDebug, @"Adding plugins: %@", [url lastPathComponent]);

                // Do this early, because scanning an unloaded bundle can cause it to load, which means we'd rescan, and we want to avoid scanning twice.
                [_scannedBundleURLs addObject:url];
                
                document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
                if (document) {
                    [self _scanNodes:[document nodesForXPath:@"plugindata" error:NULL] sourceBundle:bundle];
                } else {
                    AJRLog(AJRPlugInManagerLoggingDomain, AJRLogLevelError, @"Unable to load plug-in data: %@: %@", url, [error localizedDescription]);
                }
            }
        }
    }
}

- (void)_processLateExtensionPoints {
    while ([_extensionsToReprocess count] > 0) {
        NSOrderedSet *extensionToReprocess = [_extensionsToReprocess copy];
        
        for (NSXMLElement *element in extensionToReprocess) {
            [self _processExtensionNode:element sourceBundle:[element instanceObjectForKey:@"bundle"]];
        }
        
        if ([_extensionsToReprocess count] == [extensionToReprocess count]) {
            // Nothing reprocessed, so break out of our loop. Note we may still have extensions that haven't been defined, but we can't warn about those, because we may yet load a bundle that defines the associated extension point. This, really, is less than ideal, but it's either do this, or have sometimes spurious warnings.
            break;
        }
    }
}

- (void)_scanBundles {
    // Scan frameworks first, because they're what define the the extension points.
    [self _scanBundles:[NSBundle allFrameworks]];
    [self _scanBundles:[NSBundle allBundles]];
    
    [self _processLateExtensionPoints];
}

- (void)bundleDidLoad:(NSNotification *)notification {
    [self _scanBundles:@[[notification object]]];
    [self _processLateExtensionPoints];
}

- (AJRPlugInExtensionPoint *)extensionPointForClass:(Class)class {
    return [_extensionPointsByClass objectForKey:class];
}

- (AJRPlugInExtensionPoint *)extensionPointForName:(NSString *)name {
    return [_extensionPoints objectForKey:name];
}

@end
