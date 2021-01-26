//
//  NSInputStream+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/26/14.
//
//

#import <Foundation/Foundation.h>

#import <AJRFoundation/AJRStreamUtilities.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInputStream (AJRByteStreamExtensions) <AJRByteReaderMethods, AJRByteStreamMethods>
@end

@interface NSInputStream (Extensions) <AJRByteReader>

#pragma mark - Creation

+ (instancetype)inputStreamWithFileHandle:(int)fileHandle;
+ (instancetype)inputStreamWithStandardInput;

@end

NS_ASSUME_NONNULL_END
