//
//  NSInputStream+Extensions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/26/14.
//
//

#import "NSInputStream+Extensions.h"

#import "AJRFunctions.h"
#import "NSError+Extensions.h"
#import "NSString+Extensions.h"

#import <objc/runtime.h>
#import <iconv.h>

extern CFReadStreamRef _CFReadStreamCreateFromFileDescriptor(CFAllocatorRef alloc, int fd);

typedef NSInteger (*AJRReadFunction)(id, SEL, void *, NSInteger);

@implementation NSInputStream (Extensions)

#pragma mark - Creation

+ (id)inputStreamWithFileHandle:(int)fileHandle {
    return CFBridgingRelease(_CFReadStreamCreateFromFileDescriptor(NULL, fileHandle));
}

+ (id)inputStreamWithStandardInput {
    return [self inputStreamWithFileHandle:fileno(stdin)];
}

#pragma mark - AJRByteReader

- (BOOL)readBytes:(void *)buffer length:(size_t)length bytesRead:(out nullable size_t *)readLength error:(out NSError * _Nullable * _Nullable)error {
    NSError *localError = nil;
    NSInteger bytesRead = [self read:buffer maxLength:length];
    BOOL success = bytesRead >= 0;
    
    if (success) {
        AJRSetOutParameter(readLength, bytesRead);
    } else {
        localError = [self streamError];
        if (localError == nil && self.streamStatus != NSStreamStatusOpen) {
            localError = [NSError errorWithDomain:NSCocoaErrorDomain message:@"Stream not open"];
        }
    }
    return AJRAssertOrPropagateError(success, error, localError);
}

@end
