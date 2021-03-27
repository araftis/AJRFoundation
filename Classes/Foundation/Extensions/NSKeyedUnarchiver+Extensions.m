
#import "NSKeyedUnarchiver+Extensions.h"

#import "AJRFunctions.h"
#import "NSError+Extensions.h"

@implementation NSKeyedUnarchiver (Extensions)

+ (id)ajr_unarchivedObjectWithData:(NSData *)data error:(NSError **)error {
    NSError *localError;
    id newObject;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&localError];
    if (unarchiver) {
        unarchiver.requiresSecureCoding = NO;
        newObject = [unarchiver decodeObjectForKey:@"__ROOT__"];
        if (newObject == nil) {
            localError = [NSError errorWithDomain:NSPOSIXErrorDomain message:@"Failed to unarchive object."];
        }
    }

    return AJRAssertOrPropagateError(newObject, error, localError);
}

+ (nullable id)ajr_unarchivedObjectWithPath:(NSString *)path error:(NSError * _Nullable * _Nullable)error {
    NSError *localError = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&localError];
    id object = nil;
    if (data) {
        object = [self ajr_unarchivedObjectWithData:data error:&localError];
    }
    return AJRAssertOrPropagateError(object, error, localError);
}

+ (nullable id)ajr_unarchivedObjectWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    return [self ajr_unarchivedObjectWithPath:[url path] error:error];
}

@end
