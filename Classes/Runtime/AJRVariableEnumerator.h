//
//  AJRVariableEnumerator.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/11/18.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRVariableEnumerator : NSEnumerator<NSValue *>

+ (instancetype)variableEnumeratorWithClass:(Class)enumeratedClass;

@property (nonatomic,readonly) Class enumeratedClass;
@property (nonatomic,assign) BOOL enumerateSuperclasses;

- (nullable Ivar)nextVariable;

/*! If the last method returned was a class method, returns YES. */
@property (nonatomic,readonly) BOOL isClassVariable;

@end

NS_ASSUME_NONNULL_END
