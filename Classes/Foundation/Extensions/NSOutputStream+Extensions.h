//
//  NSOutputStream+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/23/14.
//
//

#import <Foundation/Foundation.h>

#import <AJRFoundation/AJRStreamUtilities.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSOutputStream (AJRByteStreamExtensions) <AJRByteWriterMethods, AJRByteStreamMethods>
@end

@interface NSOutputStream (AJRFoundationExtensions) <AJRByteWriter>

@property (nonatomic,assign) NSStringEncoding encoding;

/*! Returns the data of a memory stream. Returns nil if this isn't a memory stream. */
@property (nonatomic,nullable,readonly) NSData *ajr_data;
/*! Returns the memory stream's data as a string using the supplied encoding.
 @param encoding The desired string encoding.
 */
- (nullable NSString *)ajr_dataAsStringUsingEncoding:(NSStringEncoding)encoding NS_SWIFT_NAME(ajr_dataAsString(using:));

/*! Writes the endian BOM when using unicode string encoding. You should call this once, first, if writing to a unicode string encoding above UTF8. */
- (NSInteger)writeUnicodeBOM;
- (NSInteger)writeIndent:(NSInteger)indent width:(NSInteger)indentWidth;
/*! Writes a C-String to the output file. Note that the string is written litterally, so the expectation is that the string should not contain anything other than basic ASCII characters, although you could safely write a C String pre-encoded to the stream's encoding. */
- (NSInteger)writeCString:(const char *)cString;
- (NSInteger)writeCFormat:(const char *)cFormat arguments:(va_list)args;
- (NSInteger)writeCFormat:(const char *)cFormat, ...;
- (NSInteger)writeData:(NSData *)data;
- (NSInteger)writeString:(NSString *)string NS_SWIFT_NAME(write(string:));
- (NSInteger)writeFormat:(NSString *)format arguments:(va_list)args;
- (NSInteger)writeFormat:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
