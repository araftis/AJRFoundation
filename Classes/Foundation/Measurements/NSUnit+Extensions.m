/*
 NSUnit+Extensions.m
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

#import "NSUnit+Extensions.h"

#import "AJRLogging.h"
#import "AJRClassEnumerator.h"
#import "AJRFunctions.h"
#import "AJRMethodEnumerator.h"
#import "AJRPropertyEnumerator.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "NSMutableDictionary+Extensions.h"

@implementation NSUnit (Extensions)

typedef NSUnit * (*AJRUnitConstructor)(id sender, SEL _cmd);

+ (NSSet<Class> *)unitClasses {
    static dispatch_once_t onceToken;
    static NSMutableSet<Class> *unitClasses = nil;
    dispatch_once(&onceToken, ^{
        unitClasses = [NSMutableSet set];
        for (Class class in [AJRClassEnumerator classEnumerator]) {
            // IMPORTANT NOTE: Using AJRClassIsKindOfClass avoids tripping +initialize on objects, which can cause strange behavior if this code is triggerred during early start up.
            if (AJRClassIsKindOfClass(class, NSUnit.class)
                && class != NSUnit.class
                && class != NSDimension.class
                && strncmp(class_getName(class), "MX", 2) != 0
                && strncmp(class_getName(class), "_NSStatic_", 10) != 0) {
                [unitClasses addObject:class];
            }
        }
    });
    return unitClasses;
}

static NSMutableDictionary<Class, NSSet<NSString *> *> *ajr_unitClassToIndentifiers;
static NSMutableDictionary<NSString *, NSUnit *> *ajr_unitIdentifierToUnit;

+ (void)ajr_faultIndexes {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ajr_unitClassToIndentifiers = [NSMutableDictionary dictionary];
        ajr_unitIdentifierToUnit = [NSMutableDictionary dictionary];
        for (Class unitClass in self.unitClasses) {
            AJRPropertyEnumerator *enumerator = [AJRPropertyEnumerator propertyEnumeratorWithClass:unitClass];
            objc_property_t property;
            Class baseClass = objc_getClass("NSUnit");
            while ((property = [enumerator nextProperty])) {
                //AJRPrintf(@"%C: %s %s, class=%@\n", unitClass, property_getName(property), property_getAttributes(property), enumerator.propertyClass);
                Class possible = enumerator.propertyClass;
                if (![enumerator.propertyName isEqualToString:@"baseUnit"]
                    && enumerator.propertyIsClassProperty
                    && AJRClassIsKindOfClass(possible, baseClass)) {
                    Method method = class_getClassMethod(possible, enumerator.propertyGetter);
                    if (method != NULL) {
                        AJRUnitConstructor constructor = (AJRUnitConstructor)method_getImplementation(method);
                        if (constructor != NULL) {
                            NSUnit *unit = constructor(unitClass, enumerator.propertyGetter);
                            if (unit != nil) {
                                objc_setAssociatedObject(unit, @selector(identifier), enumerator.propertyName, OBJC_ASSOCIATION_RETAIN);
                                [ajr_unitClassToIndentifiers addObject:enumerator.propertyName toSetForKey:(id<NSCopying>)unitClass];
                                if (ajr_unitIdentifierToUnit[enumerator.propertyName] == nil) {
                                    ajr_unitIdentifierToUnit[enumerator.propertyName] = unit;
                                }
                            }
                        }
                    }
                }
            }
//            AJRMethodEnumerator *enumerator = [AJRMethodEnumerator methodEnumeratorWithClass:unitClass];
//            Method method = nil;
//            while ((method = [enumerator nextMethod])) {
//                if ([enumerator isClassMethod]) {
//                    NSString *name = NSStringFromSelector(method_getName(method));
//                    if (![name hasPrefix:@"_"] && strcmp("@16@0:8", method_getTypeEncoding(method)) == 0 && ![name isEqualToString:@"baseUnit"]) {
//                        AJRUnitConstructor constructor = (AJRUnitConstructor)method_getImplementation(method);
//                        NSUnit *unit = AJRObjectIfKindOfClass(constructor(unitClass, method_getName(method)), NSUnit);
//                        // Because apparently, sometimes the contructors don't return an NSUnit.
//                        if (unit != nil) {
//                            objc_setAssociatedObject(unit, @selector(identifier), name, OBJC_ASSOCIATION_RETAIN);
//                            [ajr_unitClassToIndentifiers addObject:name toSetForKey:(id<NSCopying>)unitClass];
//                            if (ajr_unitIdentifierToUnit[name] == nil) {
//                                ajr_unitIdentifierToUnit[name] = unit;
//                            }
//                        }
//                    }
//                }
//            }
        }
    });
}

+ (NSDictionary<Class, NSSet<NSString *> *> *)ajr_unitClassToIdentifier {
    [self.class ajr_faultIndexes];
    return ajr_unitClassToIndentifiers;
}

+ (NSDictionary<NSString *, NSUnit *> *)ajr_unitIdentifierToUnit {
    [self.class ajr_faultIndexes];
    return ajr_unitIdentifierToUnit;
}

+ (NSUnit *)unitForIdentifier:(NSString *)unitIdentifier {
    return [[self ajr_unitIdentifierToUnit] objectForKey:unitIdentifier];
}

+ (NSSet<NSString *> *)unitIdentifiers {
    if (self.class == [NSUnit class]) {
        // Return everything.
        return [[[self ajr_unitIdentifierToUnit] allKeys] ajr_uniqueObjects];
    } else {
        Class toTry = self;
        NSString *name = NSStringFromClass(toTry);
        // Just return the identitiers for the given class.
        if ([name hasPrefix:@"_NSStatic_"]) {
            toTry = NSClassFromString([name substringFromIndex:10]);
        }
        return [self ajr_unitClassToIdentifier][toTry];
    }
}

- (NSString *)identifier {
    [self.class ajr_faultIndexes];
    return objc_getAssociatedObject(self, @selector(identifier));
}

- (NSString *)localizedName {
    NSString *identifier = self.identifier;
    if ([identifier isEqualToString:@"points"]) {
        // We should localize this!
        return @"Points";
    }
    if ([identifier isEqualToString:@"picas"]) {
        // We should localize this!
        return @"Picas";
    }
    
    NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
    [formatter setUnitOptions:NSMeasurementFormatterUnitOptionsProvidedUnit];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setUnitStyle:NSFormattingUnitStyleLong];
    
    return [[formatter stringFromUnit:self] capitalizedName];
}

@end

@implementation NSUnitLength (Extensions)

// TODO: This should default to the user's locale.
+ (NSUnitLength *)defaultShortUnitForLocale {
    return NSUnitLength.inches;
}

// TODO: This should default to the user's locale.
+ (NSUnitLength *)defaultUnitForLocale {
    return NSUnitLength.feet;
}

// TODO: This should default to the user's locale.
+ (NSUnitLength *)defaultLongUnitForLocale {
    return NSUnitLength.miles;
}

+ (NSUnitLength *)points {
    static NSUnitLength *points = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        points = [[NSUnitLength alloc] initWithSymbol:@"pt" converter:[[NSUnitConverterLinear alloc] initWithCoefficient:1.0 / 2834.645669291340]];
    });
    return points;
}

+ (NSUnitLength *)picas {
    static NSUnitLength *picas = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        picas = [[NSUnitLength alloc] initWithSymbol:@"pc" converter:[[NSUnitConverterLinear alloc] initWithCoefficient:1.0 / 236.220472440945]];
    });
    return picas;
}

@end
