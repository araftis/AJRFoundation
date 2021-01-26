/*!
 @header NSMutableURLRequest+Extensions.h

 @author A.J. Raftis
 @updated 1/13/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @abstract Sets and encodes the correct header fields for basic authentication requests via HTTP.
 @discussion Note that you should only use these methods over https connections, because the password is only encoded via base 64 encoding, with no encryption, meaning the password could be easily read over a non-secure connection.
 */
@interface NSMutableURLRequest (Extensions)

/*!
 Sets the user name and password for basic HTTP authentication. Only use this method over an https connection, otherwise the password will be sent in plain text!
 
 @param userName The user name for the request. Pass in nil to remove the header.
 @param password The password for the given userName. Pass in nil if the user doens't have an associated password.
 */
- (void)setBasicAuthorizationForUserName:(nullable NSString *)userName andPassword:(nullable NSString *)password;

/*!
 Sets the user name and password for basic HTTP proxy authentication. Only use this method over an https connection, otherwise the password will be sent in plain text!
 
 @param userName The user name for the request. Pass in nil to remove the header.
 @param password The password for the given userName. Pass in nil if the user doens't have an associated password.
*/
- (void)setBasicProxyAuthorizationForUserName:(nullable NSString *)userName andPassword:(nullable NSString *)password;

@end

NS_ASSUME_NONNULL_END
