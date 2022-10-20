/*
AJRPathObserver.m
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

#import "AJRPathObserver.h"

#import <AJRFoundation/AJRFoundation.h>

static NSString * const AJRPathObserverLogDomain = @"AJRPathObserverLogDomain";

NSString *AJRStringFromFSEventStreamEvent(FSEventStreamEventFlags flags) {
	NSMutableArray	*strings = [NSMutableArray array];
	
	if (flags & kFSEventStreamEventFlagItemCreated) {
		[strings addObject:@"Created"];
	}
    if (flags & kFSEventStreamEventFlagItemRemoved) {
		[strings addObject:@"Removed"];
	}
    if (flags & kFSEventStreamEventFlagItemInodeMetaMod) {
		[strings addObject:@"Inode Meta Info Modified"];
	}
    if (flags & kFSEventStreamEventFlagItemModified) {
		[strings addObject:@"Item Modified"];
	}
    if (flags & kFSEventStreamEventFlagItemFinderInfoMod) {
		[strings addObject:@"Finder Info Modified"];
	}
    if (flags & kFSEventStreamEventFlagItemChangeOwner) {
		[strings addObject:@"Changed Owner"];
	}
    if (flags & kFSEventStreamEventFlagItemXattrMod) {
		[strings addObject:@"Extended Attributes Modified"];
	}
    if (flags & kFSEventStreamEventFlagItemIsFile) {
		[strings addObject:@"Is a File"];
	}
    if (flags & kFSEventStreamEventFlagItemIsDir) {
		[strings addObject:@"Is a Directory"];
	}
    if (flags & kFSEventStreamEventFlagItemIsSymlink) {
		[strings addObject:@"Is a Symlink"];
	}
	
	return [strings componentsJoinedByString:@", "];
}

@interface AJRPathObserver ()

- (void)startOnNewThread;
- (void)start;

@end

@implementation AJRPathObserver
{
    dispatch_semaphore_t _runSemaphore;
    id <NSLocking> _runLock;
    CFRunLoopRef _eventRunLoop;
    NSThread *_eventThread;
    id <NSLocking> _eventStreamLock;
    FSEventStreamRef _eventStream;
    id <NSLocking> _pathsLock;
    NSMutableDictionary<NSString *, NSMutableDictionary<AJRPathObserverToken, AJRPathObserverCallback> *> *_paths;
    NSMutableDictionary<NSString *, NSURL *> *_fileReferences;
}

#pragma mark - Initialization

static AJRPathObserverToken _globalPathObserverToken;

+ (id)sharedPathObserver {
	static AJRPathObserver *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[AJRPathObserver alloc] init];
        _globalPathObserverToken = NSProcessInfo.processInfo.globallyUniqueString;
	});
	return shared;
}

- (id)init {
	if ((self = [super init])) {
		_runSemaphore = dispatch_semaphore_create(0);
		_runLock = [[NSRecursiveLock alloc] init];
		_eventStreamLock = [[NSRecursiveLock alloc] init];
		_pathsLock = [[NSRecursiveLock alloc] init];
		_paths = [[NSMutableDictionary alloc] init];
        _fileReferences = [[NSMutableDictionary alloc] init];
		
		[self start];
	}
	return self;
}

#pragma mark - Observer Token

+ (AJRPathObserverToken)generateUniqueObserverToken {
    return NSProcessInfo.processInfo.globallyUniqueString;
}

#pragma mark - Notification

static void _fileSystemEventHandler(ConstFSEventStreamRef streamRef,
                                    void *clientCallBackInfo,
                                    size_t numEvents,
                                    void *eventPathsIn,
                                    const FSEventStreamEventFlags eventFlags[],
                                    const FSEventStreamEventId eventIds[]) {
    AJRPathObserver *pathObserver = (__bridge AJRPathObserver *)clientCallBackInfo;
	id <NSLocking> pathsLock = pathObserver->_pathsLock;
	
	[pathsLock lock];
	@try {
		NSDictionary *paths = pathObserver->_paths;
		NSArray *eventPaths = (__bridge NSArray *)eventPathsIn;
		
		for (NSInteger index = 0; index < numEvents; index++) {
			NSString *path = [eventPaths objectAtIndex:index];
            NSString *actualPath = path;
            AJRLog(AJRPathObserverLogDomain, AJRLogLevelDebug, @"path: (%@) %@", AJRStringFromFSEventStreamEvent(eventFlags[index]), path);
            NSDictionary<AJRPathObserverToken, AJRPathObserverCallback> *callbacks = [paths objectForKey:path];
            // If we didn't observe the file, lets see if we were asked to observe it's path. Iterate up the paths of the change and notify the first observers that we find.
            while ([callbacks count] == 0 && [path length] && ![path isEqualToString:@"/"]) {
                path = [path stringByDeletingLastPathComponent];
                callbacks = [paths objectForKey:path];
            }
            if (callbacks) {
                for (AJRPathObserverCallback callback in [callbacks allValues]) {
                    @autoreleasepool {
                        AJRPathObserverChange change = AJRPathObserverChangeNOP;
                        
                        // If the file was removed, then it's nonsense to try to see if it's been renamed.
                        if ((eventFlags[index] & kFSEventStreamEventFlagItemIsFile)
                            && !(eventFlags[index] & kFSEventStreamEventFlagItemRemoved)) {
                            NSURL *fileReference = [pathObserver->_fileReferences objectForKey:path];
                            NSString *resolvedPath = [[fileReference URLByStandardizingPath] path];
                            if (resolvedPath != nil && ![path isEqualToString:resolvedPath]) {
                                // This indicates that the file was "renamed" or removed, so we'll report the old and new name, as well as updating our internal tables. Note when resolvedPath is nil, then we tried to resolve a stale file system reference, in which case, we're definitely not renaming.
                                actualPath = resolvedPath;
                                NSMutableDictionary<AJRPathObserverToken, AJRPathObserverCallback> *currentCallbacks = pathObserver->_paths[path];
                                [pathObserver->_paths removeObjectForKey:path];
                                if (actualPath) {
                                    [pathObserver->_paths setObject:currentCallbacks forKey:actualPath];
                                }
                                [pathObserver->_fileReferences removeObjectForKey:path];
                                if (actualPath) {
                                    [pathObserver->_fileReferences setObject:fileReference forKey:actualPath];
                                }
                                change = AJRPathObserverChangeRenamed;
                            }
                        }
                        if (change == AJRPathObserverChangeNOP) {
                            // We didn't detect a rename, so let's see what we might be.
                            if (eventFlags[index] & kFSEventStreamEventFlagItemRemoved) {
                                change = AJRPathObserverChangeRemoved;
                            } else if (eventFlags[index] & kFSEventStreamEventFlagItemModified
                                       || eventFlags[index] & kFSEventStreamEventFlagItemInodeMetaMod) {
                                change = AJRPathObserverChangeModified;
                            } else if (eventFlags[index] & kFSEventStreamEventFlagItemCreated) {
                                change = AJRPathObserverChangeCreated;
                            }
                        }
                        if (change != AJRPathObserverChangeNOP) {
                            // And event occurred that we don't really care about. For example, renaming comes in as two events. The first event shows the file being "created", which we detect as a rename, because we look up the old path name by the file's file reference. The second event is just a "generic" event that basically indicates the old file was "removed". Regardless, since it's easy to our clients to process this as a single rename event, we don't send along the second event.
                            switch (change) {
                                case AJRPathObserverChangeNOP: break; // This'll never happen
                                case AJRPathObserverChangeModified:
                                    AJRLog(AJRPathObserverLogDomain, AJRLogLevelDebug, @"Modified: %@", path);
                                    break;
                                case AJRPathObserverChangeCreated:
                                    AJRLog(AJRPathObserverLogDomain, AJRLogLevelDebug, @"Created: %@", actualPath);
                                    break;
                                case AJRPathObserverChangeRemoved:
                                    // Basically, we're making this act like create, which is the "modified" path will be the parent path, while the "actualPath" will be the file getting removed.
                                    path = actualPath.stringByDeletingLastPathComponent;
                                    AJRLog(AJRPathObserverLogDomain, AJRLogLevelDebug, @"Removed: %@", actualPath);
                                    // And since we're doing a remove...
                                    [pathObserver->_fileReferences removeObjectForKey:actualPath];
                                    // We're hamhandedly remove all observers, because the path no longer exists.
                                    [pathObserver->_paths removeObjectForKey:actualPath];
                                    break;
                                case AJRPathObserverChangeRenamed:
                                    AJRLog(AJRPathObserverLogDomain, AJRLogLevelDebug, @"Renamed: %@ -> %@", path, actualPath);
                                    break;
                            }
                            callback(change, path, actualPath, eventFlags[index]);
                        }
                    }
                }
            }
		}
	} @finally {
		[pathsLock unlock];
	}
}

#pragma mark - Monitor Thread

- (void)startEventStream {
	[_runLock lock];
	@try {
		// Only start if we're already running.
		if (_eventThread) {
			[_eventStreamLock lock];
			[_pathsLock lock];
			@try {
				NSAssert(_eventStream == NULL, @"You cannot start an event stream while one is already running.");
				
				if ([_paths count]) {
					struct FSEventStreamContext context = {
						.version = 0, 
						.info = (__bridge void *)self, 
						.retain = CFRetain, 
						.release = CFRelease
					};
					
					_eventStream = FSEventStreamCreate(NULL, 
													   _fileSystemEventHandler,
													   &context,
													   (__bridge CFArrayRef)[[[_paths allKeys] valueForKey:@"stringByDeletingLastPathComponent"] ajr_orderedUniqueObjects],
													   kFSEventStreamEventIdSinceNow,
													   0.25,
													   kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagIgnoreSelf | kFSEventStreamCreateFlagFileEvents);
					FSEventStreamScheduleWithRunLoop(_eventStream, _eventRunLoop, kCFRunLoopCommonModes);
					FSEventStreamStart(_eventStream);
				}
			} @finally {
				[_pathsLock unlock];
				[_eventStreamLock unlock];
			}
		}
	} @finally {
		[_runLock unlock];
	}
}

- (void)stopEventStream {
	[_eventStreamLock lock];
	@try {
		if (_eventStream) {
			FSEventStreamStop(_eventStream);
			FSEventStreamUnscheduleFromRunLoop(_eventStream, _eventRunLoop, kCFRunLoopCommonModes);
			FSEventStreamInvalidate(_eventStream);
			FSEventStreamRelease(_eventStream);
			_eventStream = NULL;
		}
	} @finally {
		[_eventStreamLock unlock];
	}
}

- (void)restartEventStream {
	[_eventStreamLock lock];
	@try {
		if (_eventStream) {
			[self stopEventStream];
		}
		[self startEventStream];
	} @finally {
		[_eventStreamLock unlock];
	}
}

- (void)terminateEventThread {
	[_eventStreamLock lock];
	@try {
		[self stopEventStream];
		[_runLock lock];
		@try {
			if (_eventRunLoop) {
				CFRunLoopStop(_eventRunLoop	);
				_eventRunLoop = NULL;
				_eventThread = nil;
			}
		} @finally {
			[_runLock unlock];
		}
	} @finally {
		[_eventStreamLock unlock];
	}
}

- (void)heartBeat {
	// We don't do anything here, yet. This mostly just keeps the run loop alive when we're not actually observing any file system events.
}

- (void)startOnNewThread {
    @autoreleasepool {
		// This is protected by the lock in start. I'll hold that lock until we signal it we're about to start our runloop.
		_eventRunLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetCurrent());
		_eventThread = [NSThread currentThread];
		[_eventThread setName:@"AJRPathObservingThread"];
		// Signal that we've initialized our instance variables and we're now ready to run.
		dispatch_semaphore_signal(_runSemaphore);
		// Schedule something into the run loop to make it run.
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
		// And start the run loop.
        CFRunLoopRun(); // This will probably never return, unless someone calls CFRunLoopStop().
		[_runLock lock];
		@try {
			[self stopEventStream];
			_eventThread = nil;
			_eventRunLoop = NULL;
		} @finally {
			[_runLock unlock];
		}
    }
}

- (void)stop {
	[_runLock lock];
	@try {
		[self terminateEventThread];
		_eventThread = nil;
		_eventRunLoop = NULL;
	} @finally {
		[_runLock unlock];
	}
}

- (void)start {
	[_runLock lock];
	@try {
		NSAssert(_eventThread == nil, @"You cannot start a path observer while it's already running.");
		[NSThread detachNewThreadSelector:@selector(startOnNewThread) toTarget:self withObject:nil];
		// Wait for our thread to let us know it's up-and-running.
		dispatch_semaphore_wait(_runSemaphore, DISPATCH_TIME_FOREVER);
		// So that we can now start the event stream.
		[self startEventStream];
	} @finally {
		[_runLock unlock];
	}
}

#pragma mark - Observers

- (void)observePath:(NSString *)path observer:(AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback {
	return [self observePaths:@[path] observer:(AJRPathObserverToken)token withCallback:callback];
}

- (void)observePaths:(NSArray<NSString *> *)paths observer:(AJRPathObserverToken)tokenIn withCallback:(AJRPathObserverCallback)callback {
	[_pathsLock lock];
	@try {
        AJRPathObserverToken token = tokenIn ?: _globalPathObserverToken;
		for (NSString *path in paths) {
            NSString *actualPath = [path isKindOfClass:[NSURL class]] ? [(NSURL *)path path] : path;
			NSMutableDictionary<AJRPathObserverToken, AJRPathObserverCallback> *callbacks = [_paths objectForKey:actualPath];
			if (callbacks == nil) {
				callbacks = [[NSMutableDictionary alloc] init];
				[_paths setObject:callbacks forKey:actualPath];
                [_fileReferences setObjectIfNotNil:[[NSURL fileURLWithPath:actualPath] fileReferenceURL] forKey:actualPath];
			}
            if ([callbacks objectForKey:token] == nil) {
                [callbacks setObject:callback forKey:(id)token]; // This is a little wonky, but we know our token type is copyable.
            }
		}
		[self restartEventStream];
	} @finally {
		[_pathsLock unlock];
	}
}

- (void)removePathFromObservation:(NSString *)path observer:(AJRPathObserverToken)token {
	[self removePathsFromObservation:@[path] observer:token];
}

- (void)removePathsFromObservation:(NSArray *)paths observer:(AJRPathObserverToken)token {
	[_pathsLock lock];
	@try {
		for (NSString *path in paths) {
			[_paths removeObjectForKey:path];
            [_fileReferences removeObjectForKey:path];
		}
		[self restartEventStream];
	} @finally {
		[_pathsLock unlock];
	}
}

- (void)removeAllPathsFromObservation {
	[_pathsLock lock];
	@try {
		[_paths removeAllObjects];
        [_fileReferences removeAllObjects];
		[self restartEventStream];
	} @finally {
		[_pathsLock unlock];
	}
}

#pragma mark - URL Interfaces

- (void)observeURL:(NSURL *)url observer:(AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback {
    if (url.isFileURL) {
        [self observePath:url.path observer:token withCallback:callback];
    }
}

- (void)observeURLs:(NSArray<NSURL *> *)urls observer:(AJRPathObserverToken)token withCallback:(AJRPathObserverCallback)callback {
    NSArray<NSString *> *paths = [urls filteredAndMappedArrayUsingBlock:^NSString * (NSURL *object) {
        return object.isFileURL ? object.path : nil;
    }];
    
    if (paths.count > 0) {
        [self observePaths:paths observer:token withCallback:callback];
    }
}

- (void)removeURLFromObservation:(NSURL *)url observer:(AJRPathObserverToken)token {
    if (url.isFileURL) {
        [self removePathFromObservation:url.path observer:token];
    }
}

- (void)removeURLsFromObservation:(NSArray<NSURL *> *)urls observer:(AJRPathObserverToken)token {
    NSArray<NSString *> *paths = [urls filteredAndMappedArrayUsingBlock:^NSString * (NSURL *object) {
        return object.isFileURL ? object.path : nil;
    }];
    if (paths.count > 0) {
        [self removePathsFromObservation:paths observer:token];
    }
}

#pragma mark - Destruction

- (void)dealloc {
	[self terminateEventThread];
}

@end
