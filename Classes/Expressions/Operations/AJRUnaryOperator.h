//
//  AJRUnaryOperator.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/3/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJROperator.h>

@interface AJRUnaryOperator : AJROperator

- (id)performOperatorWithValue:(id)value error:(NSError **)error;

@end
