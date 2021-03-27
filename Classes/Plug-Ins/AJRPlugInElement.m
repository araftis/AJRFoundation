
#import "AJRPlugInElement.h"

#import "AJRFormat.h"

@implementation AJRPlugInElement

#pragma mark - Properties

- (NSString *)key {
    return _key ?: self.name;
}

#pragma mark - AJRPlugInSchemaObject

- (AJRPlugInAttribute *)attributeForName:(NSString *)attributeName {
    return _attributes[attributeName];
}

- (AJRPlugInElement *)elementForName:(NSString *)elementName {
    return _elements[elementName];
}

#pragma mark - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %p: name: %@, type: %@, required: %@>", self, self, _name, _type, _required ? @"YES" : @"NO");
}

@end
