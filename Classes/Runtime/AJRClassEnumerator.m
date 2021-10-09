/*
AJRClassEnumerator.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "AJRClassEnumerator.h"

#import <objc/runtime.h>

/* **************************************************************************************
 THIS IS MRR! You must manually retain/release.

 This is necessary, because we want to avoid sending +initialize to bunches of classes that
 don't need to be initializing.
 */

@implementation AJRClassEnumerator {
    Class *_list;
    
    unsigned int _count;
    unsigned int _subindex;
    BOOL _enumeratingClassMethods:1;
}

+ (instancetype)classEnumerator {
    return [[[self alloc] init] autorelease];
}

- (instancetype)init {
    if ((self = [super init])) {
        _count = 0;
        _subindex = 0;
        _list = objc_copyClassList(&_count);
    }
    return self;
}

- (void)dealloc {
    if (_list) {
        free(_list);
    }
    [super dealloc];
}

+ (void)getClasses:(Class **)array count:(NSUInteger *)aCount {
    NSZone *zone = nil;
    AJRClassEnumerator *enumerator = [[[self class] allocWithZone:zone] init];
    Class next;
    NSInteger maxCount = 256;

    NSCAssert(enumerator != nil, @"We apparently out of memory. Let's die.");
    
    *array = (Class *)NSZoneMalloc(zone, sizeof(Class) * maxCount);
    *aCount = 0;
    
    while ((next = [enumerator nextObject])) {
        (*array)[*aCount] = next;
        (*aCount)++;
        if (*aCount == maxCount) {
            maxCount += 256;
            *array = (Class *)NSZoneRealloc(zone, *array, sizeof(Class) * maxCount);
        }
    }

    [enumerator release];
}

static BOOL AJRSafeIsClassInheritedFromNSObject(Class possible) {
    static Class NSObjectClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSObjectClass = objc_getClass("NSObject");;
    });
    // Hack to work around a DVT issue.
    const char *name = class_getName(possible);
    if (strncmp(name, "DVT_", 4) == 0
        || strncmp(name, "VMU", 3) == 0
        || strncmp(name, "UINS", 4) == 0) {
        return NO;
    }
    Class current = possible;
    do {
        if (current == NSObjectClass) {
            return YES;
        }
        current = class_getSuperclass(current);
    } while (current != Nil);
    return NO;
}

- (id)nextObject {
    return [self nextClass];
}

- (Class)nextClass {
    Class possible = Nil;
    do {
        possible = _subindex >= _count ? Nil : _list[_subindex++];
    } while (possible && !AJRSafeIsClassInheritedFromNSObject(possible));
    return possible;
}

@end

BOOL AJRClassIsKindOfClass(Class inputClass, Class superclass) {
    Class class = inputClass;
    
    while (class != Nil) {
        if (class == superclass) {
            return YES;
        }
        class = class_getSuperclass(class);
    }
    
    return NO;
}

NSArray<Class> *AJRClassesInheritingFromClass(Class superclass, BOOL includeSuperclass) {
    NSMutableArray<Class> *classes = [NSMutableArray array];
    
    for (Class aClass in [AJRClassEnumerator classEnumerator]) {
        if (AJRClassIsKindOfClass(aClass, superclass)) {
            if (!includeSuperclass && aClass == superclass) {
                continue;
            }
            [classes addObject:aClass];
        }
    }
    
    return classes;
}
