
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

