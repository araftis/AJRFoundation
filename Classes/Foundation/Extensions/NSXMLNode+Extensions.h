
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSXMLNode (Extensions)

- (NSXMLNode *)findNodeWithName:(NSString *)name;
- (NSXMLNode *)findNodeWithName:(NSString *)name andValue:(nullable NSString *)value forAttribute:(nullable NSString *)attribute;

- (void)enumerateChildrenUsingBlock:(void (^)(NSXMLNode *node, BOOL *stop))enumerator;
- (void)enumerateDescendantsUsingBlock:(void (^)(NSXMLNode *node, BOOL *done))block NS_SWIFT_NAME(ajr_enumerateDescendantsUsingBlock(using:));

- (NSXMLNode *)nextSibling;

@end

NS_ASSUME_NONNULL_END
