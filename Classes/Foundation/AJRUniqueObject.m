
#import "AJRUniqueObject.h"

#import <objc/runtime.h>

@implementation AJRUniqueObject

+ (id)allocWithZone:(NSZone *)newZone {
    id instance = nil;
    
    @synchronized (self) {
        @autoreleasepool {
            instance = objc_getAssociatedObject(self, @selector(alloc));
            if (instance == nil) {
                instance = [super allocWithZone:newZone];
                objc_setAssociatedObject(self, @selector(alloc), instance, OBJC_ASSOCIATION_RETAIN);
            }
        }
    }
    
    return instance;
}

- (id)self {
    return objc_getAssociatedObject([self class], @selector(alloc));
}

+ (id)self {
    return objc_getAssociatedObject(self, @selector(alloc));
}

@end
