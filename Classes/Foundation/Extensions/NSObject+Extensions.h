/*
NSObject+Extensions.h
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

