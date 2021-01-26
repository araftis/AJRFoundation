//
//  NSXMLNode+Extensions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 4/10/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import "NSXMLNode+Extensions.h"

#import "AJRFunctions.h"

@implementation NSXMLNode (Extensions)

- (NSXMLNode *)findNodeWithName:(NSString *)name {
    return [self findNodeWithName:name andValue:nil forAttribute:nil];
}

- (NSXMLNode *)findNodeWithName:(NSString *)name andValue:(NSString *)value forAttribute:(NSString *)attributeName {
    __block NSXMLNode *found = nil;
    
    [self enumerateDescendantsUsingBlock:^(NSXMLNode *node, BOOL *done) {
        if ([node isKindOfClass:[NSXMLElement class]] &&
            [[node name] caseInsensitiveCompare:name] == NSOrderedSame) {
            NSXMLNode *attribute = attributeName ? [(NSXMLElement *)node attributeForName:[attributeName lowercaseString]] : nil;
            //AJRPrintf(@"%@: %@, %@\n", attributeName, [attribute stringValue], value);
            if (attributeName == nil || (attribute && [[attribute stringValue] compare:value] == NSOrderedSame)) {
                found = node;
                *done = YES;
            }
        }
    }];
    
    return found;
}

- (void)enumerateChildrenUsingBlock:(void (^)(NSXMLNode *node, BOOL *stop))enumerator {
    [[self children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        enumerator(obj, stop);
    }];
}

- (void)enumerateDescendantsUsingBlock:(void (^)(NSXMLNode *node, BOOL *stop))block {
    __block BOOL    done = NO;
    
    NSAssert(block != nil, @"You must provide an enumeration block");
    
    block(self, &done);
    if (!done) {
        for (NSXMLNode *node in [self children]) {
            [node enumerateDescendantsUsingBlock:^(NSXMLNode *node, BOOL *stop) {
                block(node, &done);
                *stop = done;
            }];
            if (done) break;
        }
    }
}

- (NSXMLNode *)nextSibling {
    NSArray *children = [[self parent] children];
    NSInteger index = [children indexOfObjectIdenticalTo:self];
    NSXMLElement *sibling = nil;
    
    if (index != NSNotFound && index + 1 < [children count]) {
        sibling = [children objectAtIndex:index + 1];
    }
    
    return sibling;
}

@end
