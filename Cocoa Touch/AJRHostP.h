//
//  AJRHostP.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 4/27/18.
//

#ifndef AJRHostP_h
#define AJRHostP_h

#import <AJRFoundation/AJRHost.h>

NS_ASSUME_NONNULL_BEGIN

// Privately declared for unit testing. Normally these are only used within the AJRHost class.

typedef void (^AJRHostResolutionCompletionBlock)(NSArray * _Nullable names, NSArray * _Nullable addresses, NSError * _Nullable error);

void AJRResolveLocalHost(BOOL wait, AJRHostResolutionCompletionBlock block);
void AJRResolveHostByName(BOOL wait, NSString *hostName, AJRHostResolutionCompletionBlock block);
void AJRResolveHostByAddress(BOOL wait, NSString *address, AJRHostResolutionCompletionBlock block);

// If set to YES, then the next call to resolve a hostname will cause the "getaddrinfo" or "getifaddrs" call to fail. For use by unit/coverage testing.
extern BOOL AJRHostFailNameLookUpForUnitTesting;
extern BOOL AJRHostFailLocalHostNameForUnitTesting;

@interface AJRHost (AJRPrivate)
+ (void)flushHostCache;
@end

#endif /* AJRHostP_h */

NS_ASSUME_NONNULL_END
