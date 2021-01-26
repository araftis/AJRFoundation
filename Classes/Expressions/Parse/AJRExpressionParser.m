
#import "AJRExpressionParser.h"

#import "AJRConstant.h"
#import "AJRExpression.h"
#import "AJRExpressionFunctionStackFrame.h"
#import "AJRExpressionStackFrame.h"
#import "AJRExpressionToken.h"
#import "AJRFormat.h"
#import "AJRFunction.h"
#import "AJROperator.h"
#import "AJRPlugInManager.h"
#import "NSCharacterSet+Extensions.h"
#import "NSString+Extensions.h"

static NSCharacterSet *whitespaceSet;
static NSMutableCharacterSet *literalStartSet;
static NSMutableCharacterSet *literalSet;
static NSCharacterSet *numberStartSet;
static NSCharacterSet *argumentNumberStartSet;
static NSCharacterSet *numberSet;
static NSMutableCharacterSet *operatorStartSet;
static NSMutableCharacterSet *operatorSet;

@interface AJRExpressionParser ()

- (AJRExpression *)expressionWithArguments:(va_list)arguments;

@end

@implementation AJRExpressionParser

#pragma mark Initialize

+ (void)initialize
{  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        argumentNumberStartSet = [NSCharacterSet characterSetWithCharactersInString:@"+-0123456789"];
        numberStartSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        literalStartSet = [[NSCharacterSet ajr_swiftIdentifierStartCharacterSet] mutableCopy];
        literalSet = [[NSCharacterSet ajr_swiftIdentifierCharacterSet] mutableCopy];
        operatorStartSet = [[NSMutableCharacterSet alloc] init];
        operatorSet = [[NSMutableCharacterSet alloc] init];
        
        // Since we depend on the plug-in manager, make sure it's initialized.
        [AJRPlugInManager initializePlugInManager];
    });
}

#pragma mark Creation

- (id)initWithString:(NSString *)string
{
    return [self initWithStringFormat:string arguments:NULL];
}

- (id)initWithStringFormat:(NSString *)string, ...
{
    va_list     ap;
    
    va_start(ap, string);
    self = [self initWithStringFormat:string arguments:ap];
    va_end(ap);
    
    return self;
}

- (id)initWithStringFormat:(NSString *)string arguments:(va_list)arguments
{
    if ((self = [super init])) {
        if ((string == nil) || ([[string stringByTrimmingCharactersInSet:whitespaceSet] length] == 0)) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to create AJRExpression. No expression string supplied." userInfo:nil];
        }
        
        _input = [string dataUsingEncoding:NSUTF32StringEncoding];
        _rawInput = [_input bytes];
        _length = [_input length] / sizeof(UTF32Char);
        _position = 1; // Skip the BOM marker.
        // Fault the expression immediately. This is necessary, because we have the arguments available.
        [self expressionWithArguments:arguments];
    }
    return self;
}

#pragma mark - Utilities

- (NSString *)stringFromRange:(NSRange)range
{
    UTF32Char buffer[range.length + 1];
    buffer[0] = _rawInput[0]; // Make sure to use the same BOM.
    memcpy(buffer + 1, _rawInput + range.location, range.length * sizeof(UTF32Char));
    NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:(range.length + 1) * sizeof(UTF32Char) freeWhenDone:NO];
    return [[NSString alloc] initWithData:data encoding:NSUTF32StringEncoding];
}

#pragma mark Parse

- (void)readWhitespace
{
    while ((_position < _length) && [whitespaceSet longCharacterIsMember:_rawInput[_position]]) {
        _position++;
    }
}

- (AJRExpressionToken *)readNumber
{
    NSInteger    start = _position;
    BOOL        hasDecimal = NO;
    NSNumber    *value;
    
    // Make sure we move over a +/-
    while (_position < _length) {
        UTF32Char character = _rawInput[_position];
        
        if (![numberSet longCharacterIsMember:character]) break;
        if (character == '.') {
            if (hasDecimal) break;
            hasDecimal = YES;
        }
        
        _position++;
    }
    
    value = (id)[self stringFromRange:(NSRange){start, _position - start}];
    if (hasDecimal) {
        value = [NSNumber numberWithDouble:[value floatValue]];
    } else {
        value = [NSNumber numberWithLong:[value longValue]];
    }
    
    return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:value];
}

- (AJRExpressionToken *)readOperator
{
    NSInteger start = _position;
    NSString *value;
    AJROperator *operator;
    
    while (_position < _length && [operatorSet longCharacterIsMember:_rawInput[_position]]) {
        _position++;
    }
    
    // Get the token from the stream
    value = [self stringFromRange:(NSRange){start, _position - start}];
    
    // See if it's an operator
    operator = [AJROperator operatorForToken:value];
    if (operator) {
        return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator value:operator];
    }
    
    // Fell through, so treat it as a literal. Note, we'll never be a constant, like we have in the readLiteral code, because constants are registered as literals, which means having a constant will cause us to enter the readLiteral code rather than the readOperator code.
    return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeLiteral value:value];
}

- (AJRExpressionToken *)readLiteral
{
    NSInteger start = _position;
    NSString *value;
    AJROperator *operator;
    AJRConstant *constant;
    
    while (_position < _length && ([literalSet longCharacterIsMember:_rawInput[_position]] || _rawInput[_position] == '.' || _rawInput[_position] == '@')) {
        _position++;
    }
    
    // Get the token from the stream
    value = [self stringFromRange:(NSRange){start, _position - start}];
    
    if (_position < _length && _rawInput[_position] == '(') {
        // We have a function declaration.
        Class functionClass = [AJRFunction functionClassForName:value];
        
        // Consume the opening parenthesis.
        _position++;
        
        if (functionClass) {
            AJRFunction *function = [[functionClass alloc] init];
            AJRExpressionToken *token = [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeFunction value:function];
            return token;
        }
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Unknown function: %@", value) userInfo:nil];
    }
                
    // See if it's an operator
    operator = [AJROperator operatorForToken:value];
    if (operator) {
        return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator value:operator];
    }
    constant = [AJRConstant constantForToken:value];
    if (constant) {
        return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:constant];
    }
    
    return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeLiteral value:value];
}

#define INCREMENT_POSITION() { \
    outPosition++; \
    if (outPosition == max) { \
        max += 32; \
        buffer = (UTF32Char *)NSZoneRealloc(NULL, buffer, sizeof(UTF32Char) * max); \
    } \
}

- (AJRExpressionToken *)readStringWithStartCharacter:(UTF32Char)startCharacter
{  
    AJRExpressionToken *token;
    UTF32Char *buffer;
    NSInteger max = 32;
    NSInteger outPosition = 0;
    UTF32Char character;
    
    buffer = (UTF32Char *)NSZoneMalloc(nil, sizeof(UTF32Char) * (max + 1));
    buffer[outPosition++] = _rawInput[0];
    
    _position++; // skip past the opening quote
    while (_position < _length) {
        character = _rawInput[_position];
        if (character == startCharacter) {
            break; 
        } else if (character == '\\') {
            _position++;
            if (_position >= _length) break;
            character = _rawInput[_position];
            if (character == 'n') {
                character = '\n'; 
            } else if (character == 'r') {
                character = '\r';
            } else if (character == 'e') {
                character = '\e';
            } else if (character == 't') {
                character = '\t';
            } else if (character == 's') {
                character = ' ';
            } else if (character == '\'') {
                character = '\'';
            } else if (character == '"') {
                character = '"';
            } else if (character == '\\') {
                character = '\\';
            } else {
                character = '?';
            }
            buffer[outPosition] = character;
            INCREMENT_POSITION();
        } else {
            buffer[outPosition] = character;
            INCREMENT_POSITION();
        }
        _position++;
    }
    
    NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:outPosition * sizeof(UTF32Char) freeWhenDone:NO];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF32StringEncoding];
    token = [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeString value:string];
    NSZoneFree(nil, buffer);
    _position++;
    
    return token;
}

- (AJRExpressionToken *)tokenForValue:(id)value
{
    AJRExpressionToken *token = nil;
    
    if (value == nil) {
        token = [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:nil];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        token = [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:value];
    } else {
        // A string, or something we're going to treat as a string.
        NSString *stringValue = [value description];
        AJRConstant *constant = [AJRConstant constantForToken:stringValue];
        if (constant) {
            token = [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:constant];
        } else {
            token = [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeString value:stringValue];
        }
    }
    
    return token;
}

- (AJRExpressionToken *)readArgumentExpandingConstants:(BOOL)expandConstants withArguments:(va_list)arguments
{
    UTF32Char character;
    
    if (_position >= _length) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No modifier to %%" userInfo:nil];
    }
    
    character = _rawInput[_position];
    _position++;
    if (character == 'd') {
        NSInteger arg = va_arg(arguments, NSInteger);
        return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:[NSNumber numberWithInteger:arg]];
    } else if (character == 's') {
        const char *value = va_arg(arguments, char *);
        return [self tokenForValue:value ? [NSString stringWithCString:value encoding:NSUTF8StringEncoding] : nil];
    } else if (character == '@') {
        return [self tokenForValue:va_arg(arguments, id)];
    } else if (character == 'f') {
        double arg = va_arg(arguments, double);
        return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber value:[NSNumber numberWithDouble:arg]];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"No modifier to %%: %c", character) userInfo:nil];
    }
    
    return nil;
}

- (AJRExpressionToken *)nextTokenWithArguments:(va_list)arguments
{
    UTF32Char character;
    
    // Ignore any leading whitespace
    [self readWhitespace];
    
    if (_position < _length) {
        character = _rawInput[_position];
        if (character == '(') {
            _position++;
            return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOpenParen];
        } else if (character == ')') {
            _position++;
            return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeCloseParen];
        } else if (character == ',') {
            _position++;
            return [AJRExpressionToken tokenWithType:AJRExpressionTokenTypeComma];
        } else if ([numberStartSet longCharacterIsMember:character]) {
            return [self readNumber];
        } else if (character == '"' || character == '\'') {
            return [self readStringWithStartCharacter:character];
        } else if (character == '%') {
            _position++;
            return [self readArgumentExpandingConstants:YES withArguments:arguments];
        } else if ([literalStartSet longCharacterIsMember:character]) {
            // Anything not identified above is a literal, which might turn out to be an operator
            // or a key, or something else.
            return [self readLiteral];
        } else if ([operatorStartSet longCharacterIsMember:character]) {
            return [self readOperator];
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Unexpected character in input: 0x%x '%c'", character, character) userInfo:nil];
        }
    }
    
    return nil;
}

- (AJRExpression *)expressionWithArguments:(va_list)arguments
{
    if (_expression == nil) {
        AJRExpressionToken *token;
        AJRExpressionStackFrame *frame;
        
        _stack = [[NSMutableArray alloc] init];
        [_stack addObject:[AJRExpressionStackFrame frame]];
        
        while ((token = [self nextTokenWithArguments:arguments])) {
            // Used by a lot below...
            frame = [_stack lastObject];
            
            switch ([token type]) {
                case AJRExpressionTokenTypeString:
                case AJRExpressionTokenTypeNumber:
                case AJRExpressionTokenTypeLiteral:
                case AJRExpressionTokenTypeOperator:
                    if ([[token value] isKindOfClass:[AJRExpression class]]) {
                        [frame addExpression:[token value]];
                    } else {
                        [frame addToken:token];
                    }
                    break;
                case AJRExpressionTokenTypeOpenParen:
                    [_stack addObject:[AJRExpressionStackFrame frame]];
                    break;
                case AJRExpressionTokenTypeCloseParen:
                    if ([_stack count] <= 1) {
                        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unbalanced parentheses in expression" userInfo:nil];
                    } else {
                        AJRExpression    *expression;
                        // Make sure this doesn't free itself when we remove it from the _stack.
                        [_stack removeLastObject];
                        // And add the subframe's expression to the preceeding stack frame.
                        expression = [frame expression];
                        [expression setProtected:YES];
                        [[_stack lastObject] addExpression:expression];
                    }
                    break;
                case AJRExpressionTokenTypeFunction:
                    frame = [AJRExpressionFunctionStackFrame frameWithFunction:(AJRFunction *)[token value]];
                    [_stack    addObject:frame];
                    break;
                case AJRExpressionTokenTypeComma: {
                    // Search the stack frame for a function expression
                    for (NSInteger x = [_stack count] - 1; x >= 0; x--) {
                        AJRExpressionFunctionStackFrame    *frame = [_stack objectAtIndex:x];
                        if ([frame isKindOfClass:[AJRExpressionFunctionStackFrame class]]) {
                            [frame reduceArgument];
                        }
                    }
                    break;
                }
            }
        }
        
        // Modified the below line to check for one than one item on the _stack.
        // If no parenthesis
        // were used then there will only be one item on the _stack.
        if ([_stack count] > 1) {
            // frame = _stack.get(_stack.size() - 1);
            // _stack.remove(_stack.size() - 1);
            // _stack.get(_stack.size() - 1).applyFrame(frame);
            // This should be an error condition, because it means we opened a
            // parenthesis, but
            // didn't close it.
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Illegal expression string, probably caused by an unclosed parenthesis." userInfo:nil];
        }
        
        _expression = [[_stack lastObject] expression];
        _stack = nil;
    }
    
    return _expression;
}

- (AJRExpression *)expression
{
    return _expression;
}

+ (AJRExpression *)expressionForString:(NSString *)string
{
    return [[[AJRExpressionParser alloc] initWithString:string] expression];
}

+ (AJRExpression *)expressionForStringFormat:(NSString *)string, ...
{
    AJRExpression *expression;
    va_list ap;
    
    va_start(ap, string);
    expression = [self expressionForStringFormat:string arguments:ap];
    va_end(ap);
    
    return expression;
}

+ (AJRExpression *)expressionForStringFormat:(NSString *)string arguments:(va_list)arguments
{
    return [[[AJRExpressionParser alloc] initWithStringFormat:string arguments:arguments] expression];
}

#pragma mark Tokens

+ (void)addLiteralToken:(NSString *)token
{
    if ([token length]) {
        NSData *data = [token dataUsingEncoding:NSUTF32StringEncoding];
        const UTF32Char *buffer = [data bytes];
        NSInteger length = [data length] / sizeof(UTF32Char);
        for (NSInteger x = 1; x < length; x++) {
            if (x == 1) {
                [literalStartSet addCharactersInRange:(NSRange){buffer[x], 1}];
            }
            [literalSet addCharactersInRange:(NSRange){buffer[x], 1}];
        }
    }
}

+ (void)addOperatorToken:(NSString *)token
{
    if ([token rangeOfCharacterFromSet:literalStartSet].location != NSNotFound) {
        [self addLiteralToken:token];
    } else if ([token length]) {
        NSData *data = [token dataUsingEncoding:NSUTF32StringEncoding];
        const UTF32Char *buffer = [data bytes];
        NSInteger length = [data length] / sizeof(UTF32Char);
        for (NSInteger x = 1; x < length; x++) {
            if (x == 1) {
                [operatorStartSet addCharactersInRange:(NSRange){buffer[x], 1}];
            }
            [operatorSet addCharactersInRange:(NSRange){buffer[x], 1}];
        }
    }
}

@end
