/*
 AJRExpressionTests.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface _AJRCustomNumber : NSNumber

+ (id)ajr_numberWithLongDouble:(long double)value;

@end

@interface AJRExpressionTest : XCTestCase

@end

@implementation AJRExpressionTest

- (void)setUp {
    [super setUp];
    // We need to make sure this is running, because the operators, functions, etc. all come from plugin data.
    [AJRPlugInManager initializePlugInManager];
}

- (nullable NSString *)_testExpression:(NSString *)string withObject:(id)object expectedResult:(id)expectedValue expectError:(BOOL)expectError {
    id <AJREvaluation> expression = nil;
    NSError *localError = nil;
    
    expression = [AJRExpression expressionWithString:string error:&localError];
    
    if (localError == nil) {
        XCTAssert(expression != nil, @"Failed to parse expression: \"%@\"", string);
        
        id result = [expression evaluateWithContext:[AJREvaluationContext evaluationContextWithRootObject:object] error:&localError];
        if (result == [NSNull null]) {
            result = nil;
        }
        AJRPrintf(@"[%@]: %@ = %@\n", string, expression, result);

        XCTAssert(AJREqual(result, expectedValue), @"expression: %@, expected result: %@, got: %@", string, expectedValue, result);
    }
    
    if (expectError) {
        XCTAssert(localError != nil, @"We expected a failure in expression: \"%@\", but didn't get one.", string);
        return localError.description;
    } else {
        XCTAssert(localError == nil, @"We didn't expect a failure, but got one in expression: \"%@\": %@", string, [localError localizedDescription]);
    }

    return nil;
}

- (void)_testExpression:(NSString *)string withObject:(id)object expectedResult:(id)expectedValue {
    [self _testExpression:string withObject:object expectedResult:expectedValue expectError:NO];
}

- (void)testBasicExpressions {
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
    [self _testExpression:@"null" withObject:nil expectedResult:nil];
    [self _testExpression:@"nil" withObject:nil expectedResult:nil];
    [self _testExpression:@"isnull(null)" withObject:nil expectedResult:@YES];
    [self _testExpression:@"isnull(\"a\")" withObject:nil expectedResult:@NO];
    [self _testExpression:@"5 + 5 * 5 + 5" withObject:nil expectedResult:@(35)];
    [self _testExpression:@"5 + 5^2 + 5" withObject:nil expectedResult:@(35)];
    [self _testExpression:@"5.0 + 5.0^2.0 + 5.0" withObject:nil expectedResult:@(35.0)];
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
    [self _testExpression:@"1.5 👁 1" withObject:nil expectedResult:@(2.5)];
    [self _testExpression:@"1 👁 1.5" withObject:nil expectedResult:@(2.5)];
    [self _testExpression:@"++& + 1" withObject:@{@"++&":@(1)} expectedResult:@(2)];
    [self _testExpression:@"ifelse(nil, 'one', 'two')" withObject:nil expectedResult:@"two"];
}


- (void)testObjectExpressions {
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

- (void)testSetOperations {
    NSDictionary    *dictionary;
    
    dictionary = @{
        @"array1":@[@"one", @"two", @"three", @"four"],
        @"array2":@[@"three", @"four", @"five", @"six"],
    };
    
    [self _testExpression:@"array1 union array2" withObject:dictionary expectedResult:@[@"one", @"two", @"three", @"four", @"five", @"six"]];
    [self _testExpression:@"array1 ∪ array2" withObject:dictionary expectedResult:@[@"one", @"two", @"three", @"four", @"five", @"six"]];
    [self _testExpression:@"array1 intersect array2" withObject:dictionary expectedResult:@[@"three", @"four"]];
    [self _testExpression:@"array1 ∩ array2" withObject:dictionary expectedResult:@[@"three", @"four"]];
    [self _testExpression:@"array1 - array2" withObject:dictionary expectedResult:@[@"one", @"two"]];
    [self _testExpression:@"array1 xor array2" withObject:dictionary expectedResult:@[@"one", @"two", @"five", @"six"]];
}

- (void)testConstants {
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

- (void)testMathFunctions {
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

- (void)testTrigFunctions {
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

- (void)testLogicFunctions {
    [self _testExpression:@"if(true, \"a\")" withObject:nil expectedResult:@"a"];
    [self _testExpression:@"if(false, \"a\")" withObject:nil expectedResult:nil];
    [self _testExpression:@"ifelse(true, \"a\", \"b\")" withObject:nil expectedResult:@"a"];
    [self _testExpression:@"ifelse(false, \"a\", \"b\")" withObject:nil expectedResult:@"b"];
}

- (void)testCollectionFunctions {
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
    [self _testExpression:@"contains(1, 1)" withObject:nil expectedResult:@(1)];
    
    // Union
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) union dictionary(\"four\", 4, \"five\", 5, \"six\", 6)" withObject:nil expectedResult:@{@"one":@(1), @"two":@(2), @"three":@(3), @"four":@(4), @"five":@(5), @"six":@(6)}];
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) union set(4, 5, 6)" withObject:nil expectedResult:[NSSet setWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6)]]];
    [self _testExpression:@"set(4, 5, 6) union dictionary(\"one\", 1, \"two\", 2, \"three\", 3)" withObject:nil expectedResult:[NSSet setWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6)]]];
    
    // Intersection
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) intersect dictionary(\"three\", 3, \"four\", 4, \"five\", 5)" withObject:nil expectedResult:@{@"three":@(3)}];
    [self _testExpression:@"dictionary(\"one\", 1, \"two\", 2, \"three\", 3) intersect set(3, 4, 5)" withObject:nil expectedResult:[NSSet setWithArray:@[@(3)]]];
    [self _testExpression:@"set(3, 4, 5) intersect dictionary(\"one\", 1, \"two\", 2, \"three\", 3)" withObject:nil expectedResult:[NSSet setWithArray:@[@(3)]]];

    // Functional Language Support
    [self _testExpression:@"first(array(1, 2, 3, 4))" withObject:nil expectedResult:@1];
    [self _testExpression:@"rest(array(1, 2, 3, 4))" withObject:nil expectedResult:@[@2, @3, @4]];
}

- (void)testRandomAdvancedStuff {
    NSDictionary    *object = @{@"one":@(1),
                                @"value":@"mom",
    };
    
    [self _testExpression:@"ifelse(value = \"mom\", \"you bet\", \"not a chance\")" withObject:object expectedResult:@"you bet"];
    [self _testExpression:@"ifelse(value = \"dad\", \"you bet\", \"not a chance\")" withObject:object expectedResult:@"not a chance"];
}

- (void)testErrorExpressions {
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
    
    NSString *error = [self _testExpression:@"ajr_broken()" withObject:nil expectedResult:nil expectError:YES];
    XCTAssert(error != nil && [error containsString:@"AJRFoundation.AJRFunctionError.unimplementedAbstract(\"Abstract method AJRBrokenFunction.evaluate(with:) should be implemented\")"]);

    NSError *localError = nil;
    AJRExpression *expression = [[AJRExpression alloc] init];
    AJRPrintf(@"%@", [expression evaluateWithContext:[AJREvaluationContext evaluationContext] error:&localError]);
    XCTAssert([localError.description containsString:@"Abstract method AJRExpression.evaluate(with:) should be implemented"]);

    error = [self _testExpression:@"1 ajr_broken_operator 2" withObject:nil expectedResult:nil expectError:YES];
    XCTAssert(error != nil && [error containsString:@"Abstract method AJRBrokenOperator.performOperator(left:right:context:) should be implemented"]);

    error = [self _testExpression:@"ajr_broken_unary 2" withObject:nil expectedResult:nil expectError:YES];
    XCTAssert(error != nil && [error containsString:@"Abstract method AJRBrokenUnaryOperator.performOperator(value:context:) should be implemented"]);
}

- (void)testExpressionStackFrameEdgeCases {
    NSError *localError = nil;
    AJRExpressionStackFrame *stackFrame = [[AJRExpressionStackFrame alloc] init];
    
    [stackFrame addToken:[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator value:[AJROperator operatorForToken:@"+"]] error:NULL];
    id <AJREvaluation> expression = [stackFrame expressionWithError:&localError];
    XCTAssert(expression == nil && localError != nil);

    localError = nil;
    stackFrame = [[AJRExpressionStackFrame alloc] init];
    [stackFrame addToken:[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOpenParen] error:&localError];
    XCTAssert(localError != nil);
}

- (void)testExpressionParser {
    NSError *localError = nil;

    id <AJREvaluation> expression = [AJRExpressionParser expressionWithFormat:@"%s = %@ or \"int\" = %d or \"float\" = %f" arguments: @[@"test", @"test", @1, @(M_PI)] error: NULL];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(((\"test\" == \"test\") || (\"int\" == 1)) || (\"float\" == 3.141592653589793))"]);
    
    expression = [AJRExpressionParser expressionForString:@"test = test" error:NULL];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(test == test)"]);

    expression = [AJRExpressionParser expressionWithFormat:@"%s = %s" arguments:@[@"test", [NSNull null]] error:&localError];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(\"test\" == nil)"], @"Error encounted: %@", localError);
    
    expression = [AJRExpressionParser expressionWithFormat:@"%s = %@" arguments: @[@"test", @1] error:&localError];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(\"test\" == 1)"], @"Error encounted: %@", localError);
    
    localError = nil;
    expression = [AJRExpressionParser expressionWithFormat:@"%s = %" arguments: @[@"test", @"test"] error: &localError];
    XCTAssert(localError != nil);
    
    expression = [AJRExpressionParser expressionForString:@"\"\\t\\n\\\\\\'\\\"\\r\\e\\q\\s\"" error:NULL];
    XCTAssert(expression != nil && [[expression evaluateWithContext:[AJREvaluationContext evaluationContext] error:NULL] isEqualToString:@"\t\n\\\'\"\r\e? "]);
    
    expression = [AJRExpressionParser expressionForString:@"\"This is an...\\" error:NULL];
    XCTAssert(expression != nil && [[expression evaluateWithContext:[AJREvaluationContext evaluationContext] error:NULL] isEqualToString:@"This is an..."]);
    
    expression = [AJRExpressionParser expressionForString:@"\"This is a long string to force reallocation while reading a string constant.\"" error:NULL];
    XCTAssert(expression != nil && [[expression evaluateWithContext:[AJREvaluationContext evaluationContext] error:NULL] isEqualToString:@"This is a long string to force reallocation while reading a string constant."]);
    
    expression = [[[AJRExpressionParser alloc] initWithFormat:@"%s = %@" arguments:@[@"test", @"test"] error:NULL] expressionWithError:NULL];
    XCTAssert(expression != nil && [[expression description] isEqualToString:@"(\"test\" == \"test\")"]);
}

- (void)testExpressionConstructors {
    id <AJREvaluation> expression;
    id <AJREvaluation> decoded;
    
    expression = [AJRExpression expressionWithString:@"pi = 1.0" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRSimpleExpression expressionWithLeft:[AJRLiteral literalWithName:@"π"] operator:[AJROperator operatorForToken:@"="] right:@(1.0)];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
    
    expression = [AJRExpression expressionWithString:@"5" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));

    expression = [AJRExpression expressionWithString:@"a" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));

    expression = [AJRExpression expressionWithString:@"!true" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));

    expression = [AJRExpression expressionWithString:@"min(1, 2, max(3, 4))" error:NULL];
    decoded = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    XCTAssert(AJREqual(expression, decoded));
}

- (void)testTokens {
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeComma] description] rangeOfString:@"comma"].location != NSNotFound, @"Didn't get expected value: %@", [[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeComma] description]);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeNumber] description] rangeOfString:@"number"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeString] description] rangeOfString:@"string"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOpenParen] description] rangeOfString:@"openParen"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeCloseParen] description] rangeOfString:@"closeParen"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeLiteral] description] rangeOfString:@"literal"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeFunction] description] rangeOfString:@"function"].location != NSNotFound);
    XCTAssert([[[AJRExpressionToken tokenWithType:AJRExpressionTokenTypeOperator] description] rangeOfString:@"operator"].location != NSNotFound);
}

- (void)testCoding {
    id <AJREvaluation> expression = [AJRExpression expressionWithString:@"sin(π)" error:NULL];
    id <AJREvaluation> decodedExpression = (AJRExpression *)AJRCopyCodableObject(expression, Nil);
    
    XCTAssert(AJREqual(expression, decodedExpression), @"%@ wasn't equal to %@", expression, decodedExpression);

    // TODO: We need to really expand the XML archiving tests. I doubt we're getting anywhere near to 100%

    NSError *localError = nil;
    NSData *data = [AJRXMLArchiver archivedDataWithRootObject:expression];
    decodedExpression = [AJRXMLUnarchiver unarchivedObjectWithData:data error:&localError];

    XCTAssert(localError == nil, @"We didn't expect an error, but we got one.");
    XCTAssert(AJREqual(expression, decodedExpression), @"%@ wasn't equal to %@", expression, decodedExpression);
}

- (void)testOperators {
    NSArray<NSNumber *> *operatorPrecedences = @[@(AJROperatorPrecedencePostfix),
                                                 @(AJROperatorPrecedenceUnary),
                                                 @(AJROperatorPrecedenceMultiplicative),
                                                 @(AJROperatorPrecedenceAdditive),
                                                 @(AJROperatorPrecedenceShift),
                                                 @(AJROperatorPrecedenceRelational),
                                                 @(AJROperatorPrecedenceEquality),
                                                 @(AJROperatorPrecedenceBitAnd),
                                                 @(AJROperatorPrecedenceBitXor),
                                                 @(AJROperatorPrecedenceBitOr),
                                                 @(AJROperatorPrecedenceLogicalAnd),
                                                 @(AJROperatorPrecedenceLogicalXor),
                                                 @(AJROperatorPrecedenceLogicalOr),
                                                 @(AJROperatorPrecedenceConditional)];
    
    for (NSNumber *precedence in operatorPrecedences) {
        NSString *string = AJRStringFromOperatorPrecedence([precedence integerValue]);
        AJROperatorPrecedence decoded = AJROperatorPrecedenceFromString(string);
        XCTAssert([precedence integerValue] == decoded);
    }
    
//    NSError *localError;
//    AJROperator *operator = [[AJROperator alloc] initWithPropertyListValue:@"ajr_cant_find_me" error:&localError];
//    XCTAssert(operator == nil);
//    XCTAssert(localError != nil);
    
//    AJRExpression *expression = [[AJROperatorExpression alloc] initWithPropertyListValue:@{@"type":@"AJROperatorExpression", @"operator":@"ajr_cant_find_me"} error:&localError];
//    XCTAssert(expression == nil);
//    XCTAssert(localError != nil);
    
    NSString *result = AJRStringFromOperatorPrecedence(UINT8_MAX);
    XCTAssert(result == nil); // We'll never actually reach this
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
