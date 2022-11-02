/*
 NSHost+Extensions.h
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

#import <AJRFoundation/AJRFoundationOS.h>
#import <netdb.h>

#if defined(AJRFoundation_iOS)
#import <AJRFoundation/AJRHost.h>
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * _Nullable AJRAddressToString(struct addrinfo *address);

@interface NSString (AJRHostExtensions)

@property (nonatomic,readonly) BOOL isPossibleIPV4Address;
@property (nonatomic,readonly) BOOL isPossibleIPV6Address;
@property (nonatomic,readonly) BOOL isPossibleIPAddress;

@end

@interface NSHost (Extensions)

/*!
 Examines string and it string only contains decimal digits and '.' characters, then this method calls +[NSHost hostWithAddress:], otherwise it calls +[NSHost hostWithName:]. Note that for efficiency, the results are cached, so for names at least, if the resolution from host to IP address changes, your results could become stale. This should be minimized in that the NSHost object should correct re-resolve itself.
 
 @param string A string containing a host name or address.
 
 @returns The host represented by string, if it can be resolved. Host names may not resolve, in which case nil is returned.
*/
+ (nullable NSHost *)hostWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
