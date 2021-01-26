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
