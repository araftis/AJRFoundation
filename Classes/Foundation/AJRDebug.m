//
//  AJRDebug.m
//  AJRFoundation
//
//  Created by AJ Raftis on 7/23/19.
//

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
