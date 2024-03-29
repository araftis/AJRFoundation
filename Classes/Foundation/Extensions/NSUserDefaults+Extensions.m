/*
 NSUserDefaults+Extensions.m
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

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSString *value = [self stringForKey:key];
    if (value) {
        return value.boolValue;
    }
    return defaultValue;
}

- (float)floatForKey:(NSString *)key defaultValue:(float)defaultValue {
    NSString *value = [self stringForKey:key];
    return value == nil ? defaultValue : value.floatValue;
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    NSString *value = [self stringForKey:key];
    return value == nil ? defaultValue : value.doubleValue;
}

@end
