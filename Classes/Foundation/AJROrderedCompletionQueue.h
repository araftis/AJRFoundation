
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRQueueState) {
    AJRQueueStateRunning,
    AJRQueueStatePaused,
};

/*! Defines a block that creates a limited resource. This will be called a limited number of times to create a resource to share across multiple threads. */
typedef id _Nonnull (^AJRLimitedResourceCreationBlock)(NSError **error);
/*! Defines a block that will be called with a limited resource. The resource is generally created via a AJRLimitedResourceCreationBlock. */
typedef id _Nonnull (^AJRLimitedResourceWorkBlock)(id limitedResource);
/*! Defines a block that executes without need to access a limited resource. */
typedef id _Nonnull (^AJRWorkBlock)(void);
/*! A block that's called when a job completes. The completion blocks will be called in order of originally submittal. */
typedef void (^AJRWorkCompletionBlock)(id results);

@interface AJROrderedCompletionQueue : NSObject

@property (nonatomic,assign) NSUInteger maxResourceCount;
@property (nonatomic,strong) dispatch_queue_t completionQueue;
@property (nonatomic,readonly) AJRQueueState state;

- (id)initWithLimitedResourceCreationBlock:(AJRLimitedResourceCreationBlock)creationBlock;

- (void)performBlock:(AJRWorkBlock)block withCompletionBlock:(AJRWorkCompletionBlock)completionBlock;
- (void)performLimitedResourceBlock:(AJRLimitedResourceWorkBlock)block withCompletionBlock:(AJRWorkCompletionBlock)completionBlock;

#pragma mark - Controls

- (AJRQueueState)state;
- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
