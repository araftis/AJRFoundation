
#import "AJRCaseInsensitiveString.h"

#import "NSString+Extensions.h"

@implementation AJRCaseInsensitiveString {
    NSString *_string;
    NSString *_lowercase;
    NSUInteger _hash;
}

- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        _string = string;
        _lowercase = [_string lowercaseString];
        _hash = [_lowercase hash];
    }
    
    return self;
}

- (NSUInteger)length {
    return [_string length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [_string characterAtIndex:index];
}

- (NSUInteger)hash {
    return _hash;
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange {
    return [super compare:string options:mask | NSCaseInsensitiveSearch range:compareRange];
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange locale:(NSDictionary *)dict {
    return [super compare:string options:mask | NSCaseInsensitiveSearch range:compareRange locale:dict];
}

- (BOOL)isEqualToString:(NSString *)string {
    return self == string || [_lowercase isEqualToString:[string lowercaseString]];
}

- (BOOL)isEqual:(id)string {
    BOOL result = self == string;
    
    if (!result && [string isKindOfClass:[NSString class]]) {
        result = [_lowercase isEqual:[string lowercaseString]];
    }
    
    return result;
}

- (BOOL)hasPrefix:(NSString *)string {
    return [_lowercase hasPrefix:[string lowercaseString]];
}

- (BOOL)hasSuffix:(NSString *)string {
    return [_lowercase hasSuffix:[string lowercaseString]];
}

- (NSRange)rangeOfString:(NSString *)string {
    return [self rangeOfString:string options:0 range:self.fullRange];
}

- (NSRange)rangeOfString:(NSString *)string options:(NSStringCompareOptions)mask {
    return [self rangeOfString:string options:mask range:self.fullRange];
}

- (NSRange)rangeOfString:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)searchRange {
    return [_lowercase rangeOfString:string options:mask | NSCaseInsensitiveSearch range:searchRange];
}

- (NSString *)description {
    return [_string description];
}

- (id)copyWithZone:(NSZone *)zone {
    AJRCaseInsensitiveString *new = [[self class] allocWithZone:nil];
    
    new->_string = [_string copyWithZone:zone];
    new->_lowercase = [_lowercase copyWithZone:zone];
    new->_hash = _hash;
    
    return new;
}

@end
