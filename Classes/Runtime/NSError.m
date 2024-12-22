//
//  NSError.m
//  AJRFoundation
//
//  Created by AJ Raftis on 11/18/23.
//

#import <Foundation/Foundation.h>

#import "AJRRuntime.h"
#import "AJRLogging.h"
#import "AJRMethodEnumerator.h"
#import "NSError+Extensions.h"
#import "AJRFormat.h"
#import "AJRLogging.h"
#import <objc/runtime.h>

#define CRASH_ON_LAUNCH_HACK 0

#if CRASH_ON_LAUNCH_HACK

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

@implementation NSError

+ (Class)_ajr_appleClass {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.Foundation"];
    if (bundle != nil) {
        Class class = [bundle classNamed:@"NSError"];
        if (class != Nil) {
            return class;
        }
    }
    NSAssert(false, @"We reached code we shouldn't have reached.");
    return Nil;
}

static void _AJRCopyClassMethod(Class from, Class to, SEL name) {
    Method method = class_getClassMethod(from, name);
    class_addMethod(objc_getMetaClass(class_getName(to)), name, method_getImplementation(method), method_getTypeEncoding(method));
}

+ (void)load {
    Class original = [self _ajr_appleClass];
    AJRMethodEnumerator *enumerator = [AJRMethodEnumerator methodEnumeratorWithClass:self];
    Method method;

    while ((method = [enumerator nextMethod])) {
        if (!enumerator.isClassMethod) {
            break;
        }
        SEL selector = method_getName(method);
        const char *name = sel_getName(selector);
        if (strncmp(name, "errorWithDomain:", 16) == 0) {
            if (AJRLogGetGlobalLogLevel() >= AJRLogLevelDebug) {
                fprintf(stderr, "DEBUG: Copying method %s\n", name);
            }
            _AJRCopyClassMethod(self, original, selector);
        }
    }
    return;

// These can work, but they're more to maintain, even though this code shouldn't be around for a long time.
//    // ----------------
//    // + (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)message;
//    // ----------------
//    id block = ^(id self, NSString *domain, NSInteger code, NSString *message) {
//        return [original errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
//    };
//    _AJRAddClassMethod(original, @selector(errorWithDomain:code:message:), block, AJRMethodSignature(@encode(NSError *), @encode(NSString *), @encode(NSInteger), @encode(NSString *)));
//
//    // ----------------
//    // + (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format arguments:(va_list)ap;
//    // ----------------
//    block = ^(id self, NSString *domain, NSInteger code, NSString *format, va_list arguments) {
//        return [original errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:AJRFormatv(format, arguments)}];
//    };
//    _AJRAddClassMethod(original, @selector(errorWithDomain:code:format:arguments:), block, AJRMethodSignature(@encode(NSError *), @encode(NSString *), @encode(NSInteger), @encode(NSString *), @encode(va_list)));
//
//    // ----------------
//    // + (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format arguments:(va_list)ap;
//    // ----------------
//    block = ^(id self, NSString *domain, NSInteger code, NSString *format, ...) {
//        va_list ap;
//        va_start(ap, format);
//        id result = [original errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:AJRFormatv(format, ap)}];
//        va_end(ap);
//        return result;
//    };
//    _AJRAddClassMethod(original, @selector(errorWithDomain:code:format:), block, AJRMethodSignature(@encode(NSError *), @encode(NSString *), @encode(NSInteger), @encode(NSString *), @encode(va_list)));
//
//
//
//
//    block = ^(id self, NSString *domain, NSString *message) {
//        return [original errorWithDomain:domain code:-1 userInfo:@{NSLocalizedDescriptionKey:message}];
//    };
//    _AJRAddClassMethod(original, @selector(errorWithDomain:message:), block, AJRMethodSignature(@encode(NSError *), @encode(NSString *), @encode(NSString *)));
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [[self _ajr_appleClass] allocWithZone:zone];
}

+ (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self _ajr_appleClass];
}

#pragma clang diagnostic pop
#pragma clang diagnostic pop
#pragma clang diagnostic pop
#pragma clang diagnostic pop
#pragma clang diagnostic pop

@end

#endif
