//
//  AJRExpressionToken.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/2/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRExpressionTokenType) {
    AJRExpressionTokenTypeString,
    AJRExpressionTokenTypeNumber,
    AJRExpressionTokenTypeLiteral,
    AJRExpressionTokenTypeOperator,
    AJRExpressionTokenTypeOpenParen,
    AJRExpressionTokenTypeCloseParen,
    AJRExpressionTokenTypeFunction,
    AJRExpressionTokenTypeComma
};

@interface AJRExpressionToken : NSObject

+ (instancetype)tokenWithType:(AJRExpressionTokenType)aType;
+ (instancetype)tokenWithType:(AJRExpressionTokenType)aType value:(nullable id)aValue;
- (instancetype)initWithType:(AJRExpressionTokenType)aType value:(nullable id)aValue;

@property (nonatomic,readonly) AJRExpressionTokenType type;
@property (nonatomic,nullable,readonly,strong) id value;

@end

extern NSString *AJRStringFromExpressionTokenType(AJRExpressionTokenType type);

NS_ASSUME_NONNULL_END
