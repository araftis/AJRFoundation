//
//  AJRSemaphores.h
//  AJRFoundation
//
//  Created by AJ Raftis on 1/31/19.
//

#ifndef AJRSemaphores_h
#define AJRSemaphores_h

#import <Foundation/Foundation.h>

@protocol AJRSemaphore <NSObject>
    
- (NSInteger)signal;
- (void)wait;
- (BOOL)waitWithTimeout:(NSTimeInterval)timeout NS_SWIFT_NAME(wait(timeout:));

@end

#endif /* AJRSemaphores_h */
