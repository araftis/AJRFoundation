//
//  AJRActivity.m
//
//  Created by A.J. Raftis on Mon Nov 18 2002.
//  Copyright (c) 2001 A.J. Raftis. All rights reserved.
//

#import "AJRActivity.h"

#import "AJRMutableOrderedDictionary.h"

#import <AJRFoundation/AJRFoundation-Swift.h>

#import <objc/runtime.h>
#import <objc/objc-auto.h>

@interface AJRActivity ()

@property (strong) NSPointerArray *delegates;
@property (assign) BOOL stopRequested;

@end

@implementation AJRActivity {
    NSMutableArray<NSString *> *_messages;
    NSString *_message;
}

static dispatch_queue_t	_activitiesQueue = NULL;
static NSRecursiveLock *_activitiesLock = nil;
static NSMutableArray<AJRActivity *> *_activities = nil;
static NSRecursiveLock *_activityObserversLock = nil;
static NSInteger _observerToken;
static AJRMutableOrderedDictionary<NSNumber *, AJRActivityObserver> *_activityObservers = nil;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		_activitiesQueue = dispatch_queue_create("com.ajr.activities", 0);
		//dispatch_set_target_queue(_activitiesQueue, dispatch_get_main_queue());
		
		_activitiesLock = [[NSRecursiveLock alloc] init];
        _activities = [[NSMutableArray alloc] init];
		_activityObserversLock = [[NSRecursiveLock alloc] init];
		_activityObservers = [AJRMutableOrderedDictionary dictionary];
    });
}

+ (void)manipulateActivitiesWithBlock:(void (^)(void))block {
	dispatch_async(_activitiesQueue, ^{
		[_activitiesLock lock];
		@try {
			block();
		} @finally {
			[_activitiesLock unlock];
		}
	});
}

static Class _instanceClass = Nil;

+ (void)setInstanceClass:(Class)instanceClass {
    _instanceClass = instanceClass;
}

+ (Class)instanceClass {
    return _instanceClass;
}

+ (id)activity {
    return [self activityWithIdentifier:nil];
}

+ (instancetype)activityWithIdentifier:(AJRActivityIdentifier)identifier {
    return [[(_instanceClass ?: self) alloc] initWithIdentifier:identifier];
}

+ (NSArray<AJRActivity *> *)activities {
	__block NSArray *activities;
    AJRBasicSemaphore *semaphore = [[AJRBasicSemaphore alloc] init];
	[self manipulateActivitiesWithBlock:^{
		activities = [_activities copy];
        [semaphore signal];
	}];
    [[NSRunLoop currentRunLoop] spinRunLoopInMode:NSDefaultRunLoopMode waitingForSemaphore:semaphore];
	return activities;
}

+ (void)addToActivities:(AJRActivity *)activity; {
	[self manipulateActivitiesWithBlock:^{
		[_activities addObject:activity];
        NSArray<AJRActivity *> *activities = [_activities copy];
        AJRRunAsyncOnMainThread(^{
            [self enumerateActivityObserversWithBlock:^(AJRActivityObserver observer, BOOL *stop) {
                observer(AJRActivityActionAdded, activity, activities);
            }];
        });
	}];
}

+ (void)removeFromActivities:(AJRActivity *)activity; {
	[self manipulateActivitiesWithBlock:^{
		[_activities removeObjectIdenticalTo:activity];
        NSArray<AJRActivity *> *activities = [_activities copy];
        AJRRunAsyncOnMainThread(^{
            [self enumerateActivityObserversWithBlock:^(AJRActivityObserver observer, BOOL *stop) {
                observer(AJRActivityActionRemoved, activity, activities);
            }];
        });
	}];
}

+ (void)manipulateActivityObserversWithBlock:(void (^)(void))block {
	[_activityObserversLock lock];
	@try {
		block();
	} @finally {
		[_activityObserversLock unlock];
	}
}

+ (void)enumerateActivityObserversWithBlock:(void (^)(AJRActivityObserver observer, BOOL *stop))block {
	[self manipulateActivityObserversWithBlock:^{
        [_activityObservers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, AJRActivityObserver observer, BOOL *stop) {
            block(observer, stop);
        }];
	}];
}

+ (id)addActivityObserver:(AJRActivityObserver)observer {
    __block NSNumber *token = nil;
	[self manipulateActivityObserversWithBlock:^{
        _observerToken += 1;
        token = @(_observerToken);
		[_activityObservers setObject:observer forKey:token];
	}];
    return token;
}

+ (void)removeActivityObserver:(id)token {
	[self manipulateActivityObserversWithBlock:^{
		[_activityObservers removeObjectForKey:token];
	}];
}

- (id)init {
    return [self initWithIdentifier:nil];
}

- (id)initWithIdentifier:(AJRActivityIdentifier)identifier {
    if (_instanceClass != nil && [self class] != _instanceClass) {
        self = [[_instanceClass alloc] initWithIdentifier:identifier];
    } else if ((self = [super init])) {
		_startTime = [[NSDate allocWithZone:nil] init];
		_progress = 0.0;
		_progressMin = 0.0;
		_progressMax = 1.0;
		_messages = [NSMutableArray array];
        _delegates = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
        _identifier = identifier;
	}
	
	return self;
}

- (id)view {
	return nil;
}

- (void)updateMessageText {
	[self willChangeValueForKey:@"message"];
	_message = [_messages lastObject];
	[self didChangeValueForKey:@"message"];
}

- (void)addDelegate:(id)aDelegate {
	[_delegates addObject:aDelegate];
}

- (void)removeDelegate:(id)aDelegate {
    [_delegates removeObject:aDelegate];
}

- (void)setMessage:(NSString *)message {
	@synchronized (self) {
		if ([_messages count] == 0) {
			[self addMessage:message];
		} else {
            [_delegates enumerateObjectsUsingBlock:^(id  _Nullable object, NSUInteger index, BOOL * _Nonnull stop) {
                if ([object respondsToSelector:@selector(activity:willDisplayMessage:)]) {
                    [object activity:self willDisplayMessage:message];
                }
            }];
			[_messages replaceObjectAtIndex:[_messages count] - 1 withObject:message];
            [_delegates enumerateObjectsUsingBlock:^(id  _Nullable object, NSUInteger index, BOOL * _Nonnull stop) {
                if ([object respondsToSelector:@selector(activity:didDisplayMessage:)]) {
                    [object activity:self didDisplayMessage:message];
                }
            }];
		}
		[self updateMessageText];
	}
}

- (NSString *)message {
	@synchronized (self) {
		return _message;
	}
}

- (NSArray *)messages {
	NSArray *copy = nil;
	
	@synchronized (self) {
		copy = [_messages copy];
	}
	
	return copy;
}

- (void)_addMessage:(NSString *)message {
	@synchronized (self) {
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[_messages count]] forKey:@"messages"];
		[self willChangeValueForKey:@"message"];
        [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(activity:willDisplayMessage:)]) {
                [obj activity:self willDisplayMessage:message];
            }
        }];
		[_messages addObject:message];
        [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(activity:didDisplayMessage:)]) {
                [obj activity:self didDisplayMessage:message];
            }
        }];
		[self updateMessageText];
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[_messages count] - 1] forKey:@"messages"];
		[self didChangeValueForKey:@"message"];
	}
}

- (void)addMessage:(NSString *)message {
    AJRRunAsyncOnMainThread(^{
        [self _addMessage:message];
    });
}

- (void)_popMessage {
	@synchronized (self) {
		NSString *last = [_messages lastObject];
		
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[_messages count] - 1] forKey:@"messages"];
		[self willChangeValueForKey:@"message"];
        [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(activity:willRemoveMessage:)]) {
                [obj activity:self willRemoveMessage:last];
            }
        }];
		[_messages removeLastObject];
		[self updateMessageText];
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[_messages count]] forKey:@"messages"];
		[self didChangeValueForKey:@"message"];
	}
}

- (void)popMessage {
    AJRRunAsyncOnMainThread(^{
        [self _popMessage];
    });
}

- (NSTimeInterval)ellapsedTime {
    return fabs([_startTime timeIntervalSinceNow]);
}

- (void)setProgress:(CGFloat)percent {
	[self willChangeValueForKey:@"progress"];
	_progress = percent;
	[self didChangeValueForKey:@"progress"];
	
	for (id delegate in _delegates) {
		if ([delegate respondsToSelector:@selector(activity:didSetProgress:)]) {
			[delegate activity:self didSetProgress:_progress];
		}
	}
}

- (void)stop {
	// If any delegate intervenes, then we won't stop.
	for (id delegate in _delegates) {
		if ([delegate respondsToSelector:@selector(activityWillStop:)]) {
            if (![delegate activityWillStop:self]) {
                return;
            }
		}
	}
	
	_stopRequested = YES;
}

#pragma mark - NSKeyValueObserving

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    // This is done, because we don't want to send the willChange/didChange methods in the set method, but rather we do this in our internal updateMessage method.
	return ![key isEqualToString:@"message"];
}

@end
