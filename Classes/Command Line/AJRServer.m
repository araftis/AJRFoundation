/*%*%*%*%*
 Copyright (C) 1995-2004 A. J. Raftis
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 Or, contact the author,
 
 A. J. Raftis
 mailto:alex@raftis.net
 http://www.raftis.net/~alex/
 *%*%*%*%*/
/* AJRServer.m created by alex on Wed 03-Jun-1998 */

#import "AJRServer.h"

#import "AJRLogging.h"

// Set the default timeout at 120 seconds.
const NSTimeInterval AJRDefaultConnectionTimeout = 120.0;

NSString * const AJRServerDidConnectClientNotification = @"AJRServerDidConnectClientNotification";
NSString * const AJRServerDidDisconnectClientNotification = @"AJRServerDidDisconnectClientNotification";

NSString * const AJRServerClientNameKey = @"AJRServerClientNameKey";
NSString * const AJRServerClientHostKey = @"AJRServerClientHostKey";
NSString * const AJRServerClientProxyKey = @"AJRServerClientProxyKey";

@implementation AJRServer {
    NSTimeInterval connectionTimeout;
	
    NSLock *newConnectionLock;
    NSLock *newConnectionStartLock;
    
    NSXPCConnection *_connection;
    
    NSMutableDictionary *clients;
}

- (id)init {
    self = [super init];
    
    // Set up our arguments.
    [self registerArgument:@"server"
                 parameter:@"<name>"
                      type:AJRArgumentTypeString
                  property:@"serverName"
                      help:@"Specify the name of the server."
                   repeats:NO
                  required:NO];
    [self registerArgument:@"timeout"
                 parameter:@"<seconds>"
                      type:AJRArgumentTypeDouble
                  property:@"connectionTimeout"
                      help:@"Specify send/receive timeout on connections."
                   repeats:NO
                  required:NO];
    
    // Create the locks we'll need while running to insure that we're thread safe.
    newConnectionLock = [[NSLock alloc] init];
    newConnectionStartLock = [[NSLock alloc] init];
    
    // Set the default timeout.
    [self setConnectionTimeout:AJRDefaultConnectionTimeout];
    
    clients = [[NSMutableDictionary alloc] init];
    
    [self setClientProtocol:@protocol(AJRClientProtocol)];
    [self setServerProtocol:@protocol(AJRServerProtocol)];
    
    [self setManagesRunLoop:YES];
    
    // This is temporary.
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clientIsInvalid:) name:NSConnectionDidDieNotification object:nil];
    
    return self;
}

- (void)dealloc {
    // Invalidate the connection before releasing it. This helps to make sure that we exit cleanly.
    [_connection invalidate];
}

- (void)mainWillRun {
    AJRLogError(@"%S: not implemented", _cmd);
	
	_connection = [[NSXPCConnection alloc] initWithServiceName:[self serverName]];
	_connection.exportedObject = [self rootObjectForClientConnection:_connection];
	_connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:self.serverProtocol];
}

- (BOOL)threaded {
    return NO;
}

- (NSString *)serverName {
	return _serverName ?: [self applicationName];
}

- (void)setConnectionTimeout:(NSTimeInterval)aTimeout {
    connectionTimeout = aTimeout;
}

- (NSTimeInterval)connectionTimeout {
    return connectionTimeout;
}

- (id)rootObjectForClientConnection:(NSXPCConnection *)aConnection {
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

#warning Get AJRServer working again.

static NSConnection *_connectionToToast = nil;

- (BOOL)connection:(NSConnection *)parentConnection shouldMakeNewConnection:(NSConnection *)newConnection {
    // Note, we don't need to worry about this being thread safe, because only one connection can be created at a time. Ie, we have to finish processing the connection request in out NSRunLoop before the next request can occur.
    
    if ([self threaded]) {
        [newConnection enableMultipleThreads];
    }
    
    // Set the time outs on the connection.
    [newConnection setRequestTimeout:AJRDefaultConnectionTimeout];
    [newConnection setReplyTimeout:AJRDefaultConnectionTimeout];
    
    // This makes sure that the original connection from the client to use, before the call back, will be removed. This is safe to do, because we lock the connection creation process, such that only one connection can be created at a time.
    _connectionToToast = newConnection;
    
    //   NSLog(@"%@: parentConnection = 0x%x", [self class], parentConnection);
    //   NSLog(@"%@: newConnection =    0x%x", [self class], newConnection);
    
    return YES;
}

- (BOOL)connectWithDictionary:(NSDictionary *)dictionary {
    NSConnection *newConnection;
    NSString *name = [dictionary objectForKey:AJRServerClientNameKey];
    NSHost *host = [dictionary objectForKey:AJRServerClientHostKey];
    id clientsKey;
    id <AJRClientProtocol> rootProxy;
    BOOL result = YES;
    
    // Create and autorelease pool for this thread. Autorelease pools aren't shared accross threads. We only create the pool if we're theaded.
    @autoreleasepool {
        
        // Invalidate the temporary connection used by the client to initially contact us.
        [_connectionToToast invalidate];
        _connectionToToast = nil;
        
        // Create a new connection.
        newConnection = [NSConnection connectionWithRegisteredName:name host:[host name]];
        if (!newConnection) {
            AJRLogWarning(@"Failed call back to host %@.", [host name]);
            result = NO;
        } else {
            [newConnection setRequestTimeout:[self connectionTimeout]];
            [newConnection setReplyTimeout:[self connectionTimeout]];
            
            if ([self threaded]) {
                [newConnection enableMultipleThreads];
            }
            rootProxy = (id <AJRClientProtocol>)[newConnection rootProxy];
            [(NSDistantObject *)rootProxy setProtocolForProxy:[self clientProtocol]];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clientIsInvalid:)
                                                         name:NSConnectionDidDieNotification
                                                       object:(id)newConnection];
            clientsKey = [NSValue valueWithPointer:(__bridge void *)newConnection];
            [clients setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [name copy], AJRServerClientNameKey,
                                host, AJRServerClientHostKey,
                                rootProxy, AJRServerClientProxyKey,
                                nil]
                        forKey:clientsKey];
            
            AJRLogInfo(@"Connect to %@ Created", [host name]);
            
            @try {
				[rootProxy serverDidConnect:[self rootObjectForClientConnection:nil]];//newConnection]];
                // this will allow only 1 remote message to be processed at any 1 time
                // in a thread if set to YES
                //[newConnection setIndependentConversationQueueing:YES];
                result = YES;
            } @catch (NSException *localException) {
                AJRLogError(@"Client on host %@ does not implement proper protocols. It did not respond to serverDidConnect:", [host name]);
                [clients removeObjectForKey:clientsKey];
                result = NO;
            }
            
            // a retained copy is returned from the call to [newConnection rootProxy]
        }
        
        [newConnectionStartLock unlock];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AJRServerDidConnectClientNotification
                                                            object:(id)self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    name, AJRServerClientNameKey,
                                                                    host, AJRServerClientHostKey,
                                                                    nil]];
        
        if ([self threaded]) {
            // Start out run loop.
            [[NSRunLoop currentRunLoop] run];
            
            AJRLogInfo(@"Session Terminating");
            
            // Exit the thread.
            [NSThread exit];
        }
        
        
        return result;
    }
}

- (void)threadedConnectWithDictionary:(NSDictionary *)dictionary {
    // calls connectWithDictionary: and discards return value
    [self connectWithDictionary:(NSDictionary *)dictionary];
}

- (bycopy NSString *)connectWithName:(NSString *)name host:(NSHost *)aHost {
    NSDictionary *dictionary;
    BOOL success = YES;
    
    // This isn't, I think, necessary, but I have it here just in case. Basically, we should
    // never be able to enter this loop concurrently from the main thread. There is, however,
    // a slight chance, and if there is any slight chance of it happening, we want to avoid it.
    [newConnectionLock lock];
    
    // We use newConnectionStartLock to allow the thread to start up. Once the thread has started
    // it will release this lock and allow us to continue the main thread (see below).
    [newConnectionStartLock lock];
    
    // Detach the new thread, handing it the name we generate. We have to pass this along, since the unique name can only be generated once.
    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:name, AJRServerClientNameKey, aHost, AJRServerClientHostKey, nil];
    if ([self threaded]) {
        [NSThread detachNewThreadSelector:@selector(threadedConnectWithDictionary:)
                                 toTarget:self
                               withObject:dictionary];
    } else {
        success = [self connectWithDictionary:dictionary];
    }
    
    // Block until out thread says it's done. It tells us it's done by unlocking newConnectionStartLock. Once done, we'll just unlock the lock. Done for the new thread means that it has configured itself, not that it's done running.
    [newConnectionStartLock lock];
    [newConnectionStartLock unlock];
    
    // Allow the next thread (if there is one) to continue.
    [newConnectionLock unlock];
    
    if (success) {
        return name;
    } else {
        // unsuccessful connect
        return nil;
    }
}

- (bycopy NSString *)connectWithName:(NSString *)name hostName:(NSString *)aHostName {
    return [self connectWithName:name hostName:aHostName];
}

- (void)disconnectWithName:(NSString *)name host:(NSHost *)aHost {
    NSArray *keys;
    NSNumber *key = nil;
    NSInteger x;
    NSDictionary *node;
    NSConnection *childConnection = nil;
    
    [_connectionToToast invalidate];
    _connectionToToast = nil;
    
    keys = [clients allKeys];
    for (x = 0; x < (const int)[keys count]; x++) {
        key = [keys objectAtIndex:x];
        node = [clients objectForKey:key];
        
        if (([(NSString *)[node objectForKey:AJRServerClientNameKey] compare:name] == NSOrderedSame) &&
            ([[(NSHost *)[node objectForKey:AJRServerClientHostKey] name] compare:[aHost name]] == NSOrderedSame)) {
            childConnection = (NSConnection *)[key pointerValue];
            break;
        }
    }
    
    if (childConnection) {
        [childConnection invalidate];
        [childConnection removePortsFromAllRunLoops];
        // this will release the proxy
        [clients removeObjectForKey:key];
    } else {
        AJRLogWarning(@"Unknown child %@ on host %@ attempted to disconnect.", name, [aHost name]);
    }
}

- (void)disconnectWithName:(NSString *)name hostName:(NSString *)aHostName {
    [self disconnectWithName:name host:[NSHost hostWithName:aHostName]];
}

- (void)clientIsInvalid:(NSNotification *)notification {
    NSDictionary *node;
    NSConnection *oldClientConnection = [notification object];
    NSValue *key = [NSValue valueWithPointer:(__bridge void *)oldClientConnection];
    
    node = [clients objectForKey:key];
    if (!node) {
    } else {
        AJRLogInfo(@"Child on host %@ died.", [(NSHost *)[node objectForKey:AJRServerClientHostKey] name]);
        [oldClientConnection invalidate];
        [oldClientConnection removePortsFromAllRunLoops];
        // this will release the proxy
        [clients removeObjectForKey:key];
        [[NSNotificationCenter defaultCenter] postNotificationName:AJRServerDidDisconnectClientNotification
                                                            object:(id)self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [node objectForKey:AJRServerClientNameKey], AJRServerClientNameKey,
                                                                    [node objectForKey:AJRServerClientHostKey], AJRServerClientHostKey,
                                                                    nil]];
    }
}

#pragma clang diagnostic pop

@end
