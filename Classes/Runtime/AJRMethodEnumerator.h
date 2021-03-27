#ifndef __AJR_METHOD_ENUMERATOR_H__
#define __AJR_METHOD_ENUMERATOR_H__

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRMethodEnumerator : NSEnumerator<NSValue *>

+ (instancetype)methodEnumeratorWithClass:(Class)enumeratedClass;

@property (nonatomic,readonly) Class enumeratedClass;
@property (nonatomic,readonly) Class currentClass; // If we're enumerating superclasses, this is the class currently being enumerated.
@property (nonatomic,assign) BOOL enumerateSuperclasses;

- (nullable id)nextObject;
- (nullable Method)nextMethod;

/*! If the last method returned was a class method, returns YES. */
@property (nonatomic,readonly) BOOL isClassMethod;

@end

NS_ASSUME_NONNULL_END

#endif
