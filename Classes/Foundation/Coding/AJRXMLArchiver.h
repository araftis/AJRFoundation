/*
 AJRXMLArchiver.h
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

#import <AJRFoundation/AJRXMLCoder.h>
#import <AJRFoundation/AJRXMLCoding.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRXMLOutputStream;

@interface AJRXMLArchiver : AJRXMLCoder

+ (instancetype)archiverWithOutputStream:(NSOutputStream *)outputStream;

// Use these when you want to explicitly name the top level object in the XML archive.
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject forKey:(nullable NSString *)key toFile:(NSString *)path error:(NSError **)error;
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject forKey:(nullable NSString *)key toOutputStream:(NSOutputStream *)outputStream error:(NSError **)error;
+ (nullable NSData *)archivedDataWithRootObject:(id <AJRXMLCoding>)rootObject forKey:(nullable NSString *)key;

// Use these when you want the top level element to just use the root object's XML name.
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject toFile:(NSString *)path error:(NSError **)error;
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject toOutputStream:(NSOutputStream *)outputStream error:(NSError **)error;
+ (nullable NSData *)archivedDataWithRootObject:(id <AJRXMLCoding>)rootObject;

@property (nonatomic,readonly) AJRXMLOutputStream *outputStream;

- (void)encodeObjectReference:(id)object;
- (void)encodeObjectReference:(nullable id)object forKey:(NSString *)key;

@end

/*
 NOTE: These just declare conformance, since all of this objects will encode.b
 */
@interface NSArray (AJRXMLCodingExtensions) <AJRXMLCoding>
@end

@interface NSMutableArray (AJRXMLCodingExtensions) <AJRXMLCoding>
@end

@interface NSDictionary (AJRXMLCodingExtensions) <AJRXMLCoding>
@end

@interface NSMutableDictionary (AJRXMLCodingExtensions) <AJRXMLCoding>
@end

@interface NSSet (AJRXMLCodingExtensions) <AJRXMLCoding>
@end

@interface NSMutableSet (AJRXMLCodingExtensions) <AJRXMLCoding>
@end

NS_ASSUME_NONNULL_END
