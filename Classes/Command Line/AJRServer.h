/*
 AJRServer.h
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

#import <AJRFoundation/AJRMain.h>

const extern NSTimeInterval AJRDefaultConnectionTimeout;    // The default connection timeout. Set to 120.0 seconds.

// Notifications of client connect / disconnect.
extern NSString * const AJRServerDidConnectClientNotification;
extern NSString * const AJRServerDidDisconnectClientNotification;

// Key used in the user info of the above notifications.
extern NSString * const AJRServerClientNameKey;
extern NSString * const AJRServerClientHostKey;
extern NSString * const AJRServerClientProxyKey;

@class Protocol;

@interface AJRServer : AJRMain <AJRServerProtocol>

- (id)init;

// Returns yes if the server is threaded. This is hard coded, such that a subclass is either threaded or not. It cannot be both. The default value returns NO. However, the AJRServer is implemented to be thread safe in the even that a subclass makes the server multithreaded.
- (BOOL)threaded;

// Set or retrieve the server name. This is set via the command line. If not set by the user, the default value is [self name], which will generally be the name of the running process.
@property (nonatomic,strong) NSString *serverName;

// Changes the default timeout. By default this is equal to AJRDefaultConnectionTimeout, or thirty seconds.
- (void)setConnectionTimeout:(NSTimeInterval)aTimeout;
- (NSTimeInterval)connectionTimeout;

@property (nonatomic,strong) Protocol *serverProtocol;
@property (nonatomic,strong) Protocol *clientProtocol;

- (id)rootObjectForClientConnection:(NSXPCConnection *)aConnection;

// This message is sent when a new connection is created. This allows up to save the child, so that we can monitor our clients, as well as configure the connection properly for threading, if threading is active.
- (BOOL)connection:(NSXPCConnection *)parentConnection shouldMakeNewConnection:(NSXPCConnection *)newConnection;

// Methods used by the client to connect to the server. This allows for server callback to the client to make sure that the connection comes from a trusted host.
- (bycopy NSString *)connectWithName:(NSString *)name hostName:(NSString *)aHostName;

@end


@interface NSConnection (ApplePrivate)

- (void)removePortsFromAllRunLoops;

@end
