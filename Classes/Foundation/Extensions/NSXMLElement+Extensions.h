
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSXMLElement (Extensions)

- (void)removeChild:(NSXMLNode *)childNode;
- (void)replaceChild:(NSXMLNode *)childNode withNode:(NSXMLNode *)node;
- (void)insertChild:(NSXMLNode *)node before:(NSXMLNode *)sibling;
- (void)insertChild:(NSXMLNode *)node after:(NSXMLNode *)sibling;

- (void)addAttribute:(nullable NSString *)value forName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
