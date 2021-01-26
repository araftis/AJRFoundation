//
//  AJRFileOutputStream.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRStreamErrorDomain;

@interface AJRFileOutputStream : NSOutputStream

+ (instancetype)outputStreamWithFileDescriptor:(int)fileHandle;
+ (instancetype)outputStreamWithFileDescriptor:(int)fileHandle closeOnDeallocate:(BOOL)closeOnDeallocate;
+ (instancetype)outputStreamWithFile:(FILE *)file;
+ (instancetype)outputStreamWithFile:(FILE *)file closeOnDeallocate:(BOOL)closeOnDeallocate;

@property (nonatomic,assign) BOOL closeOnDeallocate;

@end

NS_ASSUME_NONNULL_END
