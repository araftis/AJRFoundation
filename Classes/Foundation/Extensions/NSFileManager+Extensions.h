
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Extensions)

- (NSString *)temporaryFilename;
- (NSString *)temporaryFilenameForTemplate:(NSString *)template;

@end

NS_ASSUME_NONNULL_END
