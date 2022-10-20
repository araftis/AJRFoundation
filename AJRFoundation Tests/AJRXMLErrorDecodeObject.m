/*
AJRXMLErrorDecodeObject.m
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

#import "AJRXMLErrorDecodeObject.h"

@implementation AJRXMLErrorDecodeObject

- (id)initWithValue:(NSInteger)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

+ (NSString *)ajr_nameForXMLArchiving {
    return @"error-decode-object";
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder encodeInteger:_value forKey:@"value"];
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeIntegerForKey:@"value" setter:^(NSInteger value) {
        if (value >= 16) {
            @throw [NSException exceptionWithName:@"ErrorException" reason:@"To force a failure in my unit tests." userInfo:nil];
        }
        self->_value = value;
    }];
}

- (BOOL)isEqual:(id)otherIn {
    AJRXMLErrorDecodeObject *other = AJRObjectIfKindOfClass(otherIn, AJRXMLErrorDecodeObject);
    return other != nil && _value == other->_value;
}

- (NSUInteger)hash {
    return @(_value).hash;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p: %d>", self, self, (int)_value);
}

@end
