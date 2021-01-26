//
//  NSMutableSet+Extensions.m
//  AJRFoundation
//
//  Created by AJ Raftis on 7/16/19.
//

#import "NSMutableSet+Extensions.h"

@implementation NSMutableSet (Extensions)

- (void)addObjectIfNotNil:(nullable id)object {
    if (object != nil) {
        [self addObject:object];
    }
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-set";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSMutableSet class];
}

@end
