
#import "NSUnit+Extensions.h"

#import "AJRLogging.h"
#import "AJRClassEnumerator.h"
#import "AJRMethodEnumerator.h"
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
            if ([class isSubclassOfClass:NSUnit.class] && class != NSUnit.class && class != NSDimension.class) {
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
            AJRMethodEnumerator *enumerator = [AJRMethodEnumerator methodEnumeratorWithClass:unitClass];
            Method method = nil;
            while ((method = [enumerator nextMethod])) {
                if ([enumerator isClassMethod]) {
                    NSString *name = NSStringFromSelector(method_getName(method));
                    if (![name hasPrefix:@"_"] && strcmp("@16@0:8", method_getTypeEncoding(method)) == 0 && ![name isEqualToString:@"baseUnit"]) {
                        AJRUnitConstructor constructor = (AJRUnitConstructor)method_getImplementation(method);
                        NSUnit *unit = constructor(unitClass, method_getName(method));
                        objc_setAssociatedObject(unit, @selector(identifier), name, OBJC_ASSOCIATION_RETAIN);
                        [ajr_unitClassToIndentifiers addObject:name toSetForKey:(id<NSCopying>)unitClass];
                        AJRSoftAssert(ajr_unitIdentifierToUnit[name] == nil, @"Multiple units are using the identifier: \"%@\"", name);
                        ajr_unitIdentifierToUnit[name] = unit;
                    }
                }
            }
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
        // Just return the identitiers for the given class.
        return [self ajr_unitClassToIdentifier][self];
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
