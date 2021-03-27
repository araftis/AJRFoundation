
#import "AJRBooleanConstants.h"

@implementation AJRTrueConstant

- (id)value
{
    return [NSNumber numberWithBool:YES];
}

@end

@implementation AJRFalseConstant

- (id)value
{
    return [NSNumber numberWithBool:NO];
}

@end
