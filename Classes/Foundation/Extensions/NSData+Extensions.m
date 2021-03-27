
#import "NSData+Extensions.h"

#import "AJRFunctions.h"
#import "AJRXMLCoder.h"

@interface AJRXMLDataPlaceholder : NSObject <AJRXMLDecoding>
@property (nonatomic,readonly) BOOL isMutable;
@property (nonatomic,strong) NSData *value;
@end

@implementation AJRXMLDataPlaceholder

- (id)initWithMutableBytes:(BOOL)isMutable {
    if ((self = [super init])) {
        _isMutable = isMutable;
    }
    return self;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeBytesUsingSetter:^(uint8_t *bytes, NSUInteger length) {
        if (self->_isMutable) {
            self->_value = [[NSMutableData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
        } else {
            self->_value = [[NSData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
        }
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    return _value;
}

@end

@implementation NSData (Extensions)

- (void)ajr_dump {
    [self ajr_dumpToStream:AJRStdOut];
}

- (void)ajr_dumpToStream:(NSFileHandle *)stream {
    NSInteger x, y;
    unsigned char c;
    const unsigned char *bytes = [self bytes];
    NSInteger length = [self length];
    
    for (x = 0; x < length; x += 16) {
        AJRFPrintf(stream, @"%06X: ", x);
        for (y = x; y < x + 16; y++) {
            if (y >= length) {
                AJRFPrintf(stream, @"   ");
            } else {
                AJRFPrintf(stream, @"%02X ", bytes[y]);
            }
        }
        for (y = x; y < x + 16; y++) {
            if (y >= length) break;
            c = bytes[y];
            if (c >= 128) c-= 128;
            if (c < 32 || c > 126) c = '.'; 
            AJRFPrintf(stream, @"%c", c);
        }
        AJRFPrintf(stream, @"\n");
    }
}

#pragma mark - AJRXMLCoding

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLDataPlaceholder alloc] initWithMutableBytes:NO];
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeBytes:[self bytes] length:[self length]];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"data";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSData class];
}

@end

@implementation NSMutableData (Extensions)

+ (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder {
    return [[AJRXMLDataPlaceholder alloc] initWithMutableBytes:YES];
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"mutable-data";
}

+ (Class)ajr_classForXMLArchiving {
    return [NSMutableData class];
}

@end
