//
//  AJRProtocolMethodEnumerator.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/11/18.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/*! If you call nextObject, the value returned is in terms of a pointer wrapped in an NSValue. As such, the nextMethod method can be nicer to use. */
@interface AJRProtocolMethodEnumerator : NSEnumerator<NSValue *>

+ (instancetype)methodEnumeratorWithProtocol:(Protocol *)enumeratedProtocol;

@property (nullable,nonatomic,strong) Protocol *enumeratedProtocol;

- (nullable struct objc_method_description *)nextMethod;

@property (nonatomic,readonly) BOOL isClassMethod;
@property (nonatomic,readonly) BOOL isRequired;

@end

NS_ASSUME_NONNULL_END
