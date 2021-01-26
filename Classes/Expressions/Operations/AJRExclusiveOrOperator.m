//
//  AJRExclusiveOrOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/4/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRExclusiveOrOperator.h"

@implementation AJRExclusiveOrOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    BOOL l = [left boolValue], r = [right boolValue];
    return [NSNumber numberWithBool:(l || r) && (!l || !r)];
}

@end
