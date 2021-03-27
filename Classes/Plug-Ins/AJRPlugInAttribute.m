
#import "AJRPlugInAttribute.h"

#import "AJRFormat.h"

@implementation AJRPlugInAttribute

#pragma mark - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %p: name: %@, type: %@, required: %@>", self, self, _name, _type, _required ? @"YES" : @"NO");
}

@end
