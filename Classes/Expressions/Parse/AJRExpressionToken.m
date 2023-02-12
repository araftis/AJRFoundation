/*
 AJRExpressionToken.m
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AJRExpressionToken.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"

@interface AJRExpressionToken ()

@property (nonatomic,assign) AJRExpressionTokenType type;
@property (nonatomic,nullable,strong) id value;

@end

@implementation AJRExpressionToken

static AJRExpressionToken *AJROpenParenToken = nil;
static AJRExpressionToken *AJRCloseParenToken = nil;
static AJRExpressionToken *AJRCommaToken = nil;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AJROpenParenToken = [[AJRExpressionToken alloc] initWithType:AJRExpressionTokenTypeOpenParen value:nil];
        AJRCloseParenToken = [[AJRExpressionToken alloc] initWithType:AJRExpressionTokenTypeCloseParen value:nil];
        AJRCommaToken = [[AJRExpressionToken alloc] initWithType:AJRExpressionTokenTypeComma value:nil];
    });
}

+ (instancetype)tokenWithType:(AJRExpressionTokenType)aType
{
    return [self tokenWithType:aType value:nil];
}

+ (instancetype)tokenWithType:(AJRExpressionTokenType)aType value:(id)aValue
{
    if (aType == AJRExpressionTokenTypeOpenParen) {
        return AJROpenParenToken;
    } else if (aType == AJRExpressionTokenTypeCloseParen) {
        return AJRCloseParenToken;
    } else if (aType == AJRExpressionTokenTypeComma) {
        return AJRCommaToken;
    }
    
    return [[AJRExpressionToken alloc] initWithType:aType value:aValue];
}

- (instancetype)initWithType:(AJRExpressionTokenType)aType value:(id)aValue
{
    if ((self = [super init])) {
        _type = aType;
        _value = aValue;
    }
    return self;
}

- (NSString *)description
{
    if (_value) {
        return [NSString stringWithFormat:@"[Token (%@): %@]", AJRStringFromExpressionTokenType(_type), _value];
    }
    return [NSString stringWithFormat:@"[Token (%@)]", AJRStringFromExpressionTokenType(_type)];
}

@end

NSString *AJRStringFromExpressionTokenType(AJRExpressionTokenType type)
{
    switch (type) {
        case AJRExpressionTokenTypeString:     return @"String";
        case AJRExpressionTokenTypeNumber:     return @"Number";
        case AJRExpressionTokenTypeLiteral:    return @"Literal";
        case AJRExpressionTokenTypeOperator:   return @"Operator";
        case AJRExpressionTokenTypeOpenParen:  return @"OpenParen";
        case AJRExpressionTokenTypeCloseParen: return @"CloseParen";
        case AJRExpressionTokenTypeFunction:      return @"Function";
        case AJRExpressionTokenTypeComma:      return @"Comma";
    }
    AJRAssertUnreachable(@"Invalid AJRExpressionTokenType: %d", (int)type);
}

