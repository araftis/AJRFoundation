/*
NSURL+Extensions.h
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
 @header NSURL+Extensions.h

 @author A.J. Raftis
 @updated 1/8/09.
 @copyright 2009 A.J. Raftis. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Extensions)

- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary<NSString *, NSString *> *)queryDictionary;
- (NSURL *)URLByAppendingQueryValue:(NSString *)query forKey:(NSString *)key;

/*!
  @discussion Parses the query string of the receiver into a dictionary
  @result A dictionary of key-value pairs, or nil if there is no query string for this URL
 */
@property (nonatomic,readonly) NSDictionary<NSString *, NSString *> *queryDictionary;

@property (nullable,nonatomic,readonly) NSString *pathUTI;

/*!
  @discussion Performs a lenient comparison with another URL
  @result YES if the URLs point to the same resource, NO otherwise
 */
- (BOOL)isEqualToURL:(NSURL *)other;

/*!
 @discussion Runs a number of different iterations trying to contruct an URL from the input. In the worst case fallback, returns the user's default search engine.
 @result A new URL created from string.
 */
+ (nullable instancetype)URLWithParsableString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
