
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>
#import <AJRFoundation/AJRHostP.h>

@interface AJRHostTest : XCTestCase

@end

@implementation AJRHostTest

- (void)setUp {
    [super setUp];
    AJRLogSetLogLevel(AJRLogLevelDebug, @"AJRHost");
}

- (void)testLocalhost {
    AJRHost *host = [AJRHost currentHost];
    
    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testRaftis {
    AJRHost *host = [AJRHost hostWithName:@"www.raftis.net"];
    
    XCTAssert([[host address] isEqualToString:@"64.71.176.58"]);
    XCTAssert([[host addresses] count] == 1);
    XCTAssert([[host name] isEqualToString:@"www.raftis.net"]);
    XCTAssert([[host localizedName] isEqualToString:@"www.raftis.net"]);
    XCTAssert([[host names] count] == 2);

    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testByAddress {
    AJRHost *host = [AJRHost hostWithAddress:@"64.71.176.58"];
    
    XCTAssert([[host address] isEqualToString:@"64.71.176.58"]);
    XCTAssert([[host addresses] count] == 1);
    XCTAssert([[host name] isEqualToString:@"morgana.punk.net"]);
    XCTAssert([[host localizedName] isEqualToString:@"morgana.punk.net"]);
    XCTAssert([[host names] count] == 1);
    
    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testLocalhostFromCache {
    AJRHost *host = [AJRHost currentHost];
    
    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testRaftisFromCache {
    AJRHost *host = [AJRHost hostWithName:@"www.raftis.net"];
    
    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testByAddressFromCache {
    AJRHost *host = [AJRHost hostWithAddress:@"64.71.176.58"];
    
    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testEquality {
    AJRHost *left = [AJRHost hostWithName:@"www.raftis.net"];
    AJRHost *right = [AJRHost hostWithName:@"raftis.net"];
    
    XCTAssert([left isEqual:right], @"%@ didn't equal %@", left, right);
    XCTAssert(![left isEqual:@"not a host"], @"%@ shouldn't have equaled \"not a host\".", left);
}

- (void)testNonBlockingResolutionByName {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testNonBlockingResolutionByName"];
    
    AJRResolveHostByName(NO, @"www.apple.com", ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error == nil);
        XCTAssert([names count] != 0);
        XCTAssert([addresses count] != 0);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)testNonBlockingResolutionByAddress {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testNonBlockingResolutionByName"];
    
    AJRResolveHostByAddress(NO, @"17.178.96.59", ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error == nil);
        XCTAssert([names count] != 0);
        XCTAssert([addresses count] != 0);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)testNonBlockingResolutionByLocalHost {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testNonBlockingResolutionByName"];
    
    AJRResolveLocalHost(NO, ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error == nil);
        XCTAssert([names count] != 0);
        XCTAssert([addresses count] != 0);
        [expectation fulfill];
    });
    
    [self waitForExpectations:@[expectation] timeout:10.0];
}

- (void)testByIPv6 {
    AJRHost *host = [AJRHost hostWithAddress:@"2600:1406:3f:484::1aca"];
    
    XCTAssert([host name] != nil);

    AJRPrintf(@"host: %@, addresses: %@, names: %@\n", host, [host addresses], [host names]);
}

- (void)testZ1Failures {
    AJRHostFailNameLookUpForUnitTesting = YES;
    
    [AJRHost flushHostCache];
    
    AJRHost *host = [AJRHost hostWithName:@"www.apple.com"];
    XCTAssert([host address] == nil);
    XCTAssert([[host addresses] count] == 0);

    AJRResolveHostByName(YES, @"www.apple.com", ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error != nil);
        XCTAssert(names == nil);
        XCTAssert(addresses == nil);
    });

    AJRResolveHostByName(YES, @"17.178.96.59", ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error != nil);
        XCTAssert(names == nil);
        XCTAssert(addresses == nil);
    });
    
    AJRResolveLocalHost(YES, ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error != nil);
        XCTAssert(names == nil);
        XCTAssert(addresses == nil);
    });
    
    AJRHostFailNameLookUpForUnitTesting = NO;
    AJRHostFailLocalHostNameForUnitTesting = YES;
    
    AJRResolveLocalHost(YES, ^(NSArray *names, NSArray *addresses, NSError *error) {
        // Note: We're not sure what we'll get back, just that something should come back.
        XCTAssert(error == nil);
        XCTAssert(names != nil);
        XCTAssert(addresses != nil);
    });
}

@end
