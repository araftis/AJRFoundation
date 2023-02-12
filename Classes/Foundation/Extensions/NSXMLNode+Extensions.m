/*
 NSXMLNode+Extensions.m
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
