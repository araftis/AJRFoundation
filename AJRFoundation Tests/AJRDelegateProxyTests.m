//
//  AJRDelegateProxyTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 11/12/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@class AJRTestClassWithDelegate;

@protocol AJRTestClassWithDelegateProtocol <NSObject>

- (float)testClass:(AJRTestClassWithDelegate *)object didSomethingAt:(float)x and:(float)y;
@optional - (float)testClass:(AJRTestClassWithDelegate *)object willDoSomethingAt:(float)x and:(float)y;

@end

@interface AJRTestClassWithDelegate : NSObject

@property (nonatomic,weak) id<AJRTestClassWithDelegateProtocol> delegate;
@property (nonatomic,assign) float result;

@end

@implementation AJRTestClassWithDelegate

- (id)initWithDelegate:(id<AJRTestClassWithDelegateProtocol>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
    }
    return self;
}

- (void)doSomethingAt:(float)x and:(float)y {
    if ([_delegate respondsToSelector:@selector(testClass:willDoSomethingAt:and:)]) {
        _result = [_delegate testClass:self willDoSomethingAt:x and:y];
    }
    _result = [_delegate testClass:self didSomethingAt:x and:y];
    AJRLog(nil, AJRLogLevelInfo, @"result: %.3f", _result);
}

@end

@interface AJRDelegateProxyTests : XCTestCase <AJRTestClassWithDelegateProtocol>

@end

@interface AJRTestInterloper : NSObject

@property (nonatomic,assign) BOOL willDoSomething;
@property (nonatomic,assign) BOOL didSomething;

@end

@implementation AJRTestInterloper

- (float)testClass:(AJRTestClassWithDelegate *)object didSomethingAt:(float)x and:(float)y {
    _didSomething = YES;
    return x / y;
}

- (float)testClass:(AJRTestClassWithDelegate *)object willDoSomethingAt:(float)x and:(float)y {
    _willDoSomething = YES;
    return x - y;
}

@end

@implementation AJRDelegateProxyTests {
    BOOL _didSomething;
}

- (float)testClass:(AJRTestClassWithDelegate *)object didSomethingAt:(float)x and:(float)y {
    _didSomething = YES;
    return x * y;
}

- (void)testExample {
    float left = 1.0;
    float right = 2.0;
    AJRTestInterloper *interloper = [[AJRTestInterloper alloc] init];
    AJRDelegateProxy *proxy = [AJRDelegateProxy delegateProxyWithDelegate:self andInterloper:interloper];
    AJRTestClassWithDelegate *test = [[AJRTestClassWithDelegate alloc] initWithDelegate:(id <AJRTestClassWithDelegateProtocol>)proxy];
    
    _didSomething = NO;
    interloper.didSomething = NO;
    [test doSomethingAt:left and:right];
    XCTAssert(_didSomething);
    XCTAssert(interloper.didSomething);
    XCTAssert(interloper.willDoSomething);
    XCTAssert(test.result == left * right);
    XCTAssert(test.result != left / right);
    
    _didSomething = NO;
    interloper.didSomething = NO;
    interloper.willDoSomething = NO;
    proxy.returnValuesFromInterloper = YES;
    [test doSomethingAt:left and:right];
    XCTAssert(_didSomething);
    XCTAssert(interloper.didSomething);
    XCTAssert(interloper.willDoSomething);
    XCTAssert(test.result != left * right);
    XCTAssert(test.result == left / right);
}

@end
