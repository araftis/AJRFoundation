//
//  AJRAddOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/2/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRAddOperator.h"

#import "NSNumber+Extensions.h"

@implementation AJRAddOperator

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if ([left isKindOfClass:[NSString class]]) {
        return [(NSString *)left stringByAppendingString:right];
    }
    if ([left isInteger] && [right isInteger]) {
        return [NSNumber numberWithLong:[left longValue] + [right longValue]];
    }
    return [NSNumber numberWithDouble:[left doubleValue] + [right doubleValue]];
}

// Note: Subtraction is special, because it sometimes acts as a unary operator to make a value negative.
- (id)performOperatorWithValue:(id)value error:(NSError **)error
{
    return value; // But it's also basically a no-op
}

@end
