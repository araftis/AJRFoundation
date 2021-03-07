/* NSData-Extensions.h created by alex on Fri 05-Nov-1999 */

#import <AJRFoundation/AJRXMLCoding.h>

@interface NSData (Extensions) <AJRXMLEncoding, AJRXMLCoding>

- (void)ajr_dump;
- (void)ajr_dumpToStream:(NSFileHandle *)stream;

@end

@interface NSMutableData (Extensions) <AJRXMLEncoding>

@end
