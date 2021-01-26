
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
