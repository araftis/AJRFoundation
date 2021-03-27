
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRClassEnumerator : NSEnumerator

+ (instancetype)classEnumerator;

+ (void)getClasses:(Class _Nonnull * _Nonnull * _Nonnull)array count:(NSUInteger * _Nonnull)count;

- (nullable id)nextObject;
- (nullable Class)nextClass;

@end

extern BOOL AJRClassIsKindOfClass(Class inputClass, Class superclass);
extern NSArray<Class> *AJRClassesInheritingFromClass(Class superclass, BOOL includeSuperclass);

NS_ASSUME_NONNULL_END
