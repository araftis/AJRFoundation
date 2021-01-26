//
//  AJRMultiplyOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/2/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRMultiplyOperator.h"

#import "NSNumber+Extensions.h"

@implementation AJRMultiplyOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if ([left isInteger] && [right isInteger]) {
        return [NSNumber numberWithLong:[left longValue] * [right longValue]];
    }
    return [NSNumber numberWithDouble:[left doubleValue] * [right doubleValue]];
}

@end
