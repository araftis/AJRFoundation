/*
AJRRuntime.h
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

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

#import <AJRFoundation/AJRVariableEnumerator.h>
#import <AJRFoundation/AJRPropertyEnumerator.h>
#import <AJRFoundation/AJRProtocolMethodEnumerator.h>
#import <AJRFoundation/AJRProtocolPropertyEnumerator.h>
#import <AJRFoundation/AJRProtocolEnumerator.h>
#import <AJRFoundation/AJRMethodEnumerator.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *AJRStringFromEncodedType(const char * const string);
extern NSString *AJRStringFromMethod(Method method, BOOL isClassMethod);
extern NSString *AJRStringFromMethodDescription(struct objc_method_description description, BOOL isClassMethod, BOOL isRequired);
extern NSString *AJRStringFromProperty(objc_property_t property, BOOL isClassProperty);
extern NSString *AJRStringFromVariable(Ivar variable);
extern NSString *AJRStringFromProtocol(Protocol *protocol);

/*! Useful when debugging, but basically this generates a \@interface for the supplied class. Note that the interface may or may not be valid, depending on the types used, so only take the results as a close approximation. For example, the type information on block and function pointers doesn't exist, so any method or property using a block or function pointer will have incomplete types. */
extern NSString *AJRClassInterfaceFromClass(Class classToDump);

extern NSString *AJRStringFromClassSansModule(Class class);

@interface NSObject (SwiftToObjCExceptionHandling)

+ (BOOL)catchException:(void(^)(void))tryBlock error:(NSError * __autoreleasing *)error;
+ (void)ajr_testMethodThatThrowsException; // Used by unit testing

@end

extern const char *AJRPrimitiveMethodSignatureWithTypes(const char *encodedType, ...);

#define AJRMethodSignature(returnType, encodedTypes...) \
    AJRPrimitiveMethodSignatureWithTypes(returnType, @encode(id), @encode(SEL), ## encodedTypes, NULL)

#pragma mark - Method Swizzling & Implementations

extern _Nullable IMP AJRRegisterInstanceMethodWithSelector(Class aClass, SEL oldSelector, SEL newSelector);
/*! Returns the implementation of a class's instance method. This will return implementations on superclasses. */
extern _Nullable IMP AJRGetMethodImplementation(Class class, SEL selector);
/*! Returns the IMP of a method, if and only if instances of the class implement that method. This will return NULL if the implementation is on a superclass. Note this method can be slow, as it must do a linear search through the class' methods. */
extern _Nullable IMP AJRGetMethodImplementationExcludingSuperclass(Class class, SEL selector);
extern _Nullable IMP AJRReplaceMethodImplementation(Class aClass, SEL oldSelector, IMP newImp);
extern _Nullable IMP AJRReplaceMethodImplementationWithSelector(Class aClass, SEL oldSelector, SEL newSelector);

extern void AJRSwizzleMethods(Class originalClass, SEL originalSelector, Class replacementClass, SEL replacementSelector);
extern void AJRSwizzleClassMethods(Class originalClass, SEL originalSelector, Class replacementClass, SEL replacementSelector);

/*!
 This function is similar to [instance isKindOfClass:Class], except that it works on class objets on both sides and it avoids loading and initializing either of the classes pased in. This can be useful when you want to avoid side effects like have a Class' +initialize getting called.
 
 @param class The class to evaluate.
 @param baseClass The class to determine is class matches.
 
 @result YES if class is a subclass of baseClass, NO otherwise.
 */
extern BOOL AJRIsKindOfClass(Class class, Class baseClass);

/*!
 Does much the same as NSClassFromString, but if the class can't be found by it's className, it tries a second time by prepending the module name derived from bundle.
 */
extern _Nullable Class AJRClassFromString(NSString *className, NSBundle * _Nullable bundle);

NS_ASSUME_NONNULL_END
