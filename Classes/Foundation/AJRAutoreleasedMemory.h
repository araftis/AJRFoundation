/*!
 @header AJRAutoreleasedMemory.h
 @abstract Defines a useful class for autoreleasing memory created via NSZoneMalloc().
 @author A.J. Raftis
 */

#import <Foundation/Foundation.h>

/*!
 @class AJRAutoreleasedMemory

 @abstract Allows for the addition of arbitrarily allocated memory to be added to the autorelease pool.
 
 @discussion Allocates and returns a pointer to a block of memory. This is similar to how <EM>malloc()</EM> and related functions work, except that the memory is also added to a container object which is added into the autorelease pool. This allows you to return items from methods or functions which are not objects, but which still conform to Apple's retain/release/autorelease mechanism.
 */

@interface AJRAutoreleasedMemory : NSObject

/*!
 @method autoreleasedMemoryWithCapacity:

 @discussion Returns a block of memory guaranteed to be at least capacity bytes of size. The memory is allocation with NSZoneMalloc from the default allocation zone. Make sure that if you return a pointer generated with this method call from one of your own methods that you document the fact that the data at the memory must be copied to be retained.

 @result Allocated memory which will be freed on the next clean up of the autorelease pool.
 */
+ (void *)autoreleasedMemoryWithCapacity:(NSUInteger)capacity;

+ (void *)autoreleasedMemoryWithCapacity:(NSUInteger)capacity alignment:(size_t)alignment;

@end
