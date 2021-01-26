//
//  AJRConstantExpression.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/4/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRExpression.h>

@interface AJRConstantExpression : AJRExpression 

+ (AJRConstantExpression *)expressionWithValue:(id)value;
- (id)initWithValue:(id)value;

@property (nonatomic,strong) id value;

@end
