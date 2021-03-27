
#import "AJRPlugInExtension.h"

#import "AJRPlugInAttribute.h"
#import "AJRPlugInElement.h"

@implementation AJRPlugInExtension

+ (instancetype)extensionWithName:(NSString *)extensionName class:(Class)extensionClass properties:(NSDictionary<NSString *, id> *)properties owner:(AJRPlugInExtensionPoint *)extensionPoint {
    return [[self alloc] initWithName:extensionName class:extensionClass properties:properties owner:extensionPoint];
}

- (id)initWithName:(NSString *)extensionName class:(Class)extensionClass properties:(NSDictionary<NSString *, id> *)properties owner:(AJRPlugInExtensionPoint *)extensionPoint {
    if ((self = [super init])) {
        _name = extensionName;
        _extensionClass = extensionClass;
        _properties = [properties copy];
        _extensionPoint = extensionPoint;
    }
    return self;
}

- (id)valueForKey:(NSString *)propertyName {
    return [_extensionPoint propertyForName:propertyName] != nil ? [_properties valueForKey:propertyName] : [super valueForKey:propertyName];
}

@end
