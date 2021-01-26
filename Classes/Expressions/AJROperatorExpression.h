//
//  AJROperatorExpression.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/5/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRExpression.h>

@class AJROperator;

@interface AJROperatorExpression : AJRExpression

- (instancetype)initWithOperator:(AJROperator *)operator;

@property (nonatomic,strong) AJROperator *operator;

@end
