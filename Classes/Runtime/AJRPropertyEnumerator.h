
#import <Foundation/Foundation.h>

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRPropertyEnumerator : NSEnumerator<NSValue *>

+ (instancetype)propertyEnumeratorWithClass:(Class)enumeratedClass;

@property (nullable,nonatomic,readonly) Protocol *enumeratorProtocol;
@property (nullable,nonatomic,readonly) Class enumeratedClass;
@property (nonatomic,assign) BOOL enumeratesSuperclasses;

- (nullable id)nextObject;
- (nullable objc_property_t)nextProperty;

@property (nonatomic,readonly) BOOL isClassProperty;

@end

NS_ASSUME_NONNULL_END
