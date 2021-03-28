/*
AJRDebug.m
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

#import "AJRDebug.h"

#import "AJRFunctions.h"

#import <objc/runtime.h>

@implementation AJRDebug

typedef void (*AddObserverIMP)(id, SEL, NSObject *, NSString *, NSKeyValueObservingOptions, void *);
typedef id (*InitObservableIMP)(id, SEL, id, id, NSUInteger, void *);

//static AddObserverIMP originalIMP;
//static InitObservableIMP originalInitIMP;

// This code, while it mostly works, causes some unexpected crashes, and since it's only for debug purposes, I've commented it out for now. Should I need this again in the future, I'll dig into details of the crash more closely.

+ (void)load {
//    Method method1 = class_getInstanceMethod(NSClassFromString(@"NSKeyValueObservance"), @selector(_initWithObserver:property:options:context:originalObservable:));
//    if (method1) {
//        originalInitIMP = (InitObservableIMP)method_getImplementation(method1);
//        Method method2 = class_getInstanceMethod(self, @selector(ajr_initWithObserver:property:options:context:originalObservable:));
//        if (method2) {
//            IMP newIMP = method_getImplementation(method2);
//            method_setImplementation(method1, newIMP);
//        }
//    }
}

//- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
//    AJRPrintf(@"Observing: %@\n", keyPath);
//    if ([keyPath isEqualToString:@"layer"] || [keyPath hasSuffix:@".layer"]) {
//        AJRPrintf(@"object: %@\n", observer);
//    }
//    originalIMP(self, _cmd, observer, keyPath, options, context);
//}
//
//- (id)ajr_initWithObserver:(id)observer property:(id)property options:(NSUInteger)options context:(void *)context originalObservable:(id)originalObservable {
//    return originalInitIMP(self, _cmd, observer, property, options, context);
//}

@end
