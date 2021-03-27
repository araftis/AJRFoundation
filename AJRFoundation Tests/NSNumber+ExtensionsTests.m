
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSNumber_ExtensionsTests : XCTestCase

@end

#define ALWAYS_NSUINTEGER @((NSUInteger)NSIntegerMax + 1)

@implementation NSNumber_ExtensionsTests

- (void)testComparingToStrings {
    XCTAssert([@(1) isEqualToString:@"1"]);
    XCTAssert([ALWAYS_NSUINTEGER isEqualToString:ALWAYS_NSUINTEGER.description]);
    XCTAssert([@(0) isEqualToString:@"0"]);
    XCTAssert(![@(1) isEqualToString:@"0"]);
    XCTAssert(![@(0) isEqualToString:@"1"]);
    XCTAssert([@(-1) isEqualToString:@"-1"]);
    XCTAssert(![@(-1) isEqualToString:@"1"]);
    XCTAssert([@(1.0) isEqualToString:@"1.0"]);
    XCTAssert([@(-1.0) isEqualToString:@"-1.0"]);
}

- (void)testPositiveAndNegative {
    XCTAssert(@(1).isPositive);
    XCTAssert(!@(-1).isPositive);
    XCTAssert(ALWAYS_NSUINTEGER.isPositive);
    XCTAssert(@(1.0).isPositive);
    XCTAssert(!@(-1.0).isPositive);
}

- (void)testCreation {
    // NOTE: This method calls through to -[NSString numberValue], so we test this more thoroughly via the NSString+ExtensionsTests.m.
    XCTAssert([[NSNumber numberFromString:@"1"] isEqualToNumber:@(1)]);
}

- (void)testRandomNumbers {
    // Just call this and hope for no crash. We can't really "test" it, because this goes through a code path that's only visited if we haven't yet called +[NSNumber seedRandomNumbersWithSeed:]. However, that means the return value will always be random :-/. After this, we'll call +[NSNumber seedRandomNumbersWithSeed:] and make sure we get back consistent values.
    AJRPrintf(@"%@\n", NSNumber.randomNumber);
    
    [NSNumber seedRandomNumbersWithSeed:61671];
    NSNumber *random = NSNumber.randomNumber;
    XCTAssert([random isEqualToNumber:@(244140405)], @"%@ wasn't equal to 244140405", random);
    
    for (NSInteger x = 0; x < 1000; x++) {
        random = [NSNumber randomNumberInRange:(NSRange){10, 10}];
        XCTAssert(random.integerValue >= 10 && random.integerValue < 20);
    }
}

@end
