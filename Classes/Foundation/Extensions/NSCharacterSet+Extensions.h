//
//  NSCharacterSet+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/14/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (Extensions)

+ (NSCharacterSet *)ajr_swiftIdentifierStartCharacterSet;
+ (NSCharacterSet *)ajr_swiftIdentifierCharacterSet;

@end

@interface NSMutableCharacterSet (Extensions)

- (void)ajr_addLongCharacter:(UTF32Char)character;
- (void)ajr_addCharactersFrom:(UTF32Char)startCharacter to:(UTF32Char)endCharacter;

@end

NS_ASSUME_NONNULL_END
