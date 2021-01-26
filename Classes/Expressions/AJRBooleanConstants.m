//
//  AJRBooleanConstants.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/8/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

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
