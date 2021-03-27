
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSMutableSet_ExtensionsTests : XCTestCase

@end

@implementation NSMutableSet_ExtensionsTests

- (void)testAdding {
    NSMutableSet *set = [NSMutableSet set];
    
    [set addObjectIfNotNil:@"one"];
    [set addObjectIfNotNil:nil];
    XCTAssert(set.count == 1);
    XCTAssert([set containsObject:@"one"]);
}

@end
