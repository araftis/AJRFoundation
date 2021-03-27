
#import <AJRFoundation/NSData+UU.h>

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSData+Base64.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"
#import "NSObject+AJRUserInfo.h"
#import "NSString+Extensions.h"

#ifdef WIN32
#define strcasecmp stricmp
#define strncasecmp strnicmp
#endif

//static NSArray        *magic = nil;

NSInteger AJRDecodeUUECString(const char *characters, char *decoded, NSError **error);

@implementation NSData (UU)

//                             0000000000111111111122222222223333333333444444444455555555556666
//                             0123456789012345678901234567890123456789012345678901234567890123
//                             ----------------------------------------------------------------
//                             0000000000000000111111111111111122222222222222223333333333333333
//                             0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
const static char *alphabet = "`!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ ";
const static char decodeAlphabet[] = {
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,
    0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,
    0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,
    0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};

- (NSString *)ajr_uuEncodedString {
    return [self ajr_uuEncodedStringWithFilename:nil andPosixFilePermissions:0644];
}

- (NSString *)ajr_uuEncodedStringWithFilename:(nullable NSString *)name {
    return [self ajr_uuEncodedStringWithFilename:name andPosixFilePermissions:0644];
}

- (NSString *)ajr_uuEncodedStringWithFilename:(NSString *)name andPosixFilePermissions:(NSInteger)permissions
{
    const unsigned char *bytes = [self bytes];
    NSInteger x, y, length = [self length];
    unsigned char *coded;
    NSString *header = name ? AJRFormat(@"begin %o %@", (int)permissions, name) : @"begin";
    const char *footer = "\n`\nend\n";
    NSInteger count = 0;
    NSInteger lineLength = 45;
    
    NSInteger mallocLength = ceil((double)length / 3) * 4;
    mallocLength += [header length] + 1; // Length of header + its newline.
    mallocLength += strlen(footer); // Length of our eventually footer.
    mallocLength += (NSInteger)(ceil((double)length / (double)lineLength)) * 2; // And two bytes per line for the line length and newline.
    coded = (unsigned char *)NSZoneCalloc(NULL, mallocLength, sizeof(char));
    
    strcpy((char *)coded, [header UTF8String]);
    y = [header lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    for (x = 0; x < length; x += 3) {
        if (count == 0) {
            coded[y++] = '\n';
            if (x + lineLength >= length) {
                lineLength = length - x;
            }
            coded[y++] = alphabet[lineLength];
        }
        
        unsigned char c1 = bytes[x];
        unsigned char c2 = x + 1 < length ? bytes[x + 1] : 0;
        unsigned char c3 = x + 2 < length ? bytes[x + 2] : 0;
        
        coded[y++] = alphabet[c1 >> 2];
        coded[y++] = alphabet[((c1 << 4) & 060) | ((c2 >> 4) & 017)];
        coded[y++] = alphabet[((c2 << 2) & 074) | ((c3 >> 6) & 03)];
        coded[y++] = alphabet[(c3 & 077)];
        
        count = (count + 3) % lineLength;
    }
    
    strcpy((char *)(coded + y), footer);
    y += strlen(footer);
    
    return [[NSString alloc] initWithBytesNoCopy:(char *)coded length:y encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

+ (instancetype)ajr_dataWithUUEncodedString:(NSString *)string error:(NSError **)error {
    return [[self alloc] ajr_initWithUUEncodedString:string filename:NULL permissions:NULL error:error];
}

+ (nullable instancetype)ajr_dataWithUUEncodedString:(NSString *)string filename:(NSString * _Nullable * _Nullable)filenameIO permissions:(nullable NSUInteger *)permissions error:(NSError * _Nullable * _Nullable)error {
    return [[self alloc] ajr_initWithUUEncodedString:string filename:filenameIO permissions:permissions error:error];
}

- (id)ajr_initWithUUEncodedString:(NSString *)string filename:(NSString **)filenameIO permissions:(NSUInteger *)permissionsIO error:(NSError **)error {
    const char *characters = [string UTF8String];
    char line[1024];
    NSInteger x, y, z;
    char *decoded;
    NSInteger length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    unsigned int permissions = 0;
    NSString *filename = nil;
    NSData *data;
    NSError *localError = nil;
    BOOL hasBegun = NO;
    
    decoded = NSZoneMalloc(nil, (length * 4 / 3) + 20);
    
    z = 0;
    for (x = 0, y = 0; x < length && localError == nil; x++) {
        if (characters[x] == '\n') {
            line[z] = '\0';
            if (strncasecmp(line, "begin ", 6) == NSOrderedSame) {
                char filenameC[1024];
                char scratch[1024];
                
                strcpy(filenameC, "");
                sscanf(line, "begin%[ \t]%o%[ \t]%[^\n]", scratch, &permissions, scratch, filenameC);
                
                filename = [[[NSString stringWithCString:filenameC encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lastPathComponent];
                hasBegun = YES;
            } else if (strcasecmp(line, "end") == NSOrderedSame) {
                x = length; // Cause us to bail the loop.
                continue;
            } else if (hasBegun) {
                y += AJRDecodeUUECString(line, decoded + y, &localError);
            }
            z = 0;
        } else if (characters[x] == '\r') {
            continue;
        } else if (z < 1024) {
            line[z] = characters[x];
            z++;
        }
    }
    
    if (localError) {
        data = nil;
    } else {
        data = [[[self class] allocWithZone:nil] initWithBytes:decoded length:y];
        if (filenameIO) {
            *filenameIO = filename;
        }
        if (permissionsIO) {
            *permissionsIO = permissions;
        }
    }

    if (decoded) {
        NSZoneFree(nil, decoded);
    }

    return AJRAssertOrPropagateError(data, error, localError);
}

@end

NSInteger AJRDecodeUUECString(const char *characters, char *decoded, NSError **error) {
    NSInteger x, y;
    NSInteger length = strlen(characters);
    char c1, c2, c3, c4;
    NSError *localError = nil;
    
    errno = 0;
    
    static NSCharacterSet *alphabetSet = nil;
    static BOOL (*isMemberFunction)(id, SEL, unichar);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alphabetSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCString:alphabet encoding:NSASCIIStringEncoding]];
        isMemberFunction = (BOOL (*)(id, SEL, unichar))[alphabetSet methodForSelector:@selector(characterIsMember:)];
    });
    
    if (characters[0] == '`') return 0;
    
    for (y = 0, x = 1; x < length; ) {
        c1 = characters[x++];
        
        c2 = -1;
        if ((x < length) && isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            c2 = characters[x];
            x++;
        }
        
        c3 = -1;
        if ((x < length) && isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            c3 = characters[x];
            x++;
        }
        
        c4 = -1;
        if ((x < length) && isMemberFunction(alphabetSet, @selector(characterIsMember:), characters[x])) {
            c4 = characters[x];
            x++;
        }
        
        if ((c1 != -1) && (c2 != -1)) {
            decoded[y++] = (decodeAlphabet[(NSInteger)c1] << 2) | (decodeAlphabet[(NSInteger)c2] >> 4);
        } else {
            localError = [NSError errorWithDomain:AJRDataErrorDomain message:@"UUEncoded data was truncated."];
        }
        if (c2 != -1 && c3 != -1) {
            decoded[y++] = (((NSInteger)decodeAlphabet[c2]) << 4) | ((NSInteger)decodeAlphabet[c3] >> 2);
        }
        if (c3 != -1 && c4 != -1) {
            decoded[y++] = (((NSInteger)decodeAlphabet[c3]) << 6) | (NSInteger)decodeAlphabet[c4];
        }
    }
    
    NSInteger expectedLength = decodeAlphabet[(NSInteger)(characters[0])];
    if (y != ceil(expectedLength / 3.0) * 3.0) {
        localError = [NSError errorWithDomain:AJRDataErrorDomain format:@"UUEncoded data was truncated: %s", characters];
    }
    
    if (localError) {
        if (error) {
            *error = localError;
        }
        return -1;
    }
    return expectedLength;
}
