/*
AJRActivity.h
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
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
/*!
 @header AJRActivity.h
 @abstract Defines the activity object used for displaying activity in background threads.
 @version 1.0
 @updated 2002-11-18
 @copyright Copyright (c) 2001 A.J. Raftis. All rights reserved.
 */

#import <AJRFoundation/AJRFoundationOS.h>

@class AJRActivity;
@protocol AJRActivityDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef NSString *AJRActivityIdentifier NS_TYPED_EXTENSIBLE_ENUM;
typedef NSObject *AJRActivityObserverToken;

typedef NS_ENUM (uint8_t, AJRActivityAction) {
    AJRActivityActionAdded,
    AJRActivityActionRemoved,
};

typedef void (^AJRActivityObserver)(AJRActivityAction action, AJRActivity *activity, NSArray<AJRActivity *> *activities);

/*!
 @class AJRActivity
 @discussion Activies are used to monitor long running processing. Thus, if you're creating a background thread to do some task, then you probably want to consider using an activity to monitor the progress of the background thread.
 
 In some ways, an actvity is similar to a NSOperation, in that you can request an activity to stop, and hopefully your thread will poll the activity to see if it should cancel its current task, but unlike NSOperation, an activity is only a descriptive representation of what an operation is doing, while the NSOperation is controlling the actual operation itself (such as managing the NSRunLoop).
 
 To create an activity, simple call +(id)activity or +(id)init. You should then configure your activity, and once you've set all relevant information, such as a message, progress, etc... then you should call -(void)addToViewer. When you make this last call, if your environment is configured for a viewer, the activity will be added. This is generally the case with applications linked against ASInterface as well AJRFoundation. When your activity is complete, you should call -(void)removeFromViewer.
 
 Finally, in your background thread, you should make sure to call -(BOOL)isStopRequested. If this method returns YES, then you should abandon your current work, clean up, and exit your thread. While this is only advisory, it does produce a better user experience when the user can stop a long running task. Note that you don't necessarily have to abandon the task immediately. For example, you might change your message to something like "Cancelling operation... Waiting for remote service awknoledgment".
 */
@interface AJRActivity : NSObject

@property (nonatomic,class,readonly) NSArray<AJRActivity *> *activities;
+ (void)addToActivities:(AJRActivity *)activity;
+ (void)removeFromActivities:(AJRActivity *)activity;
+ (AJRActivityObserverToken)addActivityObserver:(AJRActivityObserver)observer;
+ (void)removeActivityObserver:(AJRActivityObserverToken)observerToken;

#pragma mark - Object creation

/*!
 @discussion Creates and returns an autoreleased AJRActivity (or subclass).
 */
+ (instancetype)activity;
+ (instancetype)activityWithIdentifier:(nullable AJRActivityIdentifier)identifier;

@property (nonatomic,class,strong) Class instanceClass;

/*!
 @discussion Initialize a newly created activity. By default, this initializes the start time to now, the minimum progress to 0.0, the maximum progress to 1.0, and the progress to 0.0. The activity will have no messages, so you should call -(void)setMessage: or -(void)addMessage: immediately following.
 */
- (id)init;
- (id)initWithIdentifier:(nullable AJRActivityIdentifier)identifier;

#pragma mark - User interface

@property (nonatomic,readonly) NSDate *startTime;

/*!
 @discussion Provides a UI for representing the activity. By default, this returns nil. If you link against ASInterface, this method will return an NSView to represent the activity in an ASActivityViewer.
 */
@property (nullable,nonatomic,readonly) id view;

#pragma mark - Managing delegates.

/*!
 @discussion Adds a delegate to receive various notifications as to what an activity is up to doing.
 @seealso AJRActivityDelegate
 */
- (void)addDelegate:(id <AJRActivityDelegate>)delegate NS_SWIFT_NAME(addDelegate(_:));

/*!
 @discussion Removes a previous registered delegate.
 */
- (void)removeDelegate:(id <AJRActivityDelegate>)delegate NS_SWIFT_NAME(removeDelegate(_:));

#pragma mark - Managing the displayed message

/*!
 @discussion Set an identifier for the activity. These are used to group activities for display. For example, you might use a document's url as an identifier and then only display those activities for that document which are propriate. Generally speaking, a <code>null</code> identifier indicates a "global" activity that should be displayed via multilple documents.
 */
@property (nonatomic,nullable,readonly) AJRActivityIdentifier identifier;

/*!
 @discussion Sets the activity's one and only message. After this call, the activity will display only one message. You can therefore use this method to quikcly get the activity's messages back to a single, simple message.
 */
@property (nonatomic,strong) NSString *message;

/*!
 @discussion Returns the full list of the activity's messages.
 */
@property (nonatomic,readonly) NSArray<NSString *> *messages;

/*!
 @discussion Adds a message to the activity's stack of messages. Display of this will vary, but you can use this to express sub-tasks. Call -(NSString *)popMessage to remove the last message. You might use this method when expression sub-tasks. For example, your activity's first message might be "Loading image", while you'd then push and pop additional messages like "Contacting remote service", "Download data from service", and "Close remote service connection".
 */
- (void)addMessage:(NSString *)message;

/*!
 @discussion Removes the bottom most message from the activity's message stack.
 */
- (void)popMessage;

/*!
 @discusssion Called by subclasses when they change the message text.
 */
- (void)updateMessageText;

/*!
 @discussion Returns the time in seconds since the activity started.
 */
@property (nonatomic,readonly) NSTimeInterval ellapsedTime;

#pragma mark - Manage progress

/*!
 @discussion Call this method if the activity is unable to display its progress in any meaningful way. For example, if you're talking to a remote service that doesn't report the total size of a response before returning data, then you don't know the final size of the response, and therefore you would be unable to display a meaning progress.
 */
@property (nonatomic,assign,getter=isIndeterminate) BOOL indeterminate;

/*!
 @discussion Sets the current progress of the activity. This may or may be expressed as a percent. In fact, it's a value between progressMin and progressMax. This actually allows for nested activities where each activity is responsible for a different part of the progress. For example, you might have to make two or three calls to complete a request. As such, each of the subrequests could create an activity. When this happens, each subrequest would divide up the progress by setting progressMin and progressMax in a reasonable way for each task. For example, 0 to .25, .25 to .75, and .75 to 1.0.
 */
@property (nonatomic,assign) CGFloat progress;

/*!
 @discussion Sets the minimum progress value.
 @seealso -(void)setProgress:
 */
@property (nonatomic,assign) CGFloat progressMin;

/*!
 @discussion Sets the maximum progress value.
 */
@property (nonatomic,assign) CGFloat progressMax;

#pragma mark - Controlling termination

/*!
 @discussion Flags the activity to indicate that a stop was requested.
 */
- (void)stop;

/*!
 @discussion When you're done with your activity, call this method with YES to indicate that you'll no longer be updating the activity.
 */
@property (nonatomic,assign,getter=isStopped) BOOL stopped;

/*!
 @discussion If the activity has be requested to stop, this method returns YES. Your background task should poll this method looking for a YES response. If you receive one, your task should clean up and exit.
 */
@property (nonatomic,readonly,getter=isStopRequested) BOOL stopRequested;

#pragma mark - Additional data...

/*!
 @discussion You can attach arbitrary information an activity. This can be a useful way to pass information around between tasks. Call this method to get a dictionary into which you can put this information.
 */
@property (nonatomic,copy) NSDictionary *userInfo;

@end

/*!
 @discussion Defines delegate methods called by the AJRActivity object.
 */
@protocol AJRActivityDelegate <NSObject>

/*!
 @discussion Called when the activity's progress changes. You can use this to note the change.
 @param activity The active activity.
 @param percent The percent complete for the activity. This will range between 0.0 and 1.0, inclusive.
 */
@optional - (void)activity:(AJRActivity *)activity didSetProgress:(double)percent;

/*!
 @discussion Called when the activity has been requested to stop. Note that this doesn't mean the activity will stop, but just that it had been requested to stop.
 @param activity The active activity.
 */
@optional - (BOOL)activityWillStop:(AJRActivity *)activity;

/*!
 @discussion Called when the activity is changing or removing a message from its message stack.
 @param activity The active activity.
 @param message The message being added to the activity.
 */
@optional - (void)activity:(AJRActivity *)activity willDisplayMessage:(NSString *)message;
@optional - (void)activity:(AJRActivity *)activity didDisplayMessage:(NSString *)message;

/*!
 @discussion Called when the activtiy is removing a message from its message stack.
 @param activity The active activity.
 @param message The message being removed.
 */
@optional - (void)activity:(AJRActivity *)activity willRemoveMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
