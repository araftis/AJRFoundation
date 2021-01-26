
#import <Foundation/Foundation.h>

#define AJR_DEPRECATED(message) __attribute__((deprecated(message)))

#if TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
// Do stuff specific to Mac OS X
#define AJRFoundation_MacOSX
#else
// Do stuff specific to iOS
#define AJRFoundation_iOS
#import <AJRFoundation/AJRHost.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define NSHost AJRHost
#endif
