/*
AJRObjectID.m
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

#import "AJRObjectID.h"

#import "AJRFormat.h"

#define countof(stackarray) (sizeof(stackarray)/sizeof(stackarray[0]))

typedef struct {
    uint8_t bytes[8];/// All less than 62.
} AJRObjectIDByteRepresentation;

@implementation AJRObjectID

@end

#pragma mark - Random ID Generation -

static const char AJRObjectIDCharacterSet[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

static AJRObjectIDByteRepresentation IBTruncateMemberIDByteRepresentation(const AJRObjectIDByteRepresentation input) {
    AJRObjectIDByteRepresentation result = {.bytes={0, 0, 0, 0, 0, 0, 0, 0}};
    for (NSInteger bidx = 0; bidx < countof(input.bytes); bidx += 1) {
        result.bytes[bidx] = (input.bytes[bidx] % countof(AJRObjectIDCharacterSet));
    }
    return result;
}

static AJRObjectIDByteRepresentation IBRandomMemberIDByteRepresentation(void) {
    AJRObjectIDByteRepresentation result = {.bytes={0, 0, 0, 0, 0, 0, 0, 0}};
    for (NSInteger bidx = 0; bidx < countof(result.bytes); bidx += 1) {
        result.bytes[bidx] = (uint8_t)arc4random();
    }
    return IBTruncateMemberIDByteRepresentation(result);
}

static NSString *AJRObjectIDFromBytes(AJRObjectIDByteRepresentation rep) {
    return AJRFormat(@"%c%c%c-%c%c-%c%c%c", AJRObjectIDCharacterSet[rep.bytes[0]], AJRObjectIDCharacterSet[rep.bytes[1]], AJRObjectIDCharacterSet[rep.bytes[2]], /* - */ AJRObjectIDCharacterSet[rep.bytes[3]], AJRObjectIDCharacterSet[rep.bytes[4]], /* - */ AJRObjectIDCharacterSet[rep.bytes[5]], AJRObjectIDCharacterSet[rep.bytes[6]], AJRObjectIDCharacterSet[rep.bytes[7]]);
}

NSString *AJRRandomObjectIDString(void) {
    // Produces a random string like XXX-XX-XXX, where X is ([a-z][A-Z][0-9])
    // That's 62^6, or 218340105584896, or 2^47.6 possible values.
    // "sqrt(-2 * (ln(1 - p))) * sqrt(62^8)" where p is the chance of collision tells us the number of ID's we'd have to generate to have that chance of collision.
    // So, for a (1/100) chance of a collision, we'd need 2,000,000 objects.
    // Chance        | Number of Objects Required
    // --------------+---------------------------
    // 1/2           | 1.7 * 10^7
    // 1/10          | 6.7 * 10^6
    // 1/100         | 2.0 * 10^6
    // 1/1000        | 6.6 * 10^5
    // 1/10000       | 2.0 * 10^5
    // 1/100000      | 6.6 * 10^4
    // 1/1000000     | 2.0 * 10^4
    //
    // So with 20K objects, we have a 1 in a million chance of a collision.
    // If that becomes a proplem, adding one more character would give us a 1 in 65 million chance with 20k objects.
    
    return AJRObjectIDFromBytes(IBRandomMemberIDByteRepresentation());
}
