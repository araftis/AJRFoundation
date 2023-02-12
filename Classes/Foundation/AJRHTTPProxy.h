/*
 AJRHTTPProxy.h
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
