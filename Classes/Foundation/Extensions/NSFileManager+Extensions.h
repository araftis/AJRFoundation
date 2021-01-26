//
//  NSFileManager+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 10/17/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Extensions)

- (NSString *)temporaryFilename;
- (NSString *)temporaryFilenameForTemplate:(NSString *)template;

@end

NS_ASSUME_NONNULL_END
