
#import "NSURLRequest+Extensions.h"

#import "AJRFunctions.h"

@implementation NSURLRequest (Extensions)

- (NSString *)longDescription {
    NSMutableString *string = [[NSMutableString alloc] init];
    NSDictionary *headers = [self allHTTPHeaderFields];
    NSURL *URL = [self URL];
    NSData *content;
    NSString *contentAsString = nil;
    
    [string appendFormat:@"%@ %@ HTTP/1.1\r\n", [self HTTPMethod], [URL absoluteString]];
    for (NSString *key in headers) {
        id value = [headers objectForKey:key];
        [string appendFormat:@"%@: %@\r\n", key, value];
    }
    [string appendString:@"User-Agent: AJRFoundation/"];
    [string appendString:AJRFoundationBundle().infoDictionary[@"CFBundleVersion"]];
    [string appendString:@"\r\n"];
    if ([URL host]) {
        [string appendString:@"Host: "];
        [string appendString:[URL host]];
        if ([URL port]) {
            [string appendString:@":"];
            [string appendString:[[URL port] description]];
        }
        [string appendString:@"\r\n"];
    }
    if (![headers objectForKey:@"Accept"]) {
        [string appendString:@"Accept: */*\r\n"];
    }
    content = [self HTTPBody];
    if (content) {
        contentAsString = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
        [string appendFormat:@"Content-Length: %lu\r\n", (unsigned long)[contentAsString length]];
    }
    [string appendString:@"Connection: close\r\n"];
    [string appendString:@"\r\n"];
    if (contentAsString) {
        [string appendString:contentAsString];
    }
    
    return string;
}

@end
