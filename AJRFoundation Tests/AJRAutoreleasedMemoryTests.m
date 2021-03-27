
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRAutoreleasedMemoryTests : XCTestCase

@end

@implementation AJRAutoreleasedMemoryTests

- (void)testMemory {
    @autoreleasepool {
        void *buffer1 = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:100];
        XCTAssert(buffer1 != NULL);
        void *buffer2 = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:100];
        XCTAssert(buffer2 != NULL);
        
        XCTAssert(labs((NSInteger)buffer1 - (NSInteger)buffer2) == 100);
        
        AJRAutoreleasedMemory *memory = NSThread.currentThread.threadDictionary[@"AJRAutoreleaseMalloc"];
        XCTAssert(memory != nil);
        
        void *buffer3 = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:1000];
        XCTAssert(buffer3 != NULL);
        
        XCTAssert(NSThread.currentThread.threadDictionary[@"AJRAutoreleaseMalloc"] == memory);
        
        void *buffer4 = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:400];
        XCTAssert(buffer4 != NULL);
        
        XCTAssert(NSThread.currentThread.threadDictionary[@"AJRAutoreleaseMalloc"] != memory);
    }
    
    XCTAssert(NSThread.currentThread.threadDictionary[@"AJRAutoreleaseMalloc"] == nil);
}

@end
