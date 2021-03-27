
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSBundle_ExtensionsTests : XCTestCase

@end

@implementation NSBundle_ExtensionsTests

- (void)testFinding {
    NSBundle *bundle;
    
    // Try by a name we're sure we'll find.
    bundle = [NSBundle bundleWithName:@"AJRFoundation"];
    XCTAssert(bundle != nil);
    XCTAssert([bundle.bundleIdentifier isEqualToString:@"com.ajr.framework.AJRFoundation"]);
    
    // Try by it's identifier. This is the fallback case.
    bundle = [NSBundle bundleWithName:@"com.ajr.framework.AJRFoundation"];
    XCTAssert(bundle != nil);

    // Find a resource
    NSString *path = [NSBundle pathForResource:@"AJRSharedStrings" ofType:@"strings"];
    XCTAssert(path != nil);
}

- (void)testMachO {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.ajr.framework.AJRFoundation"];
    NSData *data = [bundle machOTextDataNamed:@"__cstring"];
    
    XCTAssert(data != nil);
    
    data = [bundle machOTextDataNamed:@"__not_found"];
    XCTAssert(data == nil);
    
    bundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/Tcl.framework"];
    XCTAssert(bundle != nil);
    XCTAssert(!bundle.isLoaded);
    data = [bundle machODataOfType:@"__TEXT" named:@"__text"];
    XCTAssert(data != nil);
    
    // Final error case, which is a bundle with no executable.
    bundle = [NSBundle bundleWithPath:@"/System/Library/LinguisticData/RequiredAssets_en.bundle"];
    XCTAssert(bundle != nil);
    XCTAssert(!bundle.isLoaded);
    data = [bundle machODataOfType:@"__TEXT" named:@"__text"];
    XCTAssert(data == nil);
}

@end
