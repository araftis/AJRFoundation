
#import <AJRFoundation/NSObject+Extensions.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRTranslator;

typedef void (^AJRObserverBlock)(id object, NSString *keyPath, NSDictionary<NSKeyValueChangeKey, id> * _Nullable change);

@protocol AJRInvalidation <NSObject>

- (void)invalidate;

@end

@interface NSObject (Extensions)

#pragma mark - Miscellaneous

/*!
 This method attempts to copy an instance of an object into an instance of a subclass. This works  by using the NSCoding protocol, and as such, it may not work for all classes. If it does work,  the returned object will be of type subclass, but will contain the same instance variables as the  receiver. Not that the likelyhood is that the instance variables will also be copies of thier  original values.
 
 <p>Frankly, this method probably isn't safe to call except in highly unusual circumstances.
 */
- (nullable instancetype)copyToSubclass:(nullable Class)subclass;

#pragma mark - Reflection

- (BOOL)overridesSelector:(SEL)selector;
+ (BOOL)overridesSelector:(SEL)selector;

#pragma mark - Key/Value Expression

/*!
 Evaluates the expression using the AJRExpression class as the receiver as the object of the  evaluateWithObject: method. Returns the evaluated expression or throws an exception if there's a  problem with the expression syntax.
 */
- (nullable id)valueForKeyExpression:(NSString *)keyExpression;

#pragma mark - Observation

- (id <AJRInvalidation>)addObserver:(id)object forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock)observer;

@end

@interface NSObject (AJRFoundationExtensionsMRR)

- (nullable id)ajr_performSelector:(SEL)aSelector;
- (nullable id)ajr_performSelector:(SEL)aSelector withObject:(nullable id)object;
- (nullable id)ajr_performSelector:(SEL)aSelector withObject:(nullable id)object withObject:(nullable id)object2;

@end

NS_ASSUME_NONNULL_END

