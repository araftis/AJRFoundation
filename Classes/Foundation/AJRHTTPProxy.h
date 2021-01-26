/*!
 @header AJRHTTPProxy.h

 @author A.J. Raftis
 @updated 1/29/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <AJRFoundation/AJRFoundationOS.h>

@interface AJRHTTPProxy : NSObject 

+ (id)proxyWithHost:(NSHost *)host port:(NSUInteger)port;
+ (id)proxyWithHost:(NSHost *)host port:(NSUInteger)port username:(NSString *)username password:(NSString *)password;
+ (id)proxyWithPAC:(NSString *)pac;
+ (id)proxyWithPAC:(NSString *)pac username:(NSString *)username password:(NSString *)password;

- (id)initWithHost:(NSHost *)host port:(NSUInteger)port;
- (id)initWithHost:(NSHost *)host port:(NSUInteger)port username:(NSString *)username password:(NSString *)password;
- (id)initWithPAC:(NSString *)pac;
- (id)initWithPAC:(NSString *)pac username:(NSString *)username password:(NSString *)password;

@property (nonatomic,strong) NSHost *host;
@property (nonatomic,assign) NSUInteger port;
@property (nonatomic,strong) NSString *pacURL;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *password;

- (NSDictionary *)dictionary;

@end
