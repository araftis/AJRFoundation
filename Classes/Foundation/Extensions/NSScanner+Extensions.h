
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AJRDateSegmentStringType) {
   AJRDateSegmentStringTypeInvalid,
   AJRDateSegmentStringTypeNumeric,
   AJRDateSegmentStringTypeMonth,
   AJRDateSegmentStringTypeDayOfWeek,
};

@interface NSScanner (AJRExtensions)

- (BOOL)scanStringDelimitedBy:(NSString *)delimiter into:(NSString * _Nullable * _Nullable)string;
- (BOOL)scanCommaDelimitedString:(NSString * _Nullable * _Nullable)string;

/*!
 This method scans a segment of a string and attempts to recognize it as a apart of a string. If it's a number, that number is returned, if it's a string, that string is matched against a list of valid months and days and a relavent number is returned if a match can be made. Upon hitting the end of the input, NO is returned.
 
 @param number The numeric value of the date segmentt.
 
 @return YES if a date segment was found, otherwise NO.
 */
- (BOOL)scanDateSegment:(NSInteger *)number;

/*!
 This does the same as above, but also returns the type of string found, or AJRDateSegmentNotAString if a valid date segment could not be derived from the input string. Return NO when the end of the string is encountered.
 
 @param number The numeric value of the date segment.
 @param type The type of date segment scanned.
 
 @return YES if a date segment was found, otherwise NO.
 */
- (BOOL)scanDateSegment:(NSInteger *)number segmentType:(AJRDateSegmentStringType * _Nullable)type;

/*!
 Scans an integer from the string, assuming it's represented in base-8. When returning YES, octal will be initialized to the value. If return NO, the value pointed to by octal will be left alone.
 
 @param octal A pointer to an NSInteger into which to store the octal value.
 
 @returns YES if an octal value was found at the current scan location.
 */
- (BOOL)scanOctalInteger:(NSInteger *)octal;

/*!
 @abstract Scans a point from a string.
 @discussion Scans a point in the form {x, y}, returning NO if no point is found. This makes no assumptions about the validity of <x> or <y> in any coordinate space. You may pass in nil if you just want to scan over a point.

 @param point A pointer to a point that will be initialized if a valid point is scanned. May be nil if you just want to scan over a point.
 
 @returns YES if a point was found in the scanner's string.
 */
- (BOOL)scanPoint:(out CGPoint * _Nullable)point;

/*!
 @abstract Scans a size from a string.
 @discussion Scans a size in the form {width, height}, returning NO if no size is found. This makes no assumptions about the validity of width or height in any coordinate space. You may pass in nil if you just want to scan over a size.

 @param size A pointer to a size that will be initialized if a valid size is scanned. May be nil if you just want to scan over a size.
 
 @returns YES if a size was found in the scanner's string.
 */
- (BOOL)scanSize:(out CGSize * _Nullable)size;

/*!
 @abstract Scans a rect from a string.
 @discussion Scans a rect in the form {{x, y}, {width, height}}, returning NO if no rect is found. This makes no assumptions about the validity of x, y, width , or height in any coordinate space. You may pass in nil if you just want to scan over a rect.

 @param rect A pointer to a rect that will be initialized if a valid rect is scanned. May be nil if you just want to scan over a rect.
 
 @returns YES if a rect was found in the scanner's string.
 */
- (BOOL)scanRect:(out CGRect * _Nullable)rect;

@end

NS_ASSUME_NONNULL_END
