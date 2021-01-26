//
//  AJRPlugInProperty.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRPlugInAttribute : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *type;
@property (nullable,nonatomic,strong) id defaultValue;
@property (nullable,nonatomic,strong) NSString *rawDefaultValue;
@property (nonatomic,assign) BOOL required;

@end

NS_ASSUME_NONNULL_END
