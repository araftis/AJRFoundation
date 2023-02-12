/*
 AJRPathObserver.h
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *AJRStringFromFSEventStreamEvent(FSEventStreamEventFlags flags);

typedef NSObject *AJRPathObserverToken;

typedef NS_ENUM(uint8_t, AJRPathObserverChange) {
    AJRPathObserverChangeNOP,
    AJRPathObserverChangeModified,
    AJRPathObserverChangeCreated,
    AJRPathObserverChangeRemoved,
    AJRPathObserverChangeRenamed,
};

/**
 Defines the callback block for observations. The path observer will analyze what comes from the file system observations and turn the changes into a more simplified view of what happened. This make implementing observers a lot easier, but comes at the cost of true, deep meaning. You can get more meaning of the change by checking flags. For example, when you receive a AJRPathObserverChangeModified, you don't know if the change was to the file's attributes or contents. If you care, you can get flags to see.
 
 The values of observedPath and actualPath can vary by operation. Here's how they're defined
 
 Change    | observedPath                      | actualPath
 ----------+-----------------------------------+---------------------
 Modified  | The file modified                 | nil
 Created   | The directory containing the file | The file created
 Removed   | The directory containing the file | The file removed
 Renamed   | The original file name            | The new file name
 */
typedef void (^AJRPathObserverCallback)(AJRPathObserverChange change, NSString *observedPath, NSString *actualPath, FSEventStreamEventFlags flags);

@interface AJRPathObserver : NSObject

@property (class,nonatomic,readonly) AJRPathObserver *sharedPathObserver NS_SWIFT_NAME(shared);

+ (AJRPathObserverToken)generateUniqueObserverToken;

/**
 Calls <code>observePaths:withCallback:</code>. If you need to add many paths, you should call <code>observePaths:withCallback:</code> directly, as this will be significantly more performant, as stopping and re-starting path observation can be expensive. See the definition of <code>observePaths:withCallback:</code> for more details.
 
 @param path The path to observe.
 @param token A unique token used to identify your observer. You may pass nil to indentify as the "global" observer, but this can be problematic if multiple objects are doing observations.
 @param callback A block to call that will handle the observation.
 */
- (void)observePath:(NSString *)path observer:(nullable AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback;

/**
 Starts observing the path specified in <code>paths</code>. Note that only the paths specified are observed, thus if you say pass in /foo/bar/widget.txt, and you want to observer "foo", "bar", and "widget", then you must path in the array: ["/foo", "/foo/bar", and "/foo/widget.txt". If file observation is not currently active, calling this method will automatically start observation, thus you do not need to call <code>start</code> explicitly. Note that that paths in <code>paths</code> will not be validated, and passing in invalid file paths may produce invalid behavior.
 
 <code>callback</code> refers to a block that can be used to process the observations. The block will be called with three parameters: observedPath, actualPath, and flags. The valid of observedPath and actualPath will vary depending on the value of flags.
 
 Note that you can pass the same path in multiple times, as the observation will be uniqued based off the path and the pointer value of the block. Thus, two callers can get observations on the same path, but the same caller, assuming they pass in the same block, will only receive one observation.
 
 @param paths An array of file paths.
 @param token A unique token used to identify your observer. You may pass nil to indentify as the "global" observer, but this can be problematic if multiple objects are doing observations.
 @param callback A block that will be called when an observation occurs.
 */
- (void)observePaths:(NSArray<NSString *> *)paths observer:(nullable AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback;
- (void)removePathFromObservation:(NSString *)path observer:(AJRPathObserverToken)token;
- (void)removePathsFromObservation:(NSArray<NSString *> *)paths observer:(AJRPathObserverToken)token;

- (void)observeURL:(NSURL *)url observer:(nullable AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback;
- (void)observeURLs:(NSArray<NSURL *> *)urls observer:(nullable AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback;
- (void)removeURLFromObservation:(NSURL *)url observer:(AJRPathObserverToken)token;
- (void)removeURLsFromObservation:(NSArray<NSURL *> *)urls observer:(AJRPathObserverToken)token;

/*! Starts the path observer in its own thread. Normally, you don't have to call this. It'll be started for you. */
- (void)start;
/*! Stops the path observer. Normally the path observer runs continuously, but if you want, you can explicitly stop it. If you stop it, you'll need to restart it manually. */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
