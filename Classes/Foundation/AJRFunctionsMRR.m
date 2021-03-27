
#import "AJRFunctions.h"

/*
 These functions are for debug purposes, and call them in production code could cause memory leaks or other odd behavior. Use with caution.
 */

void AJRForceRetain(id object) {
    [object retain];
}

void AJRForceRelease(id object) {
    [object release];
}

void AJRForceAutorelease(id object) {
    [object autorelease];
}

NSInteger AJRGetRetainCount(id object) {
    return [object retainCount];
}
