/*
 NSString+Extensions.h
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#ifndef __NSSTRING_EXTENSIONS__
#define __NSSTRING_EXTENSIONS__

/*!
 @header NSString+Extensions.h
 @discussion Defines a category on NSString
 */

#import <AJRFoundation/AJRFoundationOS.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @category NSString(AJRExtensions)
 @discussion This category provides a number of useful extensions on Apple's NSString implementation.
 */

@interface NSString (AJRExtensions)

#pragma mark - Conveniences

@property (nonatomic,readonly) NSRange fullRange;

#pragma mark - File Paths

/*!
 @returns The associated UTI of the path, assuming it actually has an extension. For example, if you file ends with ".png", this would return "public.png".
 */
@property (nullable,nonatomic,readonly) NSString *pathUTI;
@property (nullable,nonatomic,readonly) NSString *pathMIMEType;

- (NSString *)stringByReplacingPathExtension:(NSString *)newExtension;

- (NSString *)stringWithPathRelativeTo:(NSString *)anchorPath;

@property (nonatomic,readonly) NSString *canonicalizedPath;

- (NSString *)stringByAppendingPathComponents:(NSArray<NSString *> *)components;

#pragma mark - Transformations

/*!
 @abstract Capitalizes the string.
 @discussion Returns the capitalized form of the string. For example, if you pass in the string "capital word", you'll get back the string "Capital word". Note that the method only capitalizes the first word in the string.
 */
- (NSString *)capitalizedName;

@property (nonatomic,readonly) NSString *titlecaseString;

/*!
 @abstract Returns a string where all characters not in set have been removed.
 @discussion This method iterates over the string and removes all characters not in set, returning the resultant set. If the string contains no characters in set, then an empty string is returned.
 
 @return The receive will all characters not in set removed.
 */
- (NSString *)stringContainingOnlyCharactersInSet:(NSCharacterSet *)set;

/*!
 @abstract Removes leading characters in set from the receiver.
 @discussion Returns the string with any leading whitespace removed.
 
 @param characterSet The characters to remove.
 
 @returns The string with the characters removed, if there are any.
 */
- (NSString*)stringByDeletingLeadingCharactersInSet:(NSCharacterSet *)characterSet;

/*!
 @abstract Removes trailing characters in set from the receiver.
 @discussion Returns the string with any trailing whitespace removed.
 
 @param characterSet The characters to remove.
 
 @returns The string with the characters removed, if there are any.
 */
- (NSString*)stringByDeletingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

/*!
 @abstract Wraps a string to a desired width.
 
 @discussion Returns a new string which will be broken into lines not more than <CODE>width</CODE> characters wide. The lines will be split using the supplied <CODE>separator</CODE> string and it will only split URL's if flag it YES. This is intended for spliting strings when the string must be used to output formatter text. Most commonly, this method is used to format strings for HTML output when autogenerating HTML is some manner.
 
 Note that `width` doesn't include the length of `prefix` or `separator`, so if you pass characters other than newline in those, you'll need adjust your width accordingly.
 
 @param width The maximum width of a line of the string.
 @param firstLinePrefix A string to prepend to the first line. If `nil`, then use `prefix`.
 @param prefix A string to prepend to each line, including the first.
 @param separator The string used to separate lines. Note that while this method is intended to divide strings into multiple lines, you can actually split strings by any predefined max width with any given separator, which may or may not contain a newline.
 @param flag If YES, URL's may be split, otherwise the algorithm attempts recognize URL's and it will not split them. Note that if a URL is greater than width, you might get back a line wider than width if you pass is YES.
 
 @return The string potentially split over multiple lines.
 */
- (NSString *)stringByWrappingToWidth:(NSInteger)width firstLinePrefix:(nullable NSString *)firstLinePrefix prefix:(nullable NSString *)prefix lineSeparator:(NSString *)separator splitURLs:(BOOL)flag NS_SWIFT_NAME(byWrapping(to:firstLinePrefix:prefix:lineSeparator:splitURLs:));

/*!
 @abstract Wraps a string to a desired width.
 
 @discussion This method simply calls `[self stringByWrappingToWidth:width prefix:@"" withLineSeparator:separator splitURLs:YES]`.
 
 @param width The maximum width of a line of the string.
 @param separator The string used to separate lines. Note that while this method is intended to divide strings into multiple lines, you can actually split strings by any predefined max width with any given separator, which may or may not contain a newline.
 @param flag If YES, URL's may be split, otherwise the algorithm attempts recognize URL's and it will not split them. Note that if a URL is greater than width, you might get back a line wider than width if you pass is YES.

 @return The string potentially split over multiple lines.
 */
- (NSString*)stringByWrappingToWidth:(NSInteger)width withLineSeparator:(NSString *)separator splitURLs:(BOOL)flag NS_SWIFT_NAME(byWrapping(to:lineSeparator:splitURLs:));

/*!
 @abstract Wraps a string to a desired width.
 
 @discussion This method simply calls `[self stringByWrappingToWidth:width prefix:@"" withLineSeparator:separator splitURLs:YES]`.
 
 @param width The maximum width of a line of the string.
 @param separator The string used to separate lines. Note that while this method is intended to divide strings into multiple lines, you can actually split strings by any predefined max width with any given separator, which may or may not contain a newline.

 @return The string potentially split over multiple lines.
 */
- (NSString *)stringByWrappingToWidth:(NSInteger)width withLineSeparator:(NSString *)separator NS_SWIFT_NAME(byWrapping(to:lineSeparator:));

/*!
 @abstract Wraps a string to a desired width.
 
 @discussion This method simply calls <CODE>[self stringByWrappingToWidth:width withLineSeparator:\@"\n"];</CODE>.
 
 @param width The maximum width of a line of the string.

 @return The string potentially split over multiple lines.
 */
- (NSString *)stringByWrappingToWidth:(NSInteger)width NS_SWIFT_NAME(byWrapping(to:));

/*!
 @abstract Attempts to remove a prefix from a string.
 @discussion If the receiver begins with the string <EM>other</EM>, this returns a new string based on receiver with the prefix specified by <EM>other</EM> deleted.

 @result See discussion.
 */
- (NSString *)stringByDeletingPrefix:(NSString *)other;

- (NSString *)stringByDeletingSuffix:(NSString *)other;

/*!
 Return a new string with the characters in range removed from the receiver.
 @param range the Range of the characters to remove.
 @result See discussion.
 */
- (NSString *)stringByDeletingCharactersInRange:(NSRange)range;

/*!
 @abstract Returns the receiver that contains only the characters from set, where all other characters have been replaced by character.
 
 @discussion Replaces all the characters not in set with character. If character is 0, it is removed instead.
 
 @param set The set of characters to keep.
 @param character The character to replace each character with. If 0, the character is deleted instead.
 
 @returns A string only contain characters in set and character.
 */
- (NSString *)ajr_stringByReplacingCharactersInSet:(NSCharacterSet *)set withCharacter:(wchar_t)character;

#pragma mark - Words

/*!
 @abstract Returns the <EM>n</EM>th word in a string.
 @discussion Returns a word (text surrounded by whitespace) at index. returnRange, if set will contain the range of the word found.
 @param index The index of the word to return.
 */
- (NSString *)wordAtIndex:(NSUInteger)index;

/*!
 @abstract Returns the <EM>n</EM>th word in a string and where it was found.
 @discussion Returns a word (text surrounded by whitespace) at index. returnRange, if set will contain the range of the word found.
 @param index The index of the word to return.
 @param returnRange The character range where the word was found. May be <CODE>NULL</CODE> if you don't care about the range.
 */
- (NSString *)wordAtIndex:(NSUInteger)index range:(nullable NSRangePointer)returnRange;

/*!
 @abstract Returns the count of words in a string.
 @discussion Returns the number of "words" found in the specified range. The words are determined by relatively standard whitespace rules.
 @param range The subrange within the string to scan.
 @result Returns the number of words.
*/
- (NSUInteger)wordCountInRange:(NSRange)range;

/*!
 @abstract Returns the count of words in a string.
 @discussion Calls wordCountInRange: with range equal to {0, [self length]}.
 @result Returns the number of words.
*/
- (NSUInteger)wordCount;

#pragma mark - Substring Searching

/*!
 @abstract Tests a strings prefix in a case insensitive manner.
 @discussion This method is similar to -[NSString hasPrefix], but does the comparison is a case insensitive manner.
 @param prefix The prefix to test.
 @result YES if the receiver starts with prefix, regardless of character case.
 */
- (BOOL)hasCaseInsensitivePrefix:(NSString *)prefix;

- (BOOL)hasCaseInsensitiveSuffix:(NSString *)suffix;

/*!
 @result Returns the first index of the specified substring, or NSNotFound if one was not found
 */
- (NSUInteger)indexOfSubstring:(NSString *)substring;

/*!
 @result Returns a substring of the receiver up until the first index of the specified substring
 */
- (nullable NSString *)substringUpToSubstring:(NSString *)substring;

#pragma mark - HTML

/*!
 @abstract Escapes any special HTML characters in the reciever.
 @discussion Scans the string and replaces any special HTML characters with HTML escape sequences. The returned string will display correctly, with its original characters, in an HTML page.
 */
- (NSString *)stringByEscapingHTML;

/*!
 @abstract Primitive string to HTML conversion.
 @discussion Simply returns the string with newlines replaced by &lt;BR&gt;. This is useful if you want to include a string in html while preserving newlines within the string. This will also replace special HTML characters, '&lt;', '&gt', and '&amp;' with their HTML character entities.
 */
@property (nonatomic,readonly) NSString *htmlString;

/*!
 @abstract Creates a string from a UTF-16 character array.
 @discussion Creates and returns a string created from Unicode-16 charaters. The string must be terminated with a NULL unicode character.
 */
+ (id)stringWithUnicodeString:(unichar *)characters;

/*!
 @abstract Initializes a string from a UTF-16 character array.
 @discussion Initializes a string with the provided null terminate unicode array.
 */
- (id)initWithUnicodeString:(unichar *)characters;

/*!
 @abstract Calls [[NSString alloc] initWIthUnicode32String:].
 */
+ (id)stringWithUnicode32String:(wchar_t *)characters;

/*!
 Creates a string from the null terminated array of wchar_t characters. If the first character is the unicode endian marker, that endianess is used for the bytes, otherwise the endianness of the current architecture is used.
 */
- (id)initWithUnicode32String:(wchar_t *)characters;

/*!
 @abstract Returns a null terminate UTF-16 character array.
 @discussion Returns a null terminated Unicode-16 string. Note that the character array is autoreleased, in that the returned value will not be valid past the next call to -[NSAutoreleasePool drain] in which the character array is created. If you want to keep the value around, you should create a copy.
 */
@property (nonatomic,readonly) unichar *unicodeString;

@property (nonatomic,readonly) wchar_t *unicode32String;

/*!
 @abstract Creates a string with raw bytes, no character encoding enforced.
 @discussion Creates an NSString which the array of bytes is copied into the string with no processing. Eight bit values of 0..255 will be copied directly to the unicode characters 0..255, regardless of their meanings. This can produce undisplayable strings, so should be used only in the situation when you know you have AJRCII data interspersed with 8 bit binary data.
 @param bytes A pointer to a <EM>n</EM> length array of bytes.
 @param length The count of <EM>bytes</EM>.
 @result A newly allocated and autoreleased NSString created in the default allocation zone.
 */
+ (id)stringWithRawBytes:(const unsigned char *)bytes length:(NSUInteger)length;

/*!
 @seealso -stringWithBytes:length:
 @seealso -rawBytes
 @abstract Initializes a string with raw bytes, no character encoding enforced.
 @discussion Initializes a newly created NSString where the array of bytes is copied into the string with no processing. Eight bit values of 0..255 will be copied directly to the unicode characters 0..255, regardless of their meanings. This can produce undisplayable strings, so should be used only in the situation when you know you have AJRCII data interspersed with 8 bit binary data.
 @param bytes A pointer to a <EM>n</EM> length array of bytes.
 @param length The count of <EM>bytes</EM>.
 @result A newly initialized NSString created in the default allocation zone.
 */
- (id)initWithRawBytes:(const unsigned char *)bytes length:(NSUInteger)length;

/*!
 @seealso -stringWithBytes:length:
 @seealso -initWithRawContentsOfFile:
 @seealso -rawBytes
 @abstract Creates a string with the raw contents of a file.
 @discussion Similar to the method <EM>initWithRawBytes:length:</EM>, expect the bytes are read from the contents of <EM>path</EM>.
 @param path A file name which contains the contents of the data to be read.
 @result A newly allocated and autoreleased NSString created in the default allocation zone or <EM>nil</EM> if the file specified by <EM>path</EM> cannot be read for any reason.
 */
+ (nullable id)stringWithRawContentsOfFile:(NSString *)path error:(out NSError * _Nullable * _Nullable)error;
+ (nullable id)stringWithRawContentsOfURL:(NSURL *)url error:(out NSError * _Nullable * _Nullable)error;

/*!
 @seealso -stringWithRawContentsOfFile:
 @seealso -rawBytes
 @abstract Initializes a string with the raw contents of a file.
 @discussion Similar to the method <EM>initWithRawBytes:length:</EM>, expect the bytes are read from the contents of <EM>path</EM>.
 @param path A file name which contains the contents of the data to be read.
 @param error Initialized with any error that occurs. Only initialized if result is <em>nil</em>.
 @result A newly initialized NSString or <EM>nil</EM> if the file specified by <EM>path</EM> cannot be read for any reason.
 */
- (nullable id)initWithRawContentsOfFile:(NSString *)path error:(out NSError * _Nullable * _Nullable)error;
- (nullable id)initWithRawContentsOfURL:(NSURL *)url error:(out NSError * _Nullable * _Nullable)error;

/*!
 @abstract Returns the raw, unsigned char contents of a string, as an NSData.
 @discussion Returns the contents of the string in a format similar to UTF8String, except no advanced processing will take place. You should only call this on strings with characters in the range 0..255. Generally speaking, this method is the converse of <EM>initWithRawBytes:</EM>, and can be used when you know the string may contain 8 bit, binary data, as can sometimes occur when processing foreign data files.
 @result The contents of the strings as an array of unsigned char stored in an NSData, truncated from their unicode values.
 */
- (NSData *)rawData;

/*!
 @abstract Returns the raw unsigned char contents of a string.
 @discussion Returns the contents of the string in a format similar to UTF8String, except no advanced processing will take place. You should only call this on strings with characters in the range 0..255. Generally speaking, this method is the converse of <EM>initWithRawBytes:</EM>, and can be used when you know the string may contain 8 bit, binary data, as can sometimes occur when processing foreign data files.
 @result The contents of the strings as an array of unsigned char, truncated from their unicode values.
 */
- (const unsigned char *)rawBytes;

#pragma mark - OS Error Messages

+ (NSString *)stringWithErrorCode:(int)errorCode;

/*!
 @abstract Return a 10 character random string.
 @discussion Simply a convenience for -[NSString randomStringOfLength:10].
 */
+ (NSString *)randomString;

/*!
 @abstract Returns a random string of a desired length.
 @discussion Generates a random string of character of the provided length. Note that the returned values are not cryptographically secure, as this simply uses the system random number generator and is not purturbed by any other randomizing inputs. The returned value is not guaranteed to be unique.
 */
+ (NSString *)randomStringOfLength:(NSInteger)length;

/*!
 @abstract Generates a random string matching the provided pattern.
 @discussion Creates and returns a random string that matches the provided pattern. The pattern is specified using the following characters:
 
	* #: A numeric digit 0 to 9.
	* A: An uppercase roman character A to Z.
	* a: A lowercase roman character a to z.
	* X: A numeric digit or uppercase roman character 0 to 9 and A to Z.
	* x: A numeric digit or lowercase roman character 0 to 9 and A to Z.
	* @: An upper or lower case roman character, A to Z and a to z.
	* $: An upper or lower case roman character or a number, 0 to 9, A to Z, and a to z.
	* \: Treat the character as a literal.
 
 So, you could pass the pattern @"$$$-$$-$$$" would produe a string "[A-Za-z0-0][A-Za-z0-0][A-Za-z0-0]-[A-Za-z0-0][A-Za-z0-0]-[A-Za-z0-0][A-Za-z0-0][A-Za-z0-0]".
 
 Note that no attempt is made to guarantee that the strings are unique. However, choose a sufficient number of characters should minimize collisions, and a simple check at the generation point can be used to re-ask for a new ID if an ID has already been generated.
 
 @param pattern The input pattern.
 */
+ (NSString *)randomStringUsingPattern:(NSString *)pattern;

/*!
 @abstract Returns an array of comma separated values.
 @discussion Returns an array of strings defines by comma separation. Note that all strings are trimmed unless the leading or trailing whitespace is quoted. Likewise, commas may appear in the results if the value is quoted.
 */
- (NSArray *)commaSeparatedComponents;

/*!
 @abstract Returns an NSData by parsing hexidecimal string value.
 @discussion Returns an NSData from a string compose of hex bytes, ie, "a800f1...". Ignores all characters not 0-9, A-F, or a-f
 
 @return If the receiver is valid hexidecimal, then that data is returned as an NSData object, otherwise nil is returned.
 */
- (nullable NSData *)dataFromHexEncodedString;

#pragma mark - Numeric Conversions

@property (nonatomic,readonly) NSTimeInterval timeIntervalValue;
@property (nonatomic,readonly) long long millisecondsValue;

/*!
 @abstract Returns an appropriate NSNumber representation of the receiver.
 @discussion This method converts the NSString to a number of the appropriate type. If the contents represent an integer value, then the value returned is an integer. If the value contains a decimal, then the returned value if a double. This method will not return boolean values.
 @result An NSNumber representation of the receiver.
 */
@property (nullable,nonatomic,readonly) NSNumber *numberValue;

/*!
 @abstract Attempts to return the base 16 NSUInteger value of the string.
 @discussion Scans the string for valid hexidecimal values and returns the integer those represent. The method stops scanning on the first invalid hexidecimal character. Leading whitespace is ignored.
 */
@property (nonatomic,readonly) NSUInteger hexValue;

/*!
 @abstract Attempts to return the base 16 unsigned long value of the string.
 @discussion Scans the string for valid hexidecimal values and returns the long those represent. The method stops scanning on the first invalid hexidecimal character. Leading whitespace is ignored.
 */
@property (nonatomic,readonly) long longHexValue;
@property (nonatomic,readonly) unsigned long unsignedLongHexValue;

/*!
 @abstract Attempts to return the base 16 unsigned long long value of the string.
 @discussion Scans the string for valid hexidecimal values and returns the long long those represent. The method stops scanning on the first invalid hexidecimal character. Leading whitespace is ignored.
 */
@property (nonatomic,readonly) long long longLongHexValue;
@property (nonatomic,readonly) unsigned long long unsignedLongLongHexValue;

/*!
 @abstract Returns a trailing integer value of the string. Optionally returns the range of the found integer.
 
 @param range The range of the found integer.
 
 @returns The integer value found.
 */
- (NSInteger)trailingIntegerValueFoundInRange:(nullable NSRangePointer)range;

@property (nonatomic,readonly) NSInteger trailingIntegerValue;

- (int32_t)int32ValueUsingBase:(NSInteger)base;
- (uint32_t)unsignedInt32ValueUsingBase:(NSInteger)base;
- (int64_t)int64ValueUsingBase:(NSInteger)base;
- (uint64_t)unsignedInt64ValueUsingBase:(NSInteger)base;

// These are here to make NSString more compatible with NSNumber.
@property (nonatomic,readonly) char charValue;
@property (nonatomic,readonly) unsigned char unsignedCharValue;
@property (nonatomic,readonly) short shortValue;
@property (nonatomic,readonly) unsigned short unsignedShortValue;

// These are here for more precise numeric conversions, when you need to be 100% sure of the number of bits used by the number.
@property (nonatomic,readonly) int8_t int8Value;
@property (nonatomic,readonly) uint8_t unsignedInt8Value;
@property (nonatomic,readonly) int16_t int16Value;
@property (nonatomic,readonly) uint16_t unsignedInt16Value;
@property (nonatomic,readonly) int32_t int32Value;
@property (nonatomic,readonly) uint32_t unsignedInt32Value;
@property (nonatomic,readonly) int64_t int64Value;
@property (nonatomic,readonly) uint64_t unsignedInt64Value;

/*!
 @abstract Returns the base 10 long value of a numeric string.
 @discussion Converts the string to a long value, if possible.
 @result The long value in the string or 0 if no number is found.
 */
@property (nonatomic,readonly) long longValue;

/*!
 @abstract Returns the base 10 unsigned long value of a numeric string.
 @discussion Converts the string to a long value, if possible.
 @result The long value in the string or 0 if no number is found.
 */
@property (nonatomic,readonly) unsigned long unsignedLongValue;

/*!
 @abstract Returns the base 10 long long value of a numeric string.
 @discussion Converts the string to a long value, if possible.
 @result The long value in the string or 0 if no number is found.
 */
@property (nonatomic,readonly) long long longLongValue;

/*!
 @abstract Returns the base 10 unsigned long value of a numeric string.
 @discussion Converts the string to a long value, if possible.
 @result The long value in the string or 0 if no number is found.
 */
@property (nonatomic,readonly) unsigned long long unsignedLongLongValue;

/*!
 @abstract Returns the base 10 NSUInteger value of a numeric string.
 @discussion Parses the string and returns its unsigned integer value.
 */
@property (nonatomic,readonly) unsigned int unsignedIntValue;
@property (nonatomic,readonly) NSUInteger unsignedIntegerValue;

@property (nonatomic,readonly) long double longDoubleValue;

@property (nullable,nonatomic,readonly) NSDate *dateValue;
- (nullable NSDate *)dateValueWithError:(NSError **)error;
- (nullable NSDate *)dateValueWithFormat:(NSString *)format error:(NSError **)error;

@property (nonatomic,readonly) BOOL isInteger;

- (NSString *)stringByCryptingWithSalt:(NSString *)salt;

/*! Returns a NSString created from the non-null terminated c-string of the given length and with the given encoding. */
+ (id)stringWithCString:(const char *)cString length:(NSUInteger)length encoding:(NSStringEncoding)encoding;

@property (nonatomic,readonly) NSString *md5Hash API_DEPRECATED("This function is cryptographically broken and should not be used in security contexts. Clients should migrate to SHA256 (or stronger).", macos(10.4, 10.15), ios(2.0, 13.0));

#pragma mark - UTF32 Character Handling

/*!
 @abstract Fetches the UTF-32 character at position index.
 @discussion Fetches the UTF-32 character at index returning the number of characters used to get the character. Some character will be composed of more than a single unicode UTF-16 character, which is why this method returns a count. So, if the character is say combining accent ` (U+0301) with a (U+0061), then character would be initialized with U+00E1, and the method would return 2. However, the character could also be stored in the string as U+00E1, in which case the same character is returned, but the length returned is 1.
 
 Note that if you need to loop over the string as all of it's UTF-32 character, you might find it better to use -[NSString dataUsingEncoding:NSUTFLittleEndian32StringEncoding], as it will be more efficient to convert the whole string in one go rather than repeatedly converting the string one character at a time, especially since strings are generally stored UTF-8 or UTF-16 encoding, and therefore extra work must be done to convert to UTF-32.
 
 @param character A pointer to the character to be returned.
 @param index The index of the character expressed in the UTF-16 position.
 
 @returns The number of UTF-16 characters used to produce the UTF-32 character.
 */
- (NSInteger)getLongCharacter:(wchar_t *)character atIndex:(NSUInteger)index;

@end

#pragma mark - IANA Name Conversion

extern NSStringEncoding AJRStringEncodingFromIANAName(NSString * _Nullable IANAName);
extern NSString *AJRIANANameFromStringEncoding(NSStringEncoding encoding);

NS_ASSUME_NONNULL_END

#endif
