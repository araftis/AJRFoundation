
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundationPrivate.h>

@interface AJRXMLCollectionPlaceholderTests : XCTestCase

@end

@implementation AJRXMLCollectionPlaceholderTests

- (void)testExample {
    // This tests the dealloc fallback which frees the object's appended to a C pointer array during decode. Normally this array is freed during dinalizeForXMLCoding, but we have to also free the objects in dealloc in the event that something went wrong with the decoding and finalizeForXMLCoding was never called.
    @autoreleasepool {
        AJRXMLCollectionPlaceholder *placeholder = [[AJRXMLCollectionPlaceholder alloc] initWithFinalClass:[NSDictionary class]];
        
        for (NSInteger x = 0; x < 200; x++) {
            [placeholder appendObject:@(x * x)];
        }
        
        // We're mostly just hoping that we don't crash in our dealloc method for AJRXMLDictionaryPlaceholder, because we didn't call finalizeForXMLCoding, which means the key/value pairs will be freed in dealloc.
    }
}

@end
