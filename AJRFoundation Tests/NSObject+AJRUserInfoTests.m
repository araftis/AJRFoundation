
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSObject_AJRUserInfoTests : XCTestCase

@end

@implementation NSObject_AJRUserInfoTests

- (void)testObject {
    NSObject *object = [[NSObject alloc] init];
    
    [object setInstanceObject:@(1) forKey:@"one"];
    [object setInstanceObject:@(2) forKey:@"two"];
    [[NSObject class] setClassObject:@"uno" forKey:@"one"];
    [[NSObject class] setClassObject:@"dos" forKey:@"two"];
    XCTAssert([[object instanceObjectForKey:@"one"] isEqualToNumber:@(1)]);
    XCTAssert([[object instanceObjectForKey:@"two"] isEqualToNumber:@(2)]);
    XCTAssert([[[NSObject class] classObjectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[[NSObject class] classObjectForKey:@"two"] isEqualToString:@"dos"]);
    [object setInstanceObject:nil forKey:@"two"];
    [[NSObject class] setClassObject:nil forKey:@"two"];
    XCTAssert([[object instanceObjectForKey:@"one"] isEqualToNumber:@(1)]);
    XCTAssert([object instanceObjectForKey:@"two"] == nil);
    XCTAssert([[[NSObject class] classObjectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[NSObject class] classObjectForKey:@"two"] == nil);
    [object clearInstanceObjects];
    XCTAssert([object instanceObjectForKey:@"one"] == nil);
    XCTAssert([object instanceObjectForKey:@"two"] == nil);
    XCTAssert([[[NSObject class] classObjectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[NSObject class] classObjectForKey:@"two"] == nil);
    [[NSObject class] clearClassObjects];
    XCTAssert([[NSObject class] classObjectForKey:@"one"] == nil);
    XCTAssert([[NSObject class] classObjectForKey:@"two"] == nil);
}

@end
