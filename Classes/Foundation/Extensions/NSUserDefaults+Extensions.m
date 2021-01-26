//
//  NSUserDefaults+Extensions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 9/15/11.
//  Copyright (c) 2011 A.J. Raftis. All rights reserved.
//

#import "NSUserDefaults+Extensions.h"

#import "AJRLogging.h"
#import "NSObject+Extensions.h"
#import "NSUnit+Extensions.h"

@implementation NSUserDefaults (Extensions)

- (Class)classForKey:(NSString *)key defaultValue:(Class)defaultValue {
    NSString *className = [self stringForKey:key];
    Class class = Nil;
    
    if (className) {
        class = NSClassFromString(className);
    }
    
    return class ?: defaultValue;
}
                              
- (void)setClass:(Class)class forKey:(NSString *)key {
    [self setObject:NSStringFromClass(class) forKey:key];
}

- (NSUnit *)unitsForKey:(NSString *)key defaultValue:(NSUnit *)defaultValue {
	NSUnit *value = defaultValue;
	NSString *raw = [self stringForKey:key];
	if (raw) {
		value = [NSUnit unitForIdentifier:raw];
	}
	return value;
}

- (void)setUnits:(NSUnit *)units forKey:(NSString *)key {
	[self setObject:[units identifier] forKey:key];
}

@end
