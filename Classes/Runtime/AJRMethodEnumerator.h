/*
AJRMethodEnumerator.h
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
