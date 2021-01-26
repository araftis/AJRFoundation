//
//  AJRKeyExpression.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/3/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRExpression.h>

@interface AJRKeyExpression : AJRExpression 

+ (AJRKeyExpression *)expressionWithKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;

@property (nonatomic,strong) NSString *key;

@end
