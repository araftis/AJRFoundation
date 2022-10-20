/*
NSMutableURLRequest+Extensions.h
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
