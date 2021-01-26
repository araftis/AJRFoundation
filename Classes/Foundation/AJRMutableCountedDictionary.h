//
//  AJRMutableCountedDictionary.h
//  AJRFoundation
//
//  Created by AJ Raftis on 5/15/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRMutableCountedDictionary<KeyType,ValueType> : NSMutableDictionary

- (NSUInteger)countForKey:(KeyType)key;

@end

NS_ASSUME_NONNULL_END
