
#import "NSCharacterSet+Extensions.h"

@implementation NSCharacterSet (Extensions)

+ (NSCharacterSet *)ajr_swiftIdentifierStartCharacterSet
{
    static NSCharacterSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // See https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html
        NSMutableCharacterSet *buildingSet = [[NSMutableCharacterSet alloc] init];
        [buildingSet ajr_addCharactersFrom:'A' to:'Z'];
        [buildingSet ajr_addCharactersFrom:'a' to:'z'];
        [buildingSet ajr_addLongCharacter:'_'];
        [buildingSet ajr_addLongCharacter:0x00A8];
        [buildingSet ajr_addLongCharacter:0x00AA];
        [buildingSet ajr_addLongCharacter:0x00AD];
        [buildingSet ajr_addLongCharacter:0x00AF];
        [buildingSet ajr_addCharactersFrom:0x00B2 to:0x00B5];
        [buildingSet ajr_addCharactersFrom:0x00B7 to:0x00BA];
        [buildingSet ajr_addCharactersFrom:0x00BC to:0x00BE];
        [buildingSet ajr_addCharactersFrom:0x00C0 to:0x00D6];
        [buildingSet ajr_addCharactersFrom:0x00D8 to:0x00F6];
        [buildingSet ajr_addCharactersFrom:0x00F8 to:0x00FF];
        [buildingSet ajr_addCharactersFrom:0x0100 to:0x02FF];
        [buildingSet ajr_addCharactersFrom:0x0370 to:0x167F];
        [buildingSet ajr_addCharactersFrom:0x1681 to:0x180D];
        [buildingSet ajr_addCharactersFrom:0x180F to:0x1DBF];
        [buildingSet ajr_addCharactersFrom:0x1E00 to:0x1FFF];
        [buildingSet ajr_addCharactersFrom:0x200B to:0x200D];
        [buildingSet ajr_addCharactersFrom:0x202A to:0x202E];
        [buildingSet ajr_addCharactersFrom:0x203F to:0x2040];
        [buildingSet ajr_addLongCharacter:0x2054];
        [buildingSet ajr_addCharactersFrom:0x2060 to:0x206F];
        [buildingSet ajr_addCharactersFrom:0x2070 to:0x20CF];
        [buildingSet ajr_addCharactersFrom:0x2100 to:0x218F];
        [buildingSet ajr_addCharactersFrom:0x2460 to:0x24FF];
        [buildingSet ajr_addCharactersFrom:0x2776 to:0x2793];
        [buildingSet ajr_addCharactersFrom:0x2C00 to:0x2DFF];
        [buildingSet ajr_addCharactersFrom:0x2E80 to:0x2FFF];
        [buildingSet ajr_addCharactersFrom:0x3004 to:0x3007];
        [buildingSet ajr_addCharactersFrom:0x3021 to:0x302F];
        [buildingSet ajr_addCharactersFrom:0x3031 to:0x303F];
        [buildingSet ajr_addCharactersFrom:0x3040 to:0xD7FF];
        [buildingSet ajr_addCharactersFrom:0xF900 to:0xFD3D];
        [buildingSet ajr_addCharactersFrom:0xFD40 to:0xFDCF];
        [buildingSet ajr_addCharactersFrom:0xFDF0 to:0xFE1F];
        [buildingSet ajr_addCharactersFrom:0xFE30 to:0xFE44];
        [buildingSet ajr_addCharactersFrom:0xFE47 to:0xFFFD];
        [buildingSet ajr_addCharactersFrom:0x10000 to:0x1FFFD];
        [buildingSet ajr_addCharactersFrom:0x20000 to:0x2FFFD];
        [buildingSet ajr_addCharactersFrom:0x30000 to:0x3FFFD];
        [buildingSet ajr_addCharactersFrom:0x40000 to:0x4FFFD];
        [buildingSet ajr_addCharactersFrom:0x50000 to:0x5FFFD];
        [buildingSet ajr_addCharactersFrom:0x60000 to:0x6FFFD];
        [buildingSet ajr_addCharactersFrom:0x70000 to:0x7FFFD];
        [buildingSet ajr_addCharactersFrom:0x80000 to:0x8FFFD];
        [buildingSet ajr_addCharactersFrom:0x90000 to:0x9FFFD];
        [buildingSet ajr_addCharactersFrom:0xA0000 to:0xAFFFD];
        [buildingSet ajr_addCharactersFrom:0xB0000 to:0xBFFFD];
        [buildingSet ajr_addCharactersFrom:0xC0000 to:0xCFFFD];
        [buildingSet ajr_addCharactersFrom:0xD0000 to:0xDFFFD];
        [buildingSet ajr_addCharactersFrom:0xE0000 to:0xEFFFD];
        set = [buildingSet copy];
    });
    return set;
}

+ (NSCharacterSet *)ajr_swiftIdentifierCharacterSet
{
    static NSCharacterSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *buildingSet = [[self ajr_swiftIdentifierStartCharacterSet] mutableCopy];
        [buildingSet ajr_addCharactersFrom:'0' to:'9'];
        [buildingSet ajr_addCharactersFrom:0x0300 to:0x036F];
        [buildingSet ajr_addCharactersFrom:0x1DC0 to:0x1DFF];
        [buildingSet ajr_addCharactersFrom:0x20D0 to:0x20FF];
        [buildingSet ajr_addCharactersFrom:0xFE20 to:0xFE2F];
        set = [buildingSet copy];
    });
    return set;
}

@end

@implementation NSMutableCharacterSet (Extensions)

- (void)ajr_addLongCharacter:(UTF32Char)character
{
    [self addCharactersInRange:(NSRange){character, 1}];
}

- (void)ajr_addCharactersFrom:(UTF32Char)startCharacter to:(UTF32Char)endCharacter
{
    [self addCharactersInRange:(NSRange){startCharacter, endCharacter - startCharacter + 1}]; // +1, because we inclusive of the last character
}


@end
