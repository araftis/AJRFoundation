
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
