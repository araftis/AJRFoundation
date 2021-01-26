//
//  AJRPlugInExtension.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPlugInExtensionPoint;

@interface AJRPlugInExtension : NSObject

+ (instancetype)extensionWithName:(nullable NSString *)extensionName class:(nullable Class)extensionClass properties:(NSDictionary<NSString *, id> *)properties owner:(AJRPlugInExtensionPoint *)extensionPoint;

@property (nonatomic,weak) AJRPlugInExtensionPoint *extensionPoint; // Gets us our schema.
// NOTE: Will define name, class, or both.
@property (nullable,nonatomic,strong,readonly) NSString *name;
@property (nullable,nonatomic,readonly) Class extensionClass;
@property (nonatomic,readonly) NSDictionary<NSString *, id> *properties;

@end

NS_ASSUME_NONNULL_END
