//
//  AJRProtocolPropertyEnumerator.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/11/18.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRProtocolPropertyEnumerator : NSEnumerator

+ (instancetype)propertyEnumeratorWithProtocol:(Protocol *)enumeratedProtocol;

@property (nullable,nonatomic,strong) Protocol *enumeratedProtocol;

- (nullable objc_property_t)nextProperty;

@property (nonatomic,readonly) BOOL isClassProperty;
@property (nonatomic,readonly) BOOL isInstanceProperty;
@property (nonatomic,readonly) BOOL isRequired;
@property (nonatomic,readonly) BOOL isOptional;

@end

NS_ASSUME_NONNULL_END
