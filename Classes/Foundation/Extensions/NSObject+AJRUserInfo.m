
#import <AJRFoundation/NSObject+AJRUserInfo.h>

#import "AJRExpression.h"
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

