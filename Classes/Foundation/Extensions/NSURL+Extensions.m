
#import "NSURL+Extensions.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "NSString+Extensions.h"
#import "NSMutableDictionary+Extensions.h"
#import "NSMutableString+Extensions.h"
#import "NSURLQueryItem+Extensions.h"

@implementation NSURL (Extensions)

- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary<NSString *, NSString *> *)queryDictionary; {
	NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
	NSMutableArray *queryItems = [components.queryItems mutableCopy] ?: [NSMutableArray array];

	[queryItems addObjectsFromArray:[NSURLQueryItem queryItemsFromDictionary:queryDictionary]];
	components.queryItems = queryItems;
	
	return [components URL];
}

- (NSURL *)URLByAppendingQueryValue:(NSString *)query forKey:(NSString *)key {
	return [self URLByAppendingQueryDictionary:@{key:query}];
}

- (NSDictionary *)queryDictionary {
	NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	
	for (NSURLQueryItem *item in components.queryItems) {
		[query setObjectIfNotNil:item.value forKey:item.name];
	}
	
	return query;
}

- (NSString *)pathUTI {
	return AJRUTIForPathExtension(self.pathExtension);
}

- (NSString *)_normalizePath:(NSString *)path {
    path = [path lowercaseString];
    
    NSArray *components = [path componentsSeparatedByString:@"/"];
    
    NSMutableString *result = [NSMutableString string];
    BOOL first = YES;
    for (NSString *component in components) {
        if ([component length] > 0) {
            if (!first) {
                [result appendString:@"/"];
			} else {
				first = NO;
			}
            [result appendString:component];
        }
    }
    
    path = result;
    
    return path;
}

- (BOOL)isEqualToURL:(NSURL *)other {
    NSString *scheme = [[self scheme] lowercaseString];
    NSString *otherScheme = [[other scheme] lowercaseString];
    
    if (!AJREqual(scheme, otherScheme)) {
        return NO;
    }
    
    NSString *host = [[self host] lowercaseString];
    NSString *otherHost = [[other host] lowercaseString];
    
    if (!AJREqual(host, otherHost)) {
        return NO;
    }
    
    NSString *path = [self _normalizePath:[self path]];
    NSString *otherPath = [self _normalizePath:[other path]];
    
    if (!AJREqual(path, otherPath)) {
        return NO;
    }
    
    NSDictionary *queryDict = [self queryDictionary];
    NSDictionary *otherQueryDict = [other queryDictionary];

	if (!AJREqual(queryDict, otherQueryDict)) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)ajr_string:(NSString *)string isPrefixedWithKnownScheme:(NSString **)output {
	static NSSet *knownSchemes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		knownSchemes = [NSSet setWithArray:@[@"http", @"https", @"ftp"]];
	});
	
	NSString *foundScheme = nil;
	
	for (NSString *scheme in knownSchemes) {
		if ([string hasCaseInsensitivePrefix:[scheme stringByAppendingString:@":"]]) {
			foundScheme = scheme;
			break;
		}
	}
	
	if (foundScheme) {
		AJRSetOutParameter(output, foundScheme);
	}
	return foundScheme != nil;
}

+ (NSURL *)URLWithParsableString:(NSString *)string {
	BOOL hasKnownPrefix = NO;

	// I'd like this to be smarter, but this'll do for now.
	hasKnownPrefix = [self ajr_string:string isPrefixedWithKnownScheme:NULL];
	
	if (!hasKnownPrefix) {
		NSURL *possibleURL = nil;
		
		// If all the characters are valid in a host name and we have at least one '.' character. If they are, try and turn into a URL.
		if ([string rangeOfCharacterFromSet:[[NSCharacterSet URLHostAllowedCharacterSet] invertedSet]].location == NSNotFound && [string rangeOfString:@"."].location != NSNotFound) {
			possibleURL = [NSURL URLWithString:AJRFormat(@"https://%@", string)];
		}
		
		if (!possibleURL) {
			NSURL *url = [NSURL URLWithString:@"https://www.google.com/search"];
			NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
			string = [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
			NSString *language = [NSLocale currentLocale].languageCode;
			components.queryItems = [NSURLQueryItem queryItemsFromDictionary:@{@"hl":language,
																			   @"q":string}];
			return [components URL];
		}
		
		if (possibleURL) {
			return possibleURL;
		}
	}
	
	return [NSURL URLWithString:string];
}

@end
