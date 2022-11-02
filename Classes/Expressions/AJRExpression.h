/*
 AJRExpression.h
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

#import <AJRFoundation/AJRFoundationOS.h>
#import <AJRFoundation/AJRPropertyListCoding.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRExpressionErrorDomain;

@interface AJRExpression : NSObject <NSCoding, AJRPropertyListCoding>

// Creating a expression
+ (instancetype)expressionWithExpressionFormat:(NSString *)format, ...;
+ (instancetype)expressionWithExpressionFormat:(NSString *)format arguments:(va_list)args;

@property (nonatomic,assign) BOOL protected;

/*!
 Used by AJROperator to evaluate their values.
 */
+ (id)evaluateValue:(id)value withObject:(id)object error:(NSError * _Nullable * _Nullable)error;

/*!
 Evaluates the expression based on the object passed in. Many expression will actually ignore object,
 but since we support the idea of key/value coding, we pass in object as the root object on which
 we can call valueForKeyPath:
 
 @param object An option object. If supplied, the object may be accessed via key/value coding, but
               only for read access. Basically, object can be used to supply variables into the 
               expression being evaluated.
 @param error If an error occurs while evaluating the expression, error contains the error.
 
 @result The result of evaluated the expression, which could be another expression or a basic type.
 */
- (nullable id)evaluateWithObject:(nullable id)object error:(NSError * _Nullable * _Nullable)error;

- (BOOL)isEqualToExpression:(AJRExpression *)other;

/*!
 Creates an expression from the supplied dictionary.
 */
+ (nullable instancetype)expressionForDictionary:(NSDictionary *)dictionary error:(NSError * _Nullable * _Nullable)error;
/*!
 Parses the supplied string and creates a new expression that can be evaluated.
 */
+ (nullable instancetype)expressionWithString:(NSString *)string error:(NSError * _Nullable * _Nullable)error;
/*!
 Examines anObject and calls either expressionForDictionary: or expressionForString:, as appropriate.
 */
+ (nullable instancetype)expressionForObject:(id)anObject error:(NSError * _Nullable * _Nullable)error;
/*!
 Returns the expression as a property list.
 */
- (NSDictionary *)propertyListValue;

/*!
 @methodgroup Utilities
 
 @discussion These methods are used by various classes in the expression subsystem to convert input
 values into basic types which can be more easily manipulated.
 */

/*!
 @discussion Evaluates the "value" until it stops being an expression and becomes a constant.
 
 @param value The value to convert.
 @param object An option object used to help evaluate expressions.
 
 @result The result of the evaluated expression, or value, if it's not an expression.
 */
+ (nullable id)value:(nullable id)value withObject:(nullable id)object error:(NSError **)error;

/*!
 Converts the input to a collection. value is analyzed, and if it's an expression, the expression
 is evaluated until a "simple" type is returned. Once we have a simple type, that is then examined.
 If the type is already a collecton, the collection is returned. Otherwise, a simple set is returned
 containing one value, value.
 
 <p>Note that for our purposes, a collection is a set, array, or map (dictionary).
 
 @param value The value to convert.
 @param object An option object used to help evaluate expressions.
 
 @result A value that will be some kind of collection.
 */
+ (nullable id)valueAsCollection:(nullable id)value withObject:(nullable id)object error:(NSError **)error;

/*!
 Converts the input to an NSNumber, if possible. If the input value cannot be evaluated to a number,
 an exception is thrown.
 
 @param value The value to convert.
 @param object An option object used to help evaluate expressions.
 
 @result An NSNumber representation of value.
 
 @throw An exception if the value cannot be converted to a number.
 */
+ (nullable id)valueAsNumber:(nullable id)value withObject:(nullable id)object error:(NSError **)error;

/*!
 Converts value to a string. This basically just returns value's description, except when value is
 an expression, in which case expression is evaluated with object until a basic type is returned, 
 at which time its description is returned.

 @param value The value to convert.
 @param object An option object used to help evaluate expressions.
 
 @result An NSString representation of value.
 */
+ (nullable id)valueAsString:(nullable id)value withObject:(nullable id)object error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
