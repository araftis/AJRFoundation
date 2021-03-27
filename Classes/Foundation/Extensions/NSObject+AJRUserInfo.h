
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @abstract Basic method for adding custom user data to classes and objects.
 @discussion Generally speaking, these methods are just slightly nice covers for objc_getAssociatedObject() and objc_setAssociatedObject(), and exist mostly for historical reasons. That being said, they can be slightly more convenient to use, but at the cost of an additional NSString hash / dictionary lookup.
 */
@interface NSObject (AJRUserInfo)

#pragma mark - Class Objects
 
/*!
 Returns a given class object identified by key. Class objects are objects that have been assigned   to a class. In this respect they're similar to class objects in other object oriented languages, but  they do not need to be defined prior to use.
 
 @param key The key identifying the desired object.
 
 @result The value of the obejct for the given key, or nil if no class object is set.
 */
+ (nullable id)classObjectForKey:(NSString *)key;

/*!
 Sets the class object identified by key. Note that a class object is similar to class variables  as found in other object oriented languages, except that it does not need to be defined prior to
 use.
 
 @param object The object to assign. Pass in nil to clear the associated object.
 @param key The key identifying object.
 */
+ (void)setClassObject:(nullable id)object forKey:(NSString *)key;

/*!
Clears all associated class objects from the receiver. After making this call, but before calling setClassObject:forKey:, any call to classObjectForKey: will return nil.
*/
+ (void)clearClassObjects;

#pragma mark - Instance Objects
 
/*!
 Returns an instance object for the given key.
 
 @param key The key identifying the desired object.
 
 @result The value of the object for the given key, or nil if no instance object is set.
 */
- (nullable id)instanceObjectForKey:(NSString *)key;

/*!
 Sets an instance object for the given key. An instance object is any arbitrary object you'd like  to have tag along with another object. The object should respect retain/release. If object is nil,  the object is removed from the receiver.
 
 @param object The object to assign. Pass in nil to clear the associated object.
 @param key A unique identifier for the object.
 */
- (void)setInstanceObject:(nullable id)object forKey:(NSString *)key;

/*!
 Clears all instances objects from the receiver. After making this call, but before calling  setInstanceObject:forKey:, any call to instanceObjectForKey: will return nil.
 */
- (void)clearInstanceObjects;

@end

NS_ASSUME_NONNULL_END
