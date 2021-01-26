//
//  AJRHost.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/8/12.
//
//

#import <Foundation/Foundation.h>

@class NSString, NSArray, NSMutableArray;

NS_ASSUME_NONNULL_BEGIN

@interface AJRHost : NSObject

+ (AJRHost *)currentHost;
+ (AJRHost *)hostWithName:(NSString *)name;
+ (AJRHost *)hostWithAddress:(NSString *)address;

- (BOOL)isEqualToHost:(AJRHost *)aHost;

@property (nullable,readonly,copy) NSString *name;    // arbitrary choice
@property (readonly,copy) NSArray<NSString *> *names;    // unordered list

@property (nullable,readonly,copy) NSString *address;    // arbitrary choice
@property (readonly,copy) NSArray<NSString *> *addresses;    // unordered list of IPv6 and IPv4 addresses

@property (nullable,readonly,copy) NSString *localizedName;

@end

NS_ASSUME_NONNULL_END
