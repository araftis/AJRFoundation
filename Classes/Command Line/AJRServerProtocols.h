/* AJRServerProtocols.h created by tsng on Wed 06-Jan-1999 */

#import <Foundation/Foundation.h>

@protocol AJRMainRemoteProtocol <NSObject>

- (NSProcessInfo *)processInformation;
- (NSString *)applicationName;
- (NSString *)applicationPath;
- (NSString *)hostName;
- (NSString *)userName;
- (NSString *)userHomeDirectory;
- (NSDate *)startTime;

- (oneway void)terminateWithExitCode:(int)errorLevel;
- (oneway void)terminate;

@end

@protocol AJRClientProtocol <NSObject>

// This is called when talking to a DO client.
- (void)serverDidConnect:(byref id)aRemoteObject;

@end

@protocol AJRServerProtocol <AJRMainRemoteProtocol>

- (bycopy NSString *)connectWithName:(NSString *)name hostName:(NSString *)aHostName;

- (void)disconnectWithName:(NSString *)name host:(NSHost *)aHost;
- (void)disconnectWithName:(NSString *)name hostName:(NSString *)aHostName;
- (NSString *)serverName;

@end
