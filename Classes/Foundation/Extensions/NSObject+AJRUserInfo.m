/*
NSObject+AJRUserInfo.m
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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

#import <AJRFoundation/NSObject+AJRUserInfo.h>

#import <AJRFoundation/AJRFoundation-Swift.h>
#import "AJRFunctions.h"

#import <objc/runtime.h>

@implementation NSObject (AJRUserInfo)

+ (void *)ajr_keyForString:(NSString *)string {
	static NSMutableDictionary<NSString *, id> *keyStore = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keyStore = [[NSMutableDictionary alloc] init];
	});

	NSValue *value = [keyStore objectForKey:string];
    if (value == nil) {
        void *pointer = NSZoneMalloc(NULL, 1);
        value = [NSValue valueWithPointer:pointer];
        [keyStore setObject:value forKey:string];
    }
    return [value pointerValue];
}

+ (id)classObjectForKey:(NSString *)key {
    return objc_getAssociatedObject(self, [self ajr_keyForString:key]);
}

+ (void)setClassObject:(id)object forKey:(NSString *)key {
    objc_setAssociatedObject(self, [self ajr_keyForString:key], object, OBJC_ASSOCIATION_RETAIN);
}

- (id)instanceObjectForKey:(NSString *)key {
    return objc_getAssociatedObject(self, [[self class] ajr_keyForString:key]);
}

- (void)setInstanceObject:(id)object forKey:(NSString *)key {
    objc_setAssociatedObject(self, [[self class] ajr_keyForString:key], object, OBJC_ASSOCIATION_RETAIN);
}

+ (void)clearClassObjects {
    objc_removeAssociatedObjects(self);
}

- (void)clearInstanceObjects {
    objc_removeAssociatedObjects(self);
}

@end

