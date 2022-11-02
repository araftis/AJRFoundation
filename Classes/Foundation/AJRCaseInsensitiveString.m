/*
 AJRCaseInsensitiveString.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

#pragma mark - AJRXMLCoding

/// We override this, so that we'd re-create the correct string class, but we don't need to do anything else.
+ (NSString *)ajr_nameForXMLArchiving {
    return @"ciString";
}

@end
