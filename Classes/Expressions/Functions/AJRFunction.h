//
//  AJRFunction.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 2/5/10.
//  Copyright 2010 A.J. Raftis. All rights reserved.
//

#import <AJRFoundation/AJRFoundationOS.h>
#import <AJRFoundation/AJRPropertyListCoding.h>

@class AJRExpression;

@interface AJRFunction : NSObject <NSCoding, AJRPropertyListCoding>

/*!
 @methodgroup Factory
 */

/*!
 Registers a new class as a function. Note that the class should be a subclass of AJRFunction, and 
 should implement the +name method. Note that no attempt is made to make sure the name is valid or 
 if it's already in use. In the case of two functions with the same name, the last one registered
 wins.
 
 @param functionClass The class to register with the function factory.
 */
+ (void)registerFunction:(Class)functionClass properties:(NSDictionary *)properties;

+ (void)registerFunction:(Class)functionClass;

/*!
 Returns a function class identified by name.
 
 @param functionName The name of the desired function's class.
 
 @result The function class identified by name. Returns nil if the function class is not found.
 */
+ (Class)functionClassForName:(NSString *)functionName;

/*!
 Returns the name of the class. Normally, this method is here for use by the factory and implemented
 by subclasses of AJRFunction to identify themselves. The name is not validated, but should only
 contain letters and numbers, and should begin with a letter.
 
 @result The name of the function.
 */
+ (NSString *)name;

/*!
 @result Simply returns the value of [[self class] name];
 */
- (NSString *)name;

/*!
 Returns the function prototype. This isn't critical, but helps present the user with more comprehensive
 error messages.
 */
+ (NSString *)prototype;

/*!
 @result Simply returns the value of [[self class] prototype];
 */
- (NSString *)prototype;

/*!
 @methodgroup Arguments
 */

/*!
 Returns the array of arguments to the method. A function may have zero or more arguments, but the
 number of arguments is not strictly enforced, although the function may throw an exception during
 evaluation if does not have an expected number of arguments. Each argument may be a number, string,
 collection, or another expression, including another function to be evaluated.
 
 <p>You should not try to add arguments to a function by accessing this array. Use the addArgument:
 method instead.
 */
@property (nonatomic,strong) NSArray<AJRExpression *> *arguments;

/*!
 Adds an argument to a function. The argument may be a number, string, collection, or expression.
 */
- (void)addArgument:(id)argument;

/*!
 @methodgroup Actions
 */

/*!
 Evaluates the functoin based on the arguments and returns the result. The result may be an NSNumber,
 NSString, a collection, or an AJRExpression. The method may throw an exception if it does not find
 a sufficient number of arguments on the stack.
 
 @param object An optional object that may be used to help evaluate expression found as arguments.
 
 @result The result of executing the function.
 */
- (id)evaluateWithObject:(id)object error:(NSError **)error;

/*!
 @methodgroup Utilities
 */

/*!
 Checks the number of arguments and throws and exception if there are not enough arguments present.
 */
- (NSError *)checkArgumentCount:(NSUInteger)count;
- (NSError *)checkArgumentCountMin:(NSUInteger)min;
- (NSError *)checkArgumentCountMin:(NSUInteger)min max:(NSUInteger)max;
- (NSError *)checkArgumentCountMax:(NSUInteger)max;

/*!
 Conveniences for accessing arugments on the stack. You should precheck arguments counts before
 calling these methods, as no bounds checked will be done.
 */
- (NSString *)stringAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error;
- (NSNumber *)numberAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error;
- (BOOL)booleanAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error;
- (NSInteger)integerAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error;
- (double)doubleAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error;
- (id)collectionAtIndex:(NSUInteger)index withObject:(id)object error:(NSError **)error;

@end
