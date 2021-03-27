
#import "NSError+Extensions.h"

#import "AJRFormat.h"
#import "NSNumber+Extensions.h"

@implementation NSError (Extensions)

+ (NSError *)errorWithDomain:(NSString *)domain errorNumber:(int)errorNo {
    return [NSError errorWithDomain:domain code:errorNo userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithCString:strerror(errorNo) encoding:NSUTF8StringEncoding]}];
}

+ (NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message {
    return [NSError errorWithDomain:domain code:-1 userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (NSError *)errorWithDomain:(NSString *)domain format:(NSString *)format arguments:(va_list)ap {
    return [self errorWithDomain:domain message:AJRFormatv(format, ap)];
}

+ (NSError *)errorWithDomain:(NSString *)domain format:(NSString *)format, ... {
    NSError *error;
    va_list ap;
    
    va_start(ap, format);
    error = [self errorWithDomain:domain format:format arguments:ap];
    va_end(ap);
    
    return error;
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)message {
    return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format arguments:(va_list)ap {
    return [self errorWithDomain:domain code:code message:AJRFormatv(format, ap)];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format, ... {
    NSError *error;
    va_list ap;
    
    va_start(ap, format);
    error = [self errorWithDomain:domain code:code format:format arguments:ap];
    va_end(ap);
    
    return error;
}

@end
