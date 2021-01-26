//
//  AJRUnaryOperator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/3/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import "AJRUnaryOperator.h"

#import "AJRFunctions.h"

@implementation AJRUnaryOperator

- (id)performOperatorWithValue:(id)value error:(NSError **)error
{
    return AJRAbstract(nil);
}

#pragma mark AJROperator

- (AJROperatorPrecedence)precedence
{
    return AJRAbstract(AJROperatorPrecedenceUnary);
}

@end
