//
//  NSURLQueryItem+Extensions.m
//  AJRFoundation
//
//  Created by AJ Raftis on 10/29/19.
//

#import "NSURLQueryItem+Extensions.h"

#import <AppKit/AppKit.h>

@implementation NSURLQueryItem (Extensions)

+ (NSArray<NSURLQueryItem *> *)queryItemsFromDictionary:(NSDictionary<NSString *, NSString *> *)items {
    NSMutableArray *array = [NSMutableArray array];
    
    [items enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        [array addObject:[NSURLQueryItem queryItemWithName:name value:value]];
    }];
    
    return array;
}

@end
