//
//  AJRFunctionExpression.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/8/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRExpression.h>

@class AJRFunction;

@interface AJRFunctionExpression : AJRExpression <NSCoding>

+ (id)expressionWithFunction:(AJRFunction *)function;
- (id)initWithFunction:(AJRFunction *)function;

@property (nonatomic,strong) AJRFunction *function;

@end
