//
//  AJRGate.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 10/8/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "AJRGate.h"

#import "AJRFormat.h"

@implementation AJRGate {
    NSCondition *_condition;
    BOOL _interrupted;
}

+ (AJRGate *)gate {
    return [[AJRGate alloc] init];
}

- (id)init {
    if ((self = [super init])) {
        _condition = [[NSCondition alloc] init];
        _waiting = 0;
        _open = NO;
        _interrupted = NO;
    }
    return self;
}

- (void)wait {
    [self waitUntilDate:[NSDate distantFuture]];
}

- (BOOL)waitForTimeInterval:(NSTimeInterval)timeInterval {
    return [self waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
}

- (BOOL)waitUntilDate:(NSDate *)date {
    [_condition lock];
    if (!_interrupted && !_open) {
        @try {
            _waiting++;
            [_condition waitUntilDate:date];
        } @catch (NSException *exception) {
            _interrupted = YES;
        } @finally {
            _waiting--;
        }
    }
    [_condition unlock];
    
    return _interrupted;
}

- (void)open {
    [_condition lock];
    _open = YES;
    [_condition broadcast];
    [_condition unlock];
}

- (BOOL)close {
    BOOL closed = NO;
    [_condition lock];
    if (!_interrupted && _open) {
        _open = NO;
        _waiting = 0;
        closed = YES;
    }
    [_condition unlock];
    
    return closed;
}

- (NSString *)description {
    return AJRFormat(@"<%C (%p): %d thread%@ waiting>", self, self, _waiting, _waiting == 1 ? @"" : @"s");
}

@end
