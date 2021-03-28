/*
AJRUniqueObject.h
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
