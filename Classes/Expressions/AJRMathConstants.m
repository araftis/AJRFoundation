
#import "AJRMathConstants.h"


@implementation AJRPIConstant

- (id)value {
    return @(M_PI);
}

@end

@implementation AJREConstant

- (id)value {
    return @(M_E);
}

@end

@implementation AJRNilConstant

- (id)value {
    return @(0);
}

@end
