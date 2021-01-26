//
//  AJRGreatorThanOrEqualToOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/2/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRGreatorThanOrEqualToOperator.h"

@implementation AJRGreatorThanOrEqualToOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return @([(NSNumber *)left compare:right] >= NSOrderedSame);
}

@end
