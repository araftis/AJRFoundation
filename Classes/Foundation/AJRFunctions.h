/*
AJRFunctions.h
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

#import <AJRFoundation/AJRFoundationOS.h>

#import <AJRFoundation/NSString+Extensions.h>

NS_ASSUME_NONNULL_BEGIN

extern NSFileHandle *AJRStdErr;
extern NSFileHandle *AJRStdOut;
extern NSFileHandle *AJRStdIn;

extern NSString * const AJRDateErrorDomain;

typedef NS_ENUM(uint32_t, AJRDateErrorCode) {
    AJRDateErrorCodeInvalidFormat = 10000,
    AJRDateErrorCodeDayOutOfRange,
    AJRDateErrorCodeMonthOutOfRange,
    AJRDateErrorCodeNoValidDate,
};

@class NSInvocation;

// Used to make sure we can reference "self" and "_cmd" from macros.
#ifndef AJR_SHARED_OPAQUE_AJRSERT_STRUCT
#define AJR_SHARED_OPAQUE_AJRSERT_STRUCT _AJROpaqueAssertStruct
#endif
extern const struct AJR_SHARED_OPAQUE_AJRSERT_STRUCT _cmd;
extern const struct AJR_SHARED_OPAQUE_AJRSERT_STRUCT self;

extern void AJRVFPrintf(NSFileHandle * _Nullable fileHandle, NSString * _Nullable format, va_list ap);
extern void AJRVPrintf(NSString * _Nullable format, va_list ap);
extern void AJRFPrintf(NSFileHandle * _Nullable stream, NSString * _Nullable format, ...);
extern void AJRPrintf(NSString * _Nullable format, ...);

/*!
 This function takes an attribute name as its parameter and returnes a pretty printed version.  The first letter is capitialized and a space is placed in front of the beginning of each string of capital letters. Ex: lastName => Last Name
 
 @param key A key expressed in camel case.
 
 @result The key cleaned up to be "pretty".
 */
extern NSString * _Nullable AJRPrettyPrintKey(NSString *key);

/*!
 Returns the value for the given environment variable. Attempts to do so in a case insensitive manner, but this means if two environment variables exist, but only differ by case, then the incorrect value could be returned. Generally, only use this where the behavior of inconsistent environment variable definitions have been exhibited.
 
 @param variable The name of the environment variable to find.
 
 @result The value of the environment variable, or nil if a value couldn't be found.
 */
extern NSString * _Nullable AJRGetEnvironmentVariable(NSString *variable);

/*!
 Searches the PATH for the given executable.  If it is found then the full path including the executable is returned, otherwise nil is returned.
 
 @param executableName The name of the executable to find.
 
 @result The full path to the executable.
 */
extern NSString *AJRFindExecutable(NSString *executableName);

extern NSString *AJRStringFromRect(CGRect rect);
extern NSString *AJRStringFromSize(CGSize rect);
extern NSString *AJRStringFromPoint(CGPoint rect);
extern CGRect AJRRectFromString(NSString *string);
extern CGSize AJRSizeFromString(NSString *string);
extern CGPoint AJRPointFromString(NSString *string);

extern NSString* AJRBadObjectVersionException;

#define AJRFunctionName() [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]
#define AJRMethodName() [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]

#define AJRBadObjectVersionFormat @"Class %@: Unable to unarchive due to old version.", NSStringFromClass([self class])

extern NSDate *AJRDateFromMonthDayAndYear(NSCalendar * _Nullable calendar, NSInteger month, NSInteger day, NSInteger year);
extern NSInteger AJRYearDerivedFromYearWithoutCentury(NSInteger inputYear, NSInteger currentYear);
extern NSDate * _Nullable AJRDateFromString(NSString *string, NSCalendar * _Nullable calendar, NSError * _Nullable * _Nullable error);
extern NSDate * _Nullable AJRDateFromStringAndFormat(NSString *string, NSString * _Nullable format, NSCalendar * _Nullable calendar, NSError * _Nullable * _Nullable error);

/*!
 Converts a number to a string using the string of supplied digits. You may also include a separator character. The base of the conversion is determined by the number of digits in `digits`, so using "0123456789" would basically do a base 10 conversion where as "0123456789ABCDEF" would do a base 16 conversion.
 
 This method is mostly used by fraction conversion in order to pass in the set of superscript or subscript numbers used to create unicode fractions.
 
 Note that no attempt is made to validate `digits`, so if you pass in repeating digits, the output will be somewhat undefined.
 
 @param number The number to convert.
 @param digits The string of digits. The number of digits represents the base of the conversion.
 @param separator The string to use as a separator every three digits.
 
 @return A string representing the input number using the supplied digits.
 */
extern NSString *AJRNumberToString(long long number, NSString *digits, wchar_t separator);

extern double AJRWholeNumberWithNumeratorAndDenominatorFromDouble(double input, double minimumDenominator, double *numeratorOut, double *denominatorOut);

/*!
 Rounds input to it's nearest fractional value. So, for example, if you pass in 0.51 and 4, this woudl return 0.5, as that's the nearest "quarter" value.

 @param input The doubel to round.
 @param minimumDenominator The minimum denominator. Think of this as fractions. If you want to expression input in say quater inches, you'd pass in 4. If you want to expression 32nd of an inch, you'd pass in 32.

 @return input rounded to the value that could be represented by a fraction with the minimumDenominator.
 */
extern double AJRRoundToNearestFraction(double input, double minimumDenominator);

/*!
 Converts a double into a fraction. Generally speaking, this function will only work with minimumDenominators that are 2^n. It's designed to return Imperial fractions for measurement. In other words, 1/2, 1/64, 3/32, etc... 
 
 @param input The double to convert to a fraction.
 @param minimumDenominator The smallest denominator we want to see. This must be a power of 2.
 
 @result A string in the form of "whole denominator/numerator". For example, calling AJRFractionFromDouble(2.5, 64.0) would return a string "2 1/2".
 */
extern NSString *AJRFractionFromDouble(double input, double minimumDenominator);

extern NSString * _Nullable AJRApplicationCachePath(void);
extern NSURL * _Nullable AJRApplicationCacheURL(void);
extern NSString * _Nullable AJRDocumentsDirectoryPath(void);
extern NSURL * _Nullable AJRDocumentsDirectoryURL(void);
extern NSURL * _Nullable AJRHomeDirectoryURL(void);
extern NSString * _Nullable AJRApplicationSupportPath(void);
extern NSURL * _Nullable AJRApplicationSupportURL(void);

/*!
 A slightly smarted equal operation for objects. Basicaly, if left is nil && right is nil, YES. If left is nin && right != nil, NO. If left != nil && right is nil, NO. Else, if left & right != nil, then [a isEqual:b].

 @param left The left value.
 @param right The right value.

 @returns YES if the values are equal, as returned by isEqual:, or YES if both values are nil. Returns NO otherwise.
 */
extern BOOL AJREqual(id _Nullable left, id _Nullable right);

/*!
 Compares two values using compare:, accounting for the possibility of left or right being nil. Nil values are sorted ahead of non-nil values.

 @param left The left value.
 @param right The right value.

 @returns The order of the objects. Note that if left is nil, and right is not, then NSOrderedAscending is returned. If left is !nil and right is nil, then NSOrderedDescending is returned. If left and right are nil, then NSOrderedSame is returned. Otherwise, the result of calling [left compare:right] is returned.
 */
extern NSComparisonResult AJRCompare(id _Nullable left, id _Nullable right);

/*!
 Compares two values using the provided selector., accounting for the possibility of left or right being nil. Nil values are sorted ahead of non-nil values.

 @param left The left value.
 @param right The right value.
 @param selector The selector to use in the comparison. If NULL is passed, then uses @selector(compare:).

 @returns The order of the objects. Note that if left is nil, and right is not, then NSOrderedAscending is returned. If left is !nil and right is nil, then NSOrderedDescending is returned. If left and right are nil, then NSOrderedSame is returned. Otherwise, the result of calling [left compare:right] is returned.
 */
extern NSComparisonResult AJRCompareUsingSelector(id _Nullable left, id _Nullable right, SEL _Nullable selector);

/*!
 Returns a hash value for a 32 bit value.

 @param input The value to hash.

 @return input's hash value.
 */
extern uint32_t AJRHash32(uint32_t input);

/*!
 Returns a hash value for a 64 bit value.

 @param input The value to hash.

 @return input's hash value.
 */
extern uint64_t AJRHash64(uint64_t input);

/*!
 Compares to doubles and checks that they're equal to the number of places requested. This is often useful when comparing floating point values, especially after values may have passed through a textual representation, as that can often lead to rounding errors due to the problematic nature of encoding floating point values.

 @param left The left value.
 @param right The right value.
 @param places The number of significant places.

 @return YES if the values are equal to the number of place.
 */
extern BOOL AJRApproximateEquals(double left, double right, NSInteger places);

/*!
 Rounds input to the number of places provided. This uses standard floating point rounding behavior, as provided by round().

 @param input The number to round.
 @param places The number of places to round to.

 @return input rounded to places.
 */
extern double AJRRoundToPlaces(double input, int places);

/*!
 Computes the Greatest Common Deominator of a and b. So, say you have had an image with the dimensions 1000 x 1500. This method would return 500, which you could then use to display the aspect ratio of the image as 2:3. If the values don't share a common denominator, this function returns 1.

 @param a The numerator.
 @param b The denonminator.

 @return The GCD of a and b.
 */
extern NSInteger AJRComputeGCD(NSInteger a, NSInteger b);

/*!
 Used in method that return a value by reference. Checks that pointer if not nil, and if it's not, assigns value to *pointer.

 @param pointer The pointer to a value, or NULL.
 @param value The value to assign.
 */
#define AJRSetOutParameter(pointer, value) do { \
        if ((pointer)) { \
            *(pointer) = (value); \
        } \
    } while(0)

#pragma mark - Assertions

extern void _AJRHandleAssertion_impl(volatile const void *owner, NSString *functionOrMethod, NSUInteger lineNumber, NSString *expression, NSString *format, ...);
extern void _AJRHandleSoftAssertion_impl(volatile const void *owner, NSString *functionOrMethod, NSUInteger lineNumber, NSString *expression, NSString *format, ...);

#define AJRAssert(condition, desc, ...)    \
    do {                \
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (__builtin_expect(!(condition), 0)) {        \
            NSString *__ajrsert_file__ = [NSString stringWithUTF8String:__FILE__]; \
            __ajrsert_file__ = __ajrsert_file__ ? __ajrsert_file__ : @"<Unknown File>"; \
            _AJRHandleAssertion_impl(&self, __ajrsert_file__, __LINE__, @#condition, desc, ##__VA_ARGS__); \
        }                \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#define AJRSoftAssert(condition, desc, ...)    \
    do {                \
        __PRAGMA_PUSH_NO_EXTRA_ARG_WARNINGS \
        if (__builtin_expect(!(condition), 0)) {        \
            NSString *__ajrsert_file__ = [NSString stringWithUTF8String:__FILE__]; \
            __ajrsert_file__ = __ajrsert_file__ ? __ajrsert_file__ : @"<Unknown File>"; \
            _AJRHandleSoftAssertion_impl(&self, __ajrsert_file__, __LINE__, @#condition, desc, ##__VA_ARGS__); \
        }                \
        __PRAGMA_POP_NO_EXTRA_ARG_WARNINGS \
    } while(0)

#define AJRObjectIfKindOfClass(object, possibleClass) ((possibleClass *)([(object) isKindOfClass:[possibleClass class]] ? (object) : nil))

#define AJRObjectIfKindOfClassOrAssert(object, possibleClass) ({ \
        possibleClass *__returnValue = (possibleClass *)([(object) isKindOfClass:[possibleClass class]] ? (object) : nil); \
        AJRAssert(__returnValue != nil, @"Object %@ isn't kind of class %@", (object), NSStringFromClass([possibleClass class])); \
        __returnValue; \
    })

#define AJRObjectIfKindOfClassOrNilOrAssert(object, possibleClass) ({ \
        if (object == nil) return nil; \
        possibleClass *__returnValue = (possibleClass *)([(object) isKindOfClass:[possibleClass class]] ? (object) : nil); \
        AJRAssert(__returnValue != nil, @"Object %@ isn't kind of class %@", (object), NSStringFromClass([possibleClass class])); \
        __returnValue; \
    })

#define AJRObjectIfConformsToProtocol(object, possibleProtocol) (id <possibleProtocol>)([(object) conformsToProtocol:@protocol(possibleProtocol)] ? (object) : nil)

#define AJRObjectIfConformsToProtocolOrAssert(object, possibleProtocol) ({ \
        id <possibleProtocol> __returnValue = (id <possibleProtocol>)([(object) conformsToProtocol:@protocol(possibleProtocol)] ? (object) : nil); \
        AJRAssert(__returnValue != nil, @"Object %@ doesn't conform to protocol %@", (object), @#possibleProtocol); \
        __returnValue; \
    })

#define AJRObjectIfConformsToProtocolOrNilOrAssert(object, possibleProtocol) ({ \
        if (object == nil) return nil; \
        id <possibleProtocol> __returnValue = (id <possibleProtocol>)([(object) conformsToProtocol:@protocol(possibleProtocol)] ? (object) : nil); \
        AJRAssert(__returnValue != nil, @"Object %@ doesn't conform to protocol %@", (object), @#possibleProtocol); \
        __returnValue; \
    })

#define AJRAssertOrPropagateError(value, error, localError) ({ \
        __typeof__(value) __returnValue = (value); \
        AJRAssert(((localError) != nil && __returnValue == (__typeof__(value))0) || ((localError) == nil), @"localError must be nil if value != nil"); \
        if ((localError) != nil) { \
            if (error) { \
                *(error) = (localError); \
            } \
        } \
        __returnValue; \
    })

#define AJRAbstract(value) ({ \
        AJRAssert(NO, @"Abstract method -[%@ %@] should be implemented", NSStringFromClass([self class]), NSStringFromSelector(_cmd)); \
        value; \
    })

#define AJRAssertUnreachable(message,...) \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:AJRFormat(@"We reached code we shouldn't have reached in %s: %@", __FUNCTION__, AJRFormat(message, __VA_ARGS__)) userInfo:NULL];

#pragma mark - Range Functions

/*!
 Checks to see if two ranges overlap.

 @param a One of the ranges.
 @param b The other range.

 @return YES if the two ranges overlap, NO otherwise.
 */
extern BOOL AJRRangeIntersect(NSRange a, NSRange b);

#pragma mark - Unique ID

/*!
 Returns a semi-unique ID. Generally, this will be good for a number of things, but not necessarily everything. For example, we use it to generate IDs during XML archiving. In this case, because the name spaces is sufficiently large, it's highly unlikely that two generated ID's will ever be the same. That being said, duplicate IDs could be generated, so keep that in mind.

 @return A semiunique ID.
 */
extern NSString *AJRSemiuniqueIdentifier(void);

#pragma mark - File Types

/*!
 Looks up the associate UTI for the given file extension. If the extension is the empty string, nil will be returned, or if there is no associated UTI, a dynamically generated system UTI will be returned. This latter case means the UTI will have the prefix "dyn.".
 
 @returns The associated UTI of the path, assuming it actually has an extension. For example, if you file ends with ".png", this would return "public.png".
*/
extern NSString * _Nullable AJRUTIForPathExtension(NSString *extension);

#pragma mark - Misc

/*!
 The bundle used by the AJRFoundation framework.

 @return The framework's bundle.
 */
extern NSBundle *AJRFoundationBundle(void);

/*!
 Copies an NSCodable object. Optionally, the decoded class can be decodedClass. This is useful for say promoting an object to a subclass.

 @param object The object to copy.
 @param decodedClass The class to decode into. If not nil, decodedClass should be a subclass of object's class.

 @return The copied object. May return nil if the object couldn't be copied.
 */
extern id _Nullable AJRCopyCodableObject(id <NSCoding> object, _Nullable Class decodedClass);

/*!
 Encodes an object into an NSData that can later be decoded with AJRObejctFromEncodedData(). Note that this makes use of non-secure coding.

 @param object The object to encode.

 @return The encoded data, or nil if the object couldn't be encoded. This can happen, for example, if a collection object contains non-encodable objects.
 */
extern NSData  * _Nullable AJRDataFromCodableObject(id <NSCoding, NSObject> object);

/*!
 Decodes the object in data created via AJRDataFromCodableObject().

 @param data The data containing the object.
 @param error An error that occurred. If error is set, the function will return nil. You may pass nil if you don't care about the specifiic error.

 @return The decoded object. If nil, error will be set.
 */
extern id _Nullable AJRObjectFromEncodedData(NSData *data, NSError * _Nullable * _Nullable error);

#if defined(__clang__)
#define AJR_NO_RETURN __attribute__((analyzer_noreturn))
#define AJR_UNUSED __attribute__((unused))
#else
#define AJR_NO_RETURN
#define AJR_UNUSED
#endif

#define AJR_IS_BIG_ENDIAN ((*(uint16_t *)"\0\xff" < 0x100) != 0)
#define AJRUTF32StringEncodingMatchingArchitecture (AJR_IS_BIG_ENDIAN ? NSUTF32BigEndianStringEncoding : NSUTF32LittleEndianStringEncoding)

/**
 For an array allocated with [], this returns it's count.
 */
#define AJRCountOf(stackarray) (sizeof(stackarray)/sizeof(stackarray[0]))

#pragma mark - Dispatch

void AJRRunAsyncOnMainThread(void (^block)(void));
void AJRRunSyncOnMainThread(void (^block)(void));
void AJRRunAfterDelay(NSTimeInterval delay, void (^block)(void));

#pragma mark - Bit Manipulation

#define AJRSetBit(mask, bit, flag) ((flag) ? ((mask) | (bit)) : ((mask) & ~(bit)))

#pragma mark - MRR Functions

/*!
 @abstract Forced a retain on an object.
 @discussion This function is the equivalent of calling [object retain]. This is potentially dangerous in ARC code, as you can easily introduce an extra retain onto an object, preventing it from ever being released. Of course you call the AJRForceRelease() or AJRForceAutorelease(), but those come with their own dangers.
 
 So why is this function here? Well, in short, there's a bug in the handling of NSButtonCell and how it copies it's internal ivars. Basically, if you copy a button cell, it'll miscopy some of it's ivars, causing an under-retain and a subsequent crash somewhere down the line when you try to reference your cell. To work around this, I introduced this function which forces an extra retain on some of the internal objects, thus putting the retain count back to where it should be. This code may have to be updated if Apple fixes the bug in NSButtonCell, but that's probably unlikely.
 
 @param object The object to retain.
 */
extern void AJRForceRetain(id object);
extern void AJRForceRelease(id object);
extern void AJRForceAutorelease(id object);

/*!
 @abstract Returns the object's retain count.
 @discussion This method returns the object's retain count and is here mostly for the purposes of debugging and unit testing. This code is likely unreliable in production situation, since the compile controls the retain count, and you can't control whether or not the compiler writers decide to add or remove extra retain/releases on the objects being passed around.
 
 For example, you'd never want to do something like:
 
 <code>
 while (AJRGetRetainCount(object) > 0) {
    AJRForceRelease(object);
 }
 </code>
 
 As this would almost certainly cause a crash under ARC.
 
 @param object The object on which to retreive the retain count.
 */
extern NSInteger AJRGetRetainCount(id object);

NS_ASSUME_NONNULL_END



