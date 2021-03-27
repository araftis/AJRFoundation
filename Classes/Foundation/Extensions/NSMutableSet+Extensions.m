
#import "NSMutableSet+Extensions.h"

@implementation NSMutableSet (Extensions)

- (void)addObjectIfNotNil:(nullable id)object {
    if (object != nil) {
        [self addObject:object];
    }
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-set";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSMutableSet class];
}

@end
