//
//  AJRMathConstants.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/8/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

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
