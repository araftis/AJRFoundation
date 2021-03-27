
#import "NSString+XMLCoding.h"

#import "AJRXMLArchiver.h"
#import "AJRXMLCoder.h"

@interface AJRXMLStringPlaceholder : NSObject <AJRXMLDecoding>
@property (nonatomic,strong) NSString *value;
@end

@implementation AJRXMLStringPlaceholder

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeTextUsingSetter:^(NSString *value) {
        self->_value = value;
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    return _value;
}

@end

@implementation NSString (XMLCoding)

+ (NSString *)ajr_nameForXMLArchiving {
    return @"string";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSString class];
}

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLStringPlaceholder alloc] init];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeText:self];
}

@end
