
#import "NSAttributedString+Extensions.h"

#import "AJRXMLCoder.h"
#import "AJRFunctions.h"
#import "NSString+Extensions.h"

@interface AJRAttributedStringPlaceholder : NSObject <AJRXMLDecoding>

@property (nonatomic,strong) NSData *data;

@end

@implementation NSAttributedString (Extensions)

- (NSUInteger)wordCount {
    return [[self string] wordCount];
}

- (void)encodeWithXMLCoder:(nonnull AJRXMLCoder *)coder {
    [coder encodeObject:AJRDataFromCodableObject(self) forKey:@"data"];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRAttributedStringPlaceholder alloc] init];
}

@end

@implementation  AJRAttributedStringPlaceholder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeObjectForKey:@"data" setter:^(id  _Nullable object) {
        self->_data = object;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable __autoreleasing *)error {
    return AJRObjectFromEncodedData(_data, error);
}

@end
