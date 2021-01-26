//
//  AJRExponentOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/8/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRExponentOperator.h"

@implementation AJRExponentOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    return [NSNumber numberWithDouble:pow([left doubleValue], [right doubleValue])];
}

@end
