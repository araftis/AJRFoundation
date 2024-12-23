/*
 AJRXMLUnarchiver.h
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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
#import <AJRFoundation/AJRLogging.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRXMLDecodingErrorDomain;
extern const AJRLoggingDomain AJRLoggingDomainXMLDecoding;

@interface AJRXMLUnarchiver : AJRXMLCoder

/*!
 For the given `name`, attempts to find the class that will be used to decode the element in the XML stream.

 @param name The name of the element that encodes the returned class.

 @returns If found, returns the class that will be instantiated when decoding the give name.
 */
+ (nullable Class)classForXMLName:(NSString *)name;

/*!
 Allows you to register an additional name for the class for decoding.

 Some classes may actually want to map multiple names to themselves, and they can do this by calling this method. This is probably a rare-ish thing to do, but here when needed. Note that we coding, the instantiate class can get the name of the element in its `+[NSObject instantiateWithXMLCoding:]` method by calling `-[NSXMLCoder decodingName]`.

 @param aClass The class to be registered.
 @param name The name of the element in the XML stream.
 */
+ (void)registerClass:(Class)aClass forName:(NSString *)name;

+ (nullable id)unarchivedObjectWithStream:(NSInputStream *)stream topLevelClass:(nullable Class)aClass error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(unarchivedObject(with:topLevelClass:));
+ (nullable id)unarchivedObjectWithData:(NSData *)data topLevelClass:(nullable Class)aClass error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(unarchivedObject(with:topLevelClass:));
+ (nullable id)unarchivedObjectWithURL:(NSURL *)url topLevelClass:(nullable Class)aClass error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(unarchivedObject(with:topLevelClass:));
+ (nullable id)unarchivedObjectWithStream:(NSInputStream *)stream error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;

@property (nonatomic,assign) BOOL warnOfUndecodedKeys;

- (void)addSetter:(AJRXMLUnarchiverGenericSetter)setter forKey:(NSString *)key;
- (BOOL)callBlock:(void (^)(void))block catchingExceptionUsingError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
