
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSError_ExtensionsTests : XCTestCase

@end

static NSString * const AJRTestErrorDomain = @"TestErrorDomain";

@implementation NSError_ExtensionsTests

// NOTE: These test don't do much, because most of the interesting stuff is done by AJRFormat, which is tested separately.

- (void)testErrorCreation {
    NSError *error;
    
    FILE *file = fopen("/tmp/nonexistantfile", "r");
    XCTAssert(file == nil);
    error = [NSError errorWithDomain:AJRTestErrorDomain errorNumber:errno];
    XCTAssert(error != nil);
    XCTAssert([error.localizedDescription isEqualToString:@"No such file or directory"]);
    
    error = [NSError errorWithDomain:AJRTestErrorDomain message:@"Test error"];
    XCTAssert(error != nil);
    XCTAssert([error.localizedDescription isEqualToString:@"Test error"]);

    error = [NSError errorWithDomain:AJRTestErrorDomain format:@"Test %@", @"error"];
    XCTAssert(error != nil);
    XCTAssert([error.localizedDescription isEqualToString:@"Test error"]);

    error = [NSError errorWithDomain:AJRTestErrorDomain code:0xdeaedbeef message:@"Test error"];
    XCTAssert(error != nil);
    XCTAssert([error.localizedDescription isEqualToString:@"Test error"]);
    XCTAssert(error.code == 0xdeaedbeef);

    error = [NSError errorWithDomain:AJRTestErrorDomain code:0xdeaedbeef format:@"Test %@", @"error"];
    XCTAssert(error != nil);
    XCTAssert([error.localizedDescription isEqualToString:@"Test error"]);
    XCTAssert(error.code == 0xdeaedbeef);
}

@end
