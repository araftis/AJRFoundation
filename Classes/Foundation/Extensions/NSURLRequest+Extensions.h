
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (Extensions)

/*!
 Returns a string describing the request in "long" form, or generally how the request would look when making an actual URL request.
 
 @return A long description of the request, useful when you want to see what would be posted to the remote service.
 */
@property (nonatomic,readonly) NSString *longDescription;

@end

NS_ASSUME_NONNULL_END
