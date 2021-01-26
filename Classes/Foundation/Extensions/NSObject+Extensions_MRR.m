//
//  NSObject+Extensions_MRR.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 7/3/14.
//
//

#import "NSObject+Extensions.h"

#import <objc/message.h>
#import <objc/runtime.h>

@implementation NSObject (AJRFoundationExtensionsMRR)

#pragma mark - Shadowing

typedef id (*AJRNoArgSelector)(id, SEL);
typedef id (*AJROneArgSelector)(id, SEL, id);
typedef id (*AJRTwoArgSelector)(id, SEL, id, id);

- (id)ajr_performSelector:(SEL)selector {
    AJRNoArgSelector imp = (AJRNoArgSelector)class_getMethodImplementation([self class], selector);
    return imp ? imp(self, selector) : nil;
}

- (id)ajr_performSelector:(SEL)selector withObject:(id)object {
    AJROneArgSelector imp = (AJROneArgSelector)class_getMethodImplementation([self class], selector);
    return imp ? imp(self, selector, object) : nil;
}

- (id)ajr_performSelector:(SEL)selector withObject:(id)object withObject:(id)object2 {
    AJRTwoArgSelector imp = (AJRTwoArgSelector)class_getMethodImplementation([self class], selector);
    return imp ? imp(self, selector, object, object2) : nil;
}

@end
