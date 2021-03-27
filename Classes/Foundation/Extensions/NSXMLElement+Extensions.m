
#import "NSXMLElement+Extensions.h"

@implementation NSXMLElement (Extensions)

- (void)removeChild:(NSXMLNode *)childNode {
	NSArray *children = self.children;
	NSInteger index = children ? [children indexOfObjectIdenticalTo:childNode] : NSNotFound;

    if (index != NSNotFound) {
        [self removeChildAtIndex:index];
    }
}

- (void)replaceChild:(NSXMLNode *)childNode withNode:(NSXMLNode *)node {
	NSArray *children = self.children;
	NSInteger index = children ? [children indexOfObjectIdenticalTo:childNode] : NSNotFound;

    if (index != NSNotFound) {
        [self replaceChildAtIndex:index withNode:node];
    }
}

- (void)insertChild:(NSXMLNode *)node before:(NSXMLNode *)sibling {
	NSArray *children = self.children;
	NSInteger index = children ? [children indexOfObjectIdenticalTo:sibling] : NSNotFound;

    if (index != NSNotFound) {
        [self insertChild:node atIndex:index];
    } else {
		[self insertChild:node atIndex:0];
    }
}

- (void)insertChild:(NSXMLNode *)node after:(NSXMLNode *)sibling {
	NSArray *children = self.children;
	NSInteger index = children ? [children indexOfObjectIdenticalTo:sibling] : NSNotFound;
    
    if (index != NSNotFound) {
        [self insertChild:node atIndex:index + 1];
    } else {
        [self addChild:node];
    }
}

- (void)addAttribute:(NSString *)value forName:(NSString *)name {
	if (value == nil) {
		[self removeAttributeForName:name];
	} else {
		[self addAttribute:[NSXMLNode attributeWithName:name stringValue:value]];
	}
}

@end
