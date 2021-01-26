//
//  AJRModulusOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/8/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRModulusOperator.h"

@implementation AJRModulusOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return [NSNumber numberWithLong:[left longValue] % [right longValue]];
}

@end
