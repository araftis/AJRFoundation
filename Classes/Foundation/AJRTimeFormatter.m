/*
AJRTimeFormatter.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

#import "AJRTimeFormatter.h"

#import "NSString+Extensions.h"

@implementation AJRTimeFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    long secondsIn = [anObject longValue];
    NSInteger seconds = secondsIn % 60;
    NSInteger minutes = (secondsIn / 60) % 60;
    NSInteger hours = (secondsIn / (60 * 60)) % 24;
    NSInteger days = (secondsIn / (60 * 60 * 24));
    NSMutableString *returnValue = [NSMutableString string];
    
    if (days != 0) {
        [returnValue appendFormat:@"%ld d", (long)days];
    }
    if (hours != 0 || [returnValue length]) {
        if ([returnValue length] > 0) [returnValue appendString:@", "];
        [returnValue appendFormat:@"%ld h", (long)hours];
    }
    if (minutes != 0 || [returnValue length]) {
        if ([returnValue length] > 0) [returnValue appendString:@", "];
        [returnValue appendFormat:@"%ld m", (long)minutes];
    }
    if (seconds != 0 || [returnValue length]) {
        if ([returnValue length] > 0) [returnValue appendString:@", "];
        [returnValue appendFormat:@"%ld s", (long)seconds];
    }

    return returnValue;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    *anObject = [NSNumber numberWithLongLong:[string longLongValue]];
    return YES;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

@end
