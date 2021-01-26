//
//  AJRUnaryExpression.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/3/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJROperatorExpression.h>

NS_ASSUME_NONNULL_BEGIN

@class AJROperator;

@interface AJRUnaryExpression : AJROperatorExpression <NSCoding>

+ (nullable instancetype)expressionWithValue:(nullable id)value operator:(AJROperator *)anOperator;

- (nullable instancetype)initWithValue:(nullable id)left operator:(AJROperator *)anOperator;

@property (nonatomic,strong,nullable) id value;

@end

NS_ASSUME_NONNULL_END
