/*
AJRAutoreleasedMemory.h
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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
