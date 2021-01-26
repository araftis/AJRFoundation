//
//  AJRConstant.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/4/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRUnaryExpression.h>

@interface AJRConstant : AJRUnaryExpression <NSCoding, NSCopying>

+ (void)registerConstant:(Class)constantClass;

+ (AJRConstant *)constantForToken:(NSString *)token;

+ (NSArray<NSString *> *)tokens;
+ (NSString *)preferredToken;

- (BOOL)isEqualToConstant:(AJRConstant *)other;

@end
