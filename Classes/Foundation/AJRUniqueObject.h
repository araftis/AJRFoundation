/*!
 @header AJRUniqueObject.h
 @discussion Defines a superclass for singleton objects.
 @author A.J. Raftis
 @copyright 2008 A.J. Raftis. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 @class AJRUniqueObject

 @discussion The AJRUniqueObject creates an object that can only be instantiated once. This is useful for doing things like making a find panel that is visible accross an application. This is behaviour that is similar to the way NeXT's SavePanel or OpenPanel work.

 Basically, AJRUniqueObject overrides the factory method allocWithZone which checks see if the object already exists. If it does, it returns the previously created instance. Otherwise, it creates a new instance of the class and keeps a reference to this class around for later use.

 AJRUniqueObject also overrides the dealloc method. This prevents the basic class from being deallocated, so it'll basically ignore retain/release calls to the class, to you can call this for consistency's sake, but it's unnecessary. You should also make sure that you never write a dealloc method that deallocates any information used by your instance.
 */

@interface AJRUniqueObject : NSObject

+ (id)allocWithZone:(NSZone *)newZone;

@end
