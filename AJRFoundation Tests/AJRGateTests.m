
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRGateTests : XCTestCase

@end

@implementation AJRGateTests

- (void)testObjCOnlyMethods {
    // These methods aren't exposed to Swift
    
    XCTAssert([AJRGate gate] != nil);
}

@end
