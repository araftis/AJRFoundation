//
//  NSXMLElement+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 12/19/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

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
