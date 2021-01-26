//
//  AJREqualsOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/2/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJREqualsOperator.h"

@implementation AJREqualsOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if (left == right) return [NSNumber numberWithBool:YES];
    return [NSNumber numberWithBool:[left isEqual:right]];
}

@end
