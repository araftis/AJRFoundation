
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface _AJRCustomNumber : NSNumber

+ (id)ajr_numberWithLongDouble:(long double)value;

@end

@interface AJRIntegerFunction : AJRFunction

@end

@implementation AJRIntegerFunction

+ (NSString *)name
{
    return @"ajr_testintegerparameter";
}

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    NSInteger value = localError == nil ? [self integerAtIndex:0 withObject:object error:&localError] : 0.0;
    id returnValue = localError == nil ? @(value) : nil;
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

- (NSString *)prototype {
    return @"ajr_testintegerparameter()";
}

@end

@interface AJRBrokenFunction : AJRFunction

@end

@implementation AJRBrokenFunction

+ (NSString *)name
{
    return @"ajr_broken";
}

@end

@interface AJRBrokenOperator : AJROperator

@end

@implementation AJRBrokenOperator

+ (NSArray<NSString *> *)tokens
{
    return @[@"ajr_broken_operator"];
}

@end

@interface AJRBrokenUnaryOperator : AJRUnaryOperator

@end

@implementation AJRBrokenUnaryOperator

+ (NSArray<NSString *> *)tokens
{
    return @[@"ajr_broken_unary"];
}

@end

@interface AJROddStartOperator : AJROperator

@end

@implementation AJROddStartOperator

+ (NSArray<NSString *> *)tokens
{
    return @[@"👁"];
}

//- (AJROperatorPrecedence)precedence {
//    return AJROperatorPrecedenceLow;
//}

+ (NSString *)preferredToken {
    return @"👁";
}

- (id)performOperatorWithLeft:(id)left andRight:(id)right error:(NSError **)error
{
    if ([left isInteger] && [right isInteger]) {
        return [NSNumber numberWithLong:[left longValue] + [right longValue]];
    }
    return [NSNumber numberWithDouble:[left doubleValue] + [right doubleValue]];
}

@end

@interface AJRArgCountCheckerFunction : AJRFunction

@end

@implementation AJRArgCountCheckerFunction

+ (NSString *)name
{
    return @"ajr_arg_count_checker";
}

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    id value = nil;
    
    localError = [self checkArgumentCountMin:2];
    if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at least 2 arguments"]) {
        localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
    }
    
    if (localError == nil) {
        localError = [self checkArgumentCountMax:10];
        if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at most 10 arguments"]) {
            localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
        }
    }
    
    if (localError == nil) {
        if ([[self stringAtIndex:0 withObject:object error:NULL] isEqualToString:@"one"]) {
            localError = [self checkArgumentCountMax:1];
            if (localError && [[localError localizedDescription] isEqualToString:@"Function ajr_arg_count_checker expects at most 1 argument"]) {
                localError = [NSError errorWithDomain:AJRExpressionErrorDomain message:@"Correct"];
            }
        }
    }
    
    return AJRAssertOrPropagateError(value, error, localError);
}

@end

@interface AJRBrokenConstant : AJRConstant

@end

@implementation AJRBrokenConstant

+ (NSArray<NSString *> *)tokens
{
    return @[@"ajr_broken_constant"];
}

// Broken because we don't implement -[AJRConstant value].

@end

@interface AJRExpressionTest : XCTestCase

@end

@implementation AJRExpressionTest

- (void)setUp
{
    [super setUp];
    
    [AJRFunction registerFunction:[AJRIntegerFunction class]];
    [AJRFunction registerFunction:[AJRBrokenFunction class]];
    [AJRFunction registerFunction:[AJRArgCountCheckerFunction class]];
    [AJRConstant registerConstant:[AJRBrokenConstant class]];
    [AJROperator registerOperator:[AJRBrokenOperator class]];
    [AJROperator registerOperator:[AJRBrokenUnaryOperator class]];
    [AJROperator registerOperator:[AJROddStartOperator class]];
}

- (void)_testExpression:(NSString *)string withObject:(id)object expectedResult:(id)expectedValue expectError:(BOOL)expectError
{
    AJRExpression *expression = nil;
    NSError *localError = nil;
    
    expression = [AJRExpression expressionWithString:string error:&localError];
    
    if (localError == nil) {
        XCTAssert(expression != nil, @"Failed to parse expression: \"%@\"", string);
        
        id result = [expression evaluateWithObject:object error:&localError];
        AJRPrintf(@"[%@]: %@ = %@\n", string, expression, result);
        
        XCTAssert(AJREqual(result, expectedValue), @"expression: %@, expected result: %@, got: %@", string, expectedValue, result);
    }
    
    if (expectError) {
        XCTAssert(localError != nil, @"We expected a failure in expression: \"%@\", but didn't get one.", string);
    } else {
        XCTAssert(localError == nil, @"We didn't expect a failure, but got one in expression: \"%@\": %@", string, [localError localizedDescription]);
    }
}

- (void)_testExpression:(NSString *)string withObject:(id)object expectedResult:(id)expectedValue
{
    [self _testExpression:string withObject:object expectedResult:expectedValue expectError:NO];
}

- (void)testBasicExpressions
{
    [self _testExpression:@"5+5" withObject:nil expectedResult:@(10)];
    [self _testExpression:@"-5" withObject:nil expectedResult:@(-5)];
    [self _testExpression:@"-5+10" withObject:nil expectedResult:@(5)];
    [self _testExpression:@"5- -10" withObject:nil expectedResult:@(15)];
    [self _testExpression:@"4+6-2/10" withObject:nil expectedResult:@(9.8)];
    [self _testExpression:@"(4+5)/(1+2)" withObject:nil expectedResult:@(3.0)];
    [self _testExpression:@"(4+6)-(2/10)" withObject:nil expectedResult:@(9.8)];
    [self _testExpression:@"22 mod 10" withObject:nil expectedResult:@(2)];
    [self _testExpression:@"5 == 5" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"5 == 6" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"5 = +5" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"5 = 6" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"5 != 5" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"5 != 6" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"5 ≠ 5" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"5 ≠ 6" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"2 · 3" withObject:nil expectedResult:@(6)];
    [self _testExpression:@"true" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"2 * π" withObject:nil expectedResult:@(2*M_PI)];
    [self _testExpression:@"false and false" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"true and false" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"false ∧ true" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"true && true" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"false or false" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"true or false" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"false ∨ true" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"true || true" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"(false or false) && (!false or !false)" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"(true or false) && (!true or !false)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"(false or true) && (!false or !true)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"(true ∨ true) ∧ (¬true ∨ ¬true)" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"false xor false" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"true xor false" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"false ⊻ true" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"true ^^ true" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"5" withObject:nil expectedResult:@(5)];
    [self _testExpression:@"2^10" withObject:nil expectedResult:@(1024)];
    [self _testExpression:@"null()" withObject:nil expectedResult:nil];
    [self _testExpression:@"isnull(null())" withObject:nil expectedResult:@YES];
    [self _testExpression:@"isnull(\"a\")" withObject:nil expectedResult:@NO];
    [self _testExpression:@"5 + 5 * 5 + 5" withObject:nil expectedResult:@(35)];
    [self _testExpression:@"5 + 5^2 + 5" withObject:nil expectedResult:@(35)];
    [self _testExpression:@"\"foo\" + \"bar\"" withObject:nil expectedResult:@"foobar"];
    [self _testExpression:@"5 + 5 mod 3" withObject:nil expectedResult:@(5 + 5 % 3)];
    [self _testExpression:@"ajr_testintegerparameter(10)" withObject:nil expectedResult:@(10)];
    [self _testExpression:@"ajr_testintegerparameter(10, 10)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"help(sin())" withObject:nil expectedResult:@"sin(value)"];
    [self _testExpression:@"help(ajr_testintegerparameter())" withObject:nil expectedResult:@"ajr_testintegerparameter()"];
    [self _testExpression:@"min(\"5\", \"4\")" withObject:nil expectedResult:@(4)];
    [self _testExpression:@"1 > 2" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"2 > 2" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"3 > 2" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"1 >= 2" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"2 >= 2" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"3 >= 2" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"1 < 2" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"2 < 2" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"3 < 2" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"1 <= 2" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"2 <= 2" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"3 <= 2" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"alex + 2" withObject:@{@"alex":@(1)} expectedResult:@(3)];
    [self _testExpression:@"👁💕🐑 + 1" withObject:@{@"👁💕🐑":@(2)} expectedResult:@(3)];
    [self _testExpression:@"1 👁 1" withObject:nil expectedResult:@(2)];
    [self _testExpression:@"1.5 👁 1.5" withObject:nil expectedResult:@(3)];
    [self _testExpression:@"++& + 1" withObject:@{@"++&":@(1)} expectedResult:@(2)];
    [self _testExpression:@"ifelse(nil, 'one', 'two')" withObject:nil expectedResult:@"two"];
}


- (void)testObjectExpressions
{
    NSDictionary    *dictionary;
    
    dictionary = @{
        @"zero":@(0),
        @"one":@(1),
        @"two":@(2),
        @"three":@(3),
        @"four":@(4),
        @"five":@(5),
        @"six":@(6),
        @"seven":@(7),
        @"eight":@(8),
        @"nine":@(9),
        @"ten":@(10),
        @"array":@[@"one", @"two", @"three", @"four"],
    };
    
    [self _testExpression:@"five" withObject:dictionary expectedResult:@(5)];
    [self _testExpression:@"two + three" withObject:dictionary expectedResult:@(5)];
    [self _testExpression:@"array.@count" withObject:dictionary expectedResult:@(4)];
    [self _testExpression:@"array.@count + three" withObject:dictionary expectedResult:@(7)];
}

- (void)testSetOperations
{
    NSDictionary    *dictionary;
    
    dictionary = @{
        @"array1":@[@"one", @"two", @"three", @"four"],
        @"array2":@[@"three", @"four", @"five", @"six"],
    };
    
    [self _testExpression:@"array1 union array2" withObject:dictionary expectedResult:@[@"one", @"two", @"three", @"four", @"five", @"six"]];
    [self _testExpression:@"array1 intersect array2" withObject:dictionary expectedResult:@[@"three", @"four"]];
}

- (void)testConstants
{
    [self _testExpression:@"π" withObject:nil expectedResult:@(M_PI)];
    [self _testExpression:@"pi" withObject:nil expectedResult:@(M_PI)];
    [self _testExpression:@"e" withObject:nil expectedResult:@(M_E)];
    
    NSMutableSet *testSet = [NSMutableSet set];
    AJRConstant *pi = [AJRConstant constantForToken:@"π"];
    AJRConstant *e = [AJRConstant constantForToken:@"e"];
    
    [testSet addObject:pi];
    [testSet addObject:e];
    XCTAssert([testSet count] == 2);
    XCTAssert([testSet containsObject:pi]);
    XCTAssert([testSet containsObject:e]);
    
    NSMutableDictionary *testDictionary = [NSMutableDictionary dictionary];
    [testDictionary setObject:@(M_PI) forKey:pi];
    [testDictionary setObject:@(M_E) forKey:e];
    XCTAssert([testDictionary count] == 2);
    XCTAssert([[testDictionary objectForKey:pi] doubleValue] == M_PI);
    XCTAssert([[testDictionary objectForKey:e] doubleValue] == M_E);
}

- (void)testMathFunctions
{
    [self _testExpression:@"sqrt(16)" withObject:nil expectedResult:@(sqrt(16))];
    [self _testExpression:@"sqrt(sqrt(16))" withObject:nil expectedResult:@(sqrt(sqrt(16)))];
    [self _testExpression:@"sqrt(sqrt(4*4))" withObject:nil expectedResult:@(sqrt(sqrt(4*4)))];
    [self _testExpression:@"ceiling(π)" withObject:nil expectedResult:@(ceil(M_PI))];
    [self _testExpression:@"floor(π)" withObject:nil expectedResult:@(floor(M_PI))];
    [self _testExpression:@"round(π)" withObject:nil expectedResult:@(round(M_PI))];
    [self _testExpression:@"remainder(10, 4)" withObject:nil expectedResult:@(10 % 4)];
    [self _testExpression:@"min(1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"min(6,2,3,1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"max(1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"max(6,2,3,1)" withObject:nil expectedResult:@(6)];
    [self _testExpression:@"max(4,6,2,3,1)" withObject:nil expectedResult:@(6)];
    [self _testExpression:@"abs(1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"abs(-1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"abs(1.5)" withObject:nil expectedResult:@(1.5)];
    [self _testExpression:@"abs(-1.5)" withObject:nil expectedResult:@(1.5)];
    [self _testExpression:@"log(10)" withObject:nil expectedResult:@(log10(10))];
    [self _testExpression:@"log(50)" withObject:nil expectedResult:@(log10(50))];
    [self _testExpression:@"log(100)" withObject:nil expectedResult:@(log10(100))];
    [self _testExpression:@"ln(e)" withObject:nil expectedResult:@(log(M_E))];
    [self _testExpression:@"ln(e*1.5)" withObject:nil expectedResult:@(log(M_E * 1.5))];
    [self _testExpression:@"ln(e*2)" withObject:nil expectedResult:@(log(M_E * 2.0))];
}

- (void)testTrigFunctions
{
    [self _testExpression:@"sin(0)" withObject:nil expectedResult:@(sin(0))];
    [self _testExpression:@"sin(π*0.5)" withObject:nil expectedResult:@(sin(M_PI*0.5))];
    [self _testExpression:@"sin(π*1.0)" withObject:nil expectedResult:@(sin(M_PI*1.0))];
    [self _testExpression:@"sin(π*1.5)" withObject:nil expectedResult:@(sin(M_PI*1.5))];
    [self _testExpression:@"sin(2*π)" withObject:nil expectedResult:@(sin(2*M_PI))];
    [self _testExpression:@"sin(\"bogus\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"sin(1.0, 2.0)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"cos(0)" withObject:nil expectedResult:@(cos(0))];
    [self _testExpression:@"cos(π*0.5)" withObject:nil expectedResult:@(cos(M_PI*0.5))];
    [self _testExpression:@"cos(π*1.0)" withObject:nil expectedResult:@(cos(M_PI*1.0))];
    [self _testExpression:@"cos(π*1.5)" withObject:nil expectedResult:@(cos(M_PI*1.5))];
    [self _testExpression:@"cos(2*π)" withObject:nil expectedResult:@(cos(2*M_PI))];
    [self _testExpression:@"cos(\"bogus\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"cos(2,π)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"tan(0)" withObject:nil expectedResult:@(tan(0))];
    [self _testExpression:@"tan(π*0.5)" withObject:nil expectedResult:@(tan(M_PI*0.5))];
    [self _testExpression:@"tan(π*1.0)" withObject:nil expectedResult:@(tan(M_PI*1.0))];
    [self _testExpression:@"tan(π*1.5)" withObject:nil expectedResult:@(tan(M_PI*1.5))];
    [self _testExpression:@"tan(2*π)" withObject:nil expectedResult:@(tan(2*M_PI))];
    [self _testExpression:@"tan(\"bogus\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"tan(2,π)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arcsin(0)" withObject:nil expectedResult:@(sin(0))];
    [self _testExpression:@"arcsin(\"bogus\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arcsin(2,π)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arccos(0)" withObject:nil expectedResult:@(acos(0))];
    [self _testExpression:@"arccos(\"bogus\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arccos(2,π)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arctan(0)" withObject:nil expectedResult:@(atan(0))];
    [self _testExpression:@"arctan(\"bogus\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arctan(0,0)" withObject:nil expectedResult:@(atan2(0.0, 0.0))];
    [self _testExpression:@"arctan(0,0,0)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"arctan(0,\"bogus\",0)" withObject:nil expectedResult:nil expectError:YES];
}

- (void)testLogicFunctions
{
    [self _testExpression:@"if(true, \"a\")" withObject:nil expectedResult:@"a"];
    [self _testExpression:@"if(false, \"a\")" withObject:nil expectedResult:nil];
    [self _testExpression:@"ifelse(true, \"a\", \"b\")" withObject:nil expectedResult:@"a"];
    [self _testExpression:@"ifelse(false, \"a\", \"b\")" withObject:nil expectedResult:@"b"];
}

- (void)testCollectionFunctions
{                                    
    [self _testExpression:@"contains(array(1, 2, 3), 1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"contains(array(1, 2, 3), 4)" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"contains(array(1, 2, 3), 1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"count(array(1, 2, 3))" withObject:nil expectedResult:@(3)];
    [self _testExpression:@"contains(set(1, 2, 3), 1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"contains(set(1, 2, 3), 4)" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"contains(set(1, 2, 3), 1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"count(set(1, 2, 3, 4, 5, 6, 7))" withObject:nil expectedResult:@(7)];
    [self _testExpression:@"contains(dictionary(\"one\", 1, \"two\", 2, \"three\", 3), 1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"contains(dictionary(\"one\", 1, \"two\", 2, \"three\", 3), 4)" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"contains(dictionary(\"one\", 1, \"two\", 2, \"three\", 3), 1)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"count(dictionary(\"one\", 1, \"two\", 2, \"three\", 3))" withObject:nil expectedResult:@(3)];
    [self _testExpression:@"array(1, 2, 3)=array(1, 2, 3)" withObject:nil expectedResult:@(1)];
    [self _testExpression:@"array(1, 2, 3)=array(1, 2, 3, 4)" withObject:nil expectedResult:@(0)];
    [self _testExpression:@"iterate(array(1, 2, 3, 4), sqrt())" withObject:nil expectedResult:@[@(sqrt(1)), @(sqrt(2)), @(sqrt(3)), @(sqrt(4))]];
    [self _testExpression:@"iterate(set(1, 2, 3, 4), sqrt())" withObject:nil expectedResult:[NSSet setWithArray:@[@(sqrt(1)), @(sqrt(2)), @(sqrt(3)), @(sqrt(4))]]];
    [self _testExpression:@"iterate(set(\"a\", \"b\", \"c\", \"d\"), sin())" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"iterate(dictionary(\"one\", 1, \"two\", 2, \"three\", 3, \"four\", 4), sqrt())" withObject:nil expectedResult:[NSSet setWithArray:@[@(sqrt(1)), @(sqrt(2)), @(sqrt(3)), @(sqrt(4))]]];
    [self _testExpression:@"array(1, a, 2)" withObject:nil expectedResult:@[@(1), [NSNull null], @(2)]]; // the 'a' forces a nil
    [self _testExpression:@"array(1, 1/0, 2)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"set(1, a, 2)" withObject:nil expectedResult:[NSSet setWithArray:@[@(1), [NSNull null], @(2)]]]; // the 'a' forces a nil
    [self _testExpression:@"set(1, 1/0, 2)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"dictionary(\"one\", 1, \"null\", a, \"two\", 2)" withObject:nil expectedResult:@{@"one":@(1), @"null":[NSNull null], @"two":@(2)}]; // the 'a' forces a nil
    [self _testExpression:@"dictionary(\"one\", 1, \"null\", 1/0, \"two\", 2)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"iterate(set(1, 2, 3, 4), π)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"iterate(array(1, 2, 3, 4), null())" withObject:nil expectedResult:@[[NSNull null], [NSNull null], [NSNull null], [NSNull null]]];
    [self _testExpression:@"contains(1, 1)" withObject:nil expectedResult:@(1)];
    
    // Union
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) union dictionary(\"four\", 4, \"five\", 5, \"six\", 6)" withObject:nil expectedResult:@{@"one":@(1), @"two":@(2), @"three":@(3), @"four":@(4), @"five":@(5), @"six":@(6)}];
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) union set(4, 5, 6)" withObject:nil expectedResult:[NSSet setWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6)]]];
    [self _testExpression:@"set(4, 5, 6) union dictionary(\"one\", 1, \"two\", 2, \"three\", 3)" withObject:nil expectedResult:[NSSet setWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6)]]];
    
    // Intersection
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) intersect dictionary(\"three\", 3, \"four\", 4, \"five\", 5)" withObject:nil expectedResult:@{@"three":@(3)}];
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) intersect set(3, 4, 5)" withObject:nil expectedResult:[NSSet setWithArray:@[@(3)]]];
    [self _testExpression:@"set(3, 4, 5) intersect dictionary(\"one\", 1, \"two\", 2, \"three\", 3)" withObject:nil expectedResult:[NSSet setWithArray:@[@(3)]]];
}

- (void)testRandomAdvancedStuff
{
    NSDictionary    *object = @{@"one":@(1),
                                @"value":@"mom",
    };
    
    [self _testExpression:@"ifelse(value = \"mom\", \"you bet\", \"not a chance\")" withObject:object expectedResult:@"you bet"];
    [self _testExpression:@"ifelse(value = \"dad\", \"you bet\", \"not a chance\")" withObject:object expectedResult:@"not a chance"];
}

- (void)testErrorExpressions
{
    [self _testExpression:@"1 + a a" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"(1 + 1) (2 + 2)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"1 +" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"sqrt(2*)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"(1 + 1" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"(1 + 1))" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"bogus()" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"1.1." withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"contains(array(1, 2, 3), 1, 2)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"ajr_arg_count_checker(1)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"ajr_arg_count_checker(1, 2)" withObject:nil expectedResult:nil expectError:NO];
    [self _testExpression:@"ajr_arg_count_checker(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"ajr_arg_count_checker(\"one\", \"two\")" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"min()" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"help(π)" withObject:nil expectedResult:nil expectError:YES];
    [self _testExpression:@"1 * * 1" withObject:nil expectedResult:nil expectError:YES];
    
    BOOL threwException = NO;
    @try {
        [self _testExpression:@"ajr_broken()" withObject:nil expectedResult:nil expectError:YES];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRBrokenFunction evaluateWithObject:error:] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"ajr_broken didn't fail.");
    
    threwException = NO;
    @try {
        [self _testExpression:@"min(ajr_broken_constant)" withObject:nil expectedResult:nil expectError:YES];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRBrokenConstant value] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"ajr_broken didn't fail.");
    
    threwException = NO;
    @try {
        AJRExpression *expression = [[AJRExpression alloc] init];
        [expression evaluateWithObject:nil error:NULL];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRExpression evaluateWithObject:error:] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"-[AJRExpression evaluateWithObject:error:] didn't fail.");
    
    threwException = NO;
    @try {
        AJRExpression *expression = [[AJRExpression alloc] init];
        [expression hash];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRExpression hash] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"-[AJRExpression hash] didn't fail.");
    
    threwException = NO;
    @try {
        [self _testExpression:@"1 ajr_broken_operator 2" withObject:nil expectedResult:nil expectError:YES];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRBrokenOperator performOperatorWithLeft:andRight:error:] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"ajr_broken_operator didn't fail.");
    
    threwException = NO;
    @try {
        [self _testExpression:@"ajr_broken_unary 2" withObject:nil expectedResult:nil expectError:YES];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRBrokenUnaryOperator performOperatorWithValue:error:] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"ajr_broken_unary didn't fail.");
    
    threwException = NO;
    @try {
        [[AJROperator operatorForToken:@"ajr_broken_unary"] precedence];
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"Abstract method -[AJRBrokenUnaryOperator precedence] should be implemented"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"ajr_broken_unary didn't fail.");
    
    threwException = NO;
    @try {
        AJRStringFromExpressionTokenType(UINT8_MAX);
    } @catch(NSException *localException) {
        XCTAssert([[localException description] hasSuffix:@"We reached code we shouldn't have reached in AJRStringFromExpressionTokenType: Invalid AJRExpressionTokenType: 255"]);
        threwException = YES;
    }
    XCTAssert(threwException, @"-[AJRExpression evaluateWithObject:error:] didn't fail.");
}

- (void)testExpressionStackFrameEdgeCases
{
    NSException *exception = nil;
    AJRExpressionStackFrame *stackFrame = [[AJRExpressionStackFrame alloc] init];
    
    [stackFrame addToken:[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator value:[AJROperator operatorForToken:@"+"]]];
    @try {
        [stackFrame expression];
    } @catch (NSException *localException) {
        exception = localException;
    }
    XCTAssert(exception != nil);
    
    stackFrame = [[AJRExpressionStackFrame alloc] init];
    @try {
        [stackFrame addToken:[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOpenParen]];
    } @catch (NSException *localException) {
        exception = localException;
    }
    XCTAssert(exception != nil);
}

- (void)testExpressionParser
{
    NSException *exception = nil;
    
    AJRExpression *expression = [AJRExpressionParser expressionForStringFormat:@"%s = %@ or \"int\" = %d or \"float\" = %f", "test", @"test", 1, M_PI];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(((((test == test) || int) == 1) || float) == 3.141592653589793)"]);
    
    expression = [AJRExpressionParser expressionForString:@"test = test"];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(test == test)"]);
    
    expression = [AJRExpressionParser expressionForStringFormat:@"%s = %s", "test", nil];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(test == (null))"]);
    
    expression = [AJRExpressionParser expressionForStringFormat:@"%s = %@", "test", @(1)];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(test == 1)"]);
    
    exception = nil;
    @try {
        expression = [AJRExpressionParser expressionForStringFormat:@"%s = %", "test", @"test"];
    } @catch (NSException *localException) {
        exception = localException;
    }
    XCTAssert(exception != nil);
    
    expression = [AJRExpressionParser expressionForString:@"\"\\t\\n\\\\\\'\\\"\\r\\e\\q\\s\""];
    XCTAssert(expression != nil && [[expression evaluateWithObject:nil error:NULL] isEqualToString:@"\t\n\\\'\"\r\e? "]);
    
    expression = [AJRExpressionParser expressionForString:@"\"This is an...\\"];
    XCTAssert(expression != nil && [[expression evaluateWithObject:nil error:NULL] isEqualToString:@"This is an..."]);
    
    expression = [AJRExpressionParser expressionForString:@"\"This is a long string to force reallocation while reading a string constant.\""];
    XCTAssert(expression != nil && [[expression evaluateWithObject:nil error:NULL] isEqualToString:@"This is a long string to force reallocation while reading a string constant."]);
    
    expression = [[[AJRExpressionParser alloc] initWithStringFormat:@"%s = %@", "test", @"test"] expression];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(test == test)"]);
}

- (void)testExpressionConstructors
{
    AJRExpression *expression;
    NSError *localError = nil;
    
    //    NSLog(@"switch (encoding[0]) {");
    //    NSLog(@"    case '%s': result = [NSNumber numberWithChar:[value charValue]]; break;\n", @encode(char));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithUnsignedChar:[value unsignedCharValue]]; break;\n", @encode(unsigned char));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithShort:[value shortValue]]; break;\n", @encode(short));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithUnsignedShort:[value unsignedShortValue]]; break;\n", @encode(unsigned short));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithInt:[value intValue]]; break;\n", @encode(int));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithUnsignedInt:[value unsignedIntValue]]; break;\n", @encode(unsigned int));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithLong:[value longValue]]; break;\n", @encode(long));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithUnsignedLong:[value unsignedLongVBalue]; break;\n", @encode(unsigned long));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithLongLong:[value longLongValue]]; break;\n", @encode(long long));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithUnsignedLongLong:[value unsignedLongLongValue]]; break;\n", @encode(unsigned long long));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithFloat:[value floatValue]]; break;\n", @encode(float));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithDouble:[value doubleValue]]; break;\n", @encode(double));
    //    NSLog(@"    case '%s': result = [NSNumber numberWithLongDouble:[value longDoubleValue]]; break;\n", @encode(long double));
    //    NSLog(@"    default:\n");
    //    NSLog(@"       // Punt;\n");
    //    NSLog(@"       result = [NSNumber numberWithDouble:[value doubleValue]];\n");
    //    NSLog(@"       break;\n");
    //    NSLog(@"}\n");
    
    expression = [AJRExpression expressionWithExpressionFormat:@"%s = %f", "pi", 1.0];
    AJRExpression *decoded = [AJRExpression expressionForObject:[expression propertyListValue] error:NULL];
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRExpression expressionForObject:@"pi = 1.0" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRSimpleExpression expressionWithLeft:[AJRConstant constantForToken:@"π"] operator:[AJROperator operatorForToken:@"="] right:@(1.0)];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRExpression expressionWithString:@"5" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    decoded = [AJRExpression expressionForObject:[expression propertyListValue] error:NULL];
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRExpression expressionWithString:@"a" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    decoded = [AJRExpression expressionForObject:[expression propertyListValue] error:NULL];
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRExpression expressionWithString:@"!true" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    decoded = [AJRExpression expressionForObject:[expression propertyListValue] error:NULL];
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRExpression expressionWithString:@"min(1, 2, max(3, 4))" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    decoded = [AJRExpression expressionForObject:[expression propertyListValue] error:NULL];
    XCTAssert(AJREqual(expression, decoded));
    
    NSString *raw = @"{"
    @"    function = {"
    @"        arguments = ("
    @"             {"
    @"                 protected = 0;"
    @"                 type = AJRConstantExpression;"
    @"                 value = {"
    @"                     encoding = I;"
    @"                     type = NSNumber;"
    @"                     value = 1;"
    @"                 };"
    @"             }"
    @"        );"
    @"        type = AJRThisAintGunnaWorkFunction;"
    @"    };"
    @"    protected = 1;"
    @"    type = AJRFunctionExpression;"
    @"}";
    NSDictionary *rawDictionary = [raw propertyList];
    decoded = [AJRExpression expressionForObject:rawDictionary error:&localError];
    XCTAssert(decoded == nil);
    XCTAssert([[localError localizedDescription] isEqualToString:@"No known function class: AJRThisAintGunnaWorkFunction"]);
    
    raw = @"{"
    @"    function = {"
    @"        arguments = ("
    @"             {"
    @"                 protected = 0;"
    @"                 type = AJRConstantExpression;"
    @"                 value = {"
    @"                     encoding = Z;"
    @"                     type = NSNumber;"
    @"                     value = 1;"
    @"                 };"
    @"             }"
    @"        );"
    @"        type = AJRSinFunction;"
    @"    };"
    @"    protected = 1;"
    @"    type = AJRFunctionExpression;"
    @"}";
    rawDictionary = [raw propertyList];
    decoded = [AJRExpression expressionForObject:rawDictionary error:&localError];
    XCTAssert(decoded == nil);
    XCTAssert([[localError localizedDescription] isEqualToString:@"Unknown number encoding: Z"]);
}

- (void)testTokens
{
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeComma] description] rangeOfString:@"Comma"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber] description] rangeOfString:@"Number"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeString] description] rangeOfString:@"String"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOpenParen] description] rangeOfString:@"OpenParen"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeCloseParen] description] rangeOfString:@"CloseParen"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeLiteral] description] rangeOfString:@"Literal"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeFunction] description] rangeOfString:@"Function"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator] description] rangeOfString:@"Operator"].location != NSNotFound);
}

- (void)testCoding
{
    AJRExpression *expression = [AJRExpression expressionWithString:@"sin(π)" error:NULL];
    AJRExpression *decodedExpression = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    
    XCTAssert([expression isEqual:decodedExpression], @"%@ wasn't equal to %@", expression, decodedExpression);
}

- (void)testPropertyListEncoding
{
    NSArray *numbers = @[
        [NSNumber numberWithChar:CHAR_MAX],
        [NSNumber numberWithUnsignedChar:UCHAR_MAX],
        [NSNumber numberWithShort:SHRT_MAX],
        [NSNumber numberWithUnsignedShort:USHRT_MAX],
        [NSNumber numberWithInt:INT_MAX],
        [NSNumber numberWithUnsignedInt:UINT_MAX],
        [NSNumber numberWithLongLong:LLONG_MAX],
        [NSNumber numberWithUnsignedLongLong:ULLONG_MAX],
        [NSNumber numberWithFloat:FLT_MAX],
        [NSNumber numberWithDouble:DBL_MAX],
    ];
    
    for (NSNumber *number in numbers) {
        NSDictionary *propertyList = [number propertyListValue];
        XCTAssert(propertyList != nil);
        NSNumber *decoded = [[NSNumber alloc] initWithPropertyListValue:propertyList error:NULL];
        XCTAssert(AJREqual(number, decoded), @"%@ != %@", number, decoded);
    }
    
    NSString *original = @"This is a test";
    NSString *decoded = [[NSString alloc] initWithPropertyListValue:[original propertyListValue] error:NULL];
    XCTAssert(AJREqual(original, decoded));
    decoded = [[NSString alloc] initWithPropertyListValue:original error:NULL];
    XCTAssert(AJREqual(original, decoded));
}

- (void)testOperators
{
    NSArray<NSNumber *> *operatorPrecedences = @[@(AJROperatorPrecedenceLow),
                                                 @(AJROperatorPrecedenceMedium),
                                                 @(AJROperatorPrecedenceHigh),
                                                 @(AJROperatorPrecedenceHigher),
                                                 @(AJROperatorPrecedenceUnary)];
    
    for (NSNumber *precedence in operatorPrecedences) {
        NSString *string = AJRStringFromOperatorPrecedence([precedence integerValue]);
        AJROperatorPrecedence decoded = AJROperatorPrecedenceFromString(string);
        XCTAssert([precedence integerValue] == decoded);
    }
    
    NSError *localError;
    AJROperator *operator = [[AJROperator alloc] initWithPropertyListValue:@"ajr_cant_find_me" error:&localError];
    XCTAssert(operator == nil);
    XCTAssert(localError != nil);
    
    AJRExpression *expression = [[AJROperatorExpression alloc] initWithPropertyListValue:@{@"type":@"AJROperatorExpression", @"operator":@"ajr_cant_find_me"} error:&localError];
    XCTAssert(expression == nil);
    XCTAssert(localError != nil);
    
    BOOL hitException = NO;
    @try {
        AJRStringFromOperatorPrecedence(UINT8_MAX);
    } @catch (NSException *localException) {
        XCTAssert([[localException description] isEqualToString:@"We reached code we shouldn't have reached in AJRStringFromOperatorPrecedence: Invalid AJROperatorPrecedence: 255"]);
        hitException = YES;
    }
    XCTAssert(hitException, @"We didn't failing in AJRStringFromOperatorPrecedence() like we expected.");
}

//- (void)testComplexExpression
//{
//    NSMutableDictionary    *values;
//    
//    values = [[NSMutableDictionary alloc] init];
//    [values setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:1124], @"questionCount", [NSNumber numberWithInteger:113], @"answerCount", nil] forKey:@"current"];
//    [values setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:857], @"questionCount", [NSNumber numberWithInteger:628], @"answerCount", nil] forKey:@"previous"];
//    
//    [self _testExpression:@"current.questionCount + current.answerCount" withObject:values];
//    [self _testExpression:@"previous.questionCount + previous.answerCount" withObject:values];
//    [self _testExpression:@"(current.questionCount + current.answerCount) / (previous.questionCount + previous.answerCount)" withObject:values];
//    
//    [values release];
//}

@end
