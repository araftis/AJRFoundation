
#import <Foundation/Foundation.h>

@interface NSError (Extensions)

+ (NSError *)errorWithDomain:(NSString *)domain errorNumber:(int)errorNo;

+ (NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message;
+ (NSError *)errorWithDomain:(NSString *)domain format:(NSString *)format arguments:(va_list)ap;
+ (NSError *)errorWithDomain:(NSString *)domain format:(NSString *)format, ...;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)message;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format arguments:(va_list)ap;
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code format:(NSString *)format, ...;

@end
