
#import "AJRExpressionFunctionStackFrame.h"

#import "AJRExpression.h"
#import "AJRExpressionToken.h"
#import "AJRFormat.h"
#import "AJRFunction.h"
#import "AJRFunctionExpression.h"

@interface AJRExpressionFunctionStackFrame ()
@property (nonatomic,strong) AJRFunction *function;
@end

@implementation AJRExpressionFunctionStackFrame

#pragma mark Creation

+ (instancetype)frameWithFunction:(AJRFunction *)function
{
    return [[self alloc] initWithFunction:function];
}

- (instancetype)initWithFunction:(AJRFunction *)function
{
    if ((self = [super init])) {
        _function = function;
    }
    return self;
}

#pragma mark Actions

- (void)reduceArgument
{
    // This only works if the stack count is 1.
    if ([_tokenStack count] == 1) {
        // Get the actual expression of the argument from our super.
        AJRExpression    *expression = [super expression];
        
        if (expression) {
            // If we got something, add it as an argument to the function.
            [_function addArgument:expression];
        }
        // And regardless of what we did, clear the expression in preparation for the next argument.
        [_tokenStack removeAllObjects];
    } else if ([_tokenStack count] > 1) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:AJRFormat(@"Expression failed to fully reduce: %@", _tokenStack) userInfo:nil];
    }
    // Do nothing in this case. We'll just ignore blank arguments.
}

#pragma mark AJRExpressionStackFrame

- (AJRExpression *)expression
{
    // First off, let's make sure we reduce the last argument
    [self reduceArgument];
    
    return [AJRFunctionExpression expressionWithFunction:_function];
}
@end
