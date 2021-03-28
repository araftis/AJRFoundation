/*
AJRDelegateProxyTests.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
