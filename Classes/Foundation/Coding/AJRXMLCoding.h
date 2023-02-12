/*
 AJRXMLCoding.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRXMLCoder;

@protocol AJRXMLSubstituteDecoding <NSObject>

/*!
 Allows the receiver of the object to instantiate itself. This often isn't necessary, but some objects, like class clusters, may need to instantiate a specific subclass to work correctly. The default implementation of this method (hidden on NSObject) just calls [[self alloc] init]. While this is part of decoding, it's on the encoding side of the equation, because it's the object that's encoding which decides if it'll decode itself, or if it needs a placeholder object to do the decoding.
 
 @param coder The archiver doing the decoding, usually an NSXMLUnarchiver.
 */
@optional + (id)instantiateWithXMLCoder:(AJRXMLCoder *)coder;

@end

@protocol AJRXMLEncoding <NSObject>

/*!
 Encodes the object into the coder. You should implement this method, and call the various encode... methods to encode you objects values.
 
 @param coder The coder encoding the object graph, usually an AJRXMLArchiver.
 */
@required - (void)encodeWithXMLCoder:(AJRXMLCoder *)coder;

@end

@protocol AJRXMLDecoding <NSObject>

/*!
 This protocol requires that objects be instantiated in an "default" state. This is necessary, because the object is instantiated "empty" and then initialized as the object is unarchived via streaming. The round-about-ness of this is required, because we might need to instantiate an object other than the one initially indicated by the archive.
 */
- (instancetype)init;

/*!
 Called to decode the object. In this method to call various decode... method on coder passing in blocks to set the values as they're read from the XML stream. For this reason, you can't depend on specific values being set in any order, as the order they're called is the same as they're found in the XML. When XML decoding is complete, if you implement -[id<AJRXMLCoding> finalizeXMLDecoding], this method will be called. You can to any final initialization in this method, knowing that all of your setter blocks have been called.
 
 This method is optional, but it truth, it will need to be implemented by most objects. It's optional, because some decoders will make use of the +[id<AJRXMLCoding> instantiateWithXMLCoder:] and -[id<AJRXMLCoding> finalzeXMLDecoding] methods to actually perform the decoding on a place holder object that's then returned via the finalize method. For example, NSString cannot be modified after creation, but because we use a "lazy" initialization method, and because we don't want to return a "mutable" string, NSString decodes into a place holder that's then turned into an actual NSString in the finalize method.
 
 @param coder The archiver doing the decoding, usually an NSXMLUnarchiver.
 */
@optional - (void)decodeWithXMLCoder:(AJRXMLCoder *)coder;

/*!
 When implemented, this is called once all the decoding setter blocks have been called on the receiver. This method will normally just return self, but it may return a different object. This happens with some special objects, like NSString. Since NSStrings cannot be changed once created, when decoding, the NSString implementation of -[id<AJRXMLCoding> intantiateWithXMLCoder:] will return a place holder to do the decoding. Then, in the finalization, this method will return the actual string as read from the XML.
 
 @return Usually the receiver, but may return a different object. The returned object becomes the de-facto object in the decoded object graph. */
@optional - (nullable id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error;

@end

@protocol AJRXMLCoding <AJRXMLEncoding, AJRXMLDecoding, AJRXMLSubstituteDecoding, NSObject>

@end

NS_ASSUME_NONNULL_END
