//
//  AJRPlugInProperty.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AJRPlugInAttribute.h"

#import "AJRFormat.h"

@implementation AJRPlugInAttribute

#pragma mark - NSObject

- (NSString *)description {
    return AJRFormat(@"<%C: %p: name: %@, type: %@, required: %@>", self, self, _name, _type, _required ? @"YES" : @"NO");
}

@end
