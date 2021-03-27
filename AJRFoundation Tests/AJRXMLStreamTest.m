
#import <XCTest/XCTest.h>

#import "AJRXMLCoder.h"
#import "AJRXMLOutputStream.h"
#import "NSArray+Extensions.h"
#import "NSOutputStream+Extensions.h"

@interface TestDocument : NSObject <AJRXMLCoding>
- (id)initWithType:(NSString *)type;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSMutableArray *pages;
@end

@interface TestPage : NSObject <AJRXMLCoding>
- (id)initWithType:(NSString *)type pageNumber:(NSInteger)pageNumber;
@property (nonatomic,weak) TestDocument *document;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,assign) NSInteger pageNumber;
@end

@implementation TestDocument

- (id)initWithType:(NSString *)type {
    if ((self = [super init])) {
        _type = type;
        _pages = [[NSMutableArray alloc] init];
        
        [_pages addObject:[[TestPage alloc] initWithType:@"master.left" pageNumber:1]];
        [(TestPage *)[_pages lastObject] setDocument:self];
        [_pages addObject:[[TestPage alloc] initWithType:@"master.right" pageNumber:2]];
        [(TestPage *)[_pages lastObject] setDocument:self];
    }
    return self;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeString:_type forKey:@"type"];
    [coder encodeObject:_pages forKey:@"pages"];
}

@end

@implementation TestPage

- (id)initWithType:(NSString *)type pageNumber:(NSInteger)pageNumber {
    if ((self = [super init])) {
        _type = type;
        _pageNumber = pageNumber;
    }
    return self;
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"page";
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    if (_document) [coder encodeObject:_document forKey:@"document"];
    [coder encodeString:_type forKey:@"type"];
    [coder encodeInteger:_pageNumber forKey:@"pageNumber"];
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
}

- (NSString *)preferredXMLName {
    return @"page";
}

@end

@interface AJRXMLStreamTest : XCTestCase <NSStreamDelegate>
@end

@implementation AJRXMLStreamTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleDocument {
    NSString *expectedResult = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               @"<document type=\"com.ajr.document\">\n"
                               @"  <page type=\"master.left\"/>\n"
                               @"  <page type=\"master.right\"/>\n"
                               @"</document>\n";
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    [output setDelegate:self];
    [output open];
    [AJRXMLOutputStream XMLDocumentStreamedInto:output scope:^(AJRXMLOutputStream *builder) {
        [builder setPrettyOutput:YES];
        [builder setEncoding:NSUTF8StringEncoding];
        [builder setVersion:@"1.0"];
        [builder push:@"document" scope:^{
            [builder addAttribute:@"type" withValue:@"com.ajr.document"];
            [builder push:@"page" scope:^{
                [builder addAttribute:@"type" withValue:@"master.left"];
            }];
            [builder push:@"page" scope:^{
                [builder addAttribute:@"type" withValue:@"master.right"];
            }];
        }];
    }];
    //[output close];
    
    NSString *string = [[NSString alloc] initWithData:[output propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[output encoding]];

    XCTAssert([string isEqualToString:expectedResult], @"expected to get document:\n%@\nbut got:\n%@\n", expectedResult, string);
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"%d", (int)streamEvent);
}

- (void)testNSOutputStream {
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    
    [stream setDelegate:self];
    [stream open];
    for (NSInteger x = 0; x < 10000; x++) {
        [stream writeCString:" "];
        [stream writeCString:""];
    }
    [stream close];

    NSString *string = [[NSString alloc] initWithData:[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[stream encoding]];
    XCTAssert([string length] == 10000, @"Expected the resulting string to be 10000 characters, but it was only %ld", (long)[string length]);
}

- (void)testEncodedSimpleDocument {
    TestDocument *document = [[TestDocument alloc] initWithType:@"com.ajr.document"];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    AJRXMLCoder *coder = [[AJRXMLCoder alloc] initWithStream:outputStream];
    
    [outputStream open];
    [coder encodeRootObject:document forKey:@"document"];
    [outputStream close];

    NSLog(@"result:\n\n%@\n\n", [[NSString alloc] initWithData:[outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:[outputStream encoding]]);
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/
@end
