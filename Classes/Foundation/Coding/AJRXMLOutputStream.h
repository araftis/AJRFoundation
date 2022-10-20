/*
AJRXMLOutputStream.h
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

#import <Foundation/Foundation.h>

@class AJRXMLOutputStream;

typedef void (^AJRXMLOutputStreamElementBlock)(void);
typedef void (^AJRXMLOutputStreamInitialElementBlock)(AJRXMLOutputStream *builder);

@interface AJRXMLOutputStream : NSObject

@property (nonatomic,strong) NSString *version;
@property (nonatomic,assign) NSStringEncoding encoding;

@property (nonatomic,assign) BOOL prettyOutput;
@property (nonatomic,readonly,strong) NSOutputStream *outputStream;
@property (nonatomic,assign) NSUInteger indentSize;

+ (void)XMLDocumentStreamedInto:(NSOutputStream *)output scope:(AJRXMLOutputStreamInitialElementBlock)scope;
- (id)initWithStream:(NSOutputStream *)output;

- (void)begin;
- (void)finish;

/*! See -[AJRXMLOutputStream push:suppressingPrettyPrinting:scope:]. */
- (void)push:(NSString *)name scope:(AJRXMLOutputStreamElementBlock)scope;
/*!
 Begins a new scope, which is basically an alias for a new XML tag, given that we're writing XML. You'll generally call this when adding a new tag to your output stream. The exact form of the output will depend on whether or not the passed in block creates children for the node.
 
 @param name The XML tag name.
 @param suppressingPrettyPrinting If YES, the node won't be decorated with additonal formatting to make it look pretty. This is important for certain tags, where the "pretty" printing can basically alter the value expressed by the XML. For example, a text block with no newlines, but written to a node that has pretty printing turned on would gain extre newlines and whitespace around the text.
 @param scope A block that will configure the current scope, possibly creating additional child scopes. For example, the block may call things like -[AJRXMLOutputStream addAttribute:withValue:] to add an attribute to the current XML node. The block may addtionally call this method to create additional child nodes.
 */
- (void)push:(NSString *)name suppressingPrettyPrinting:(BOOL)suppressingPrettyPrinting scope:(AJRXMLOutputStreamElementBlock)scope;
- (void)addCStringAttribute:(const char *)name withCStringValue:(const char *)value;
- (void)addCStringAttribute:(const char *)name withValue:(NSString *)value;
- (void)addAttribute:(NSString *)name withCStringValue:(const char *)value;
- (void)addAttribute:(NSString *)name withValue:(NSString *)value;
- (void)addBytes:(const uint8_t *)bytes length:(NSUInteger)length;
- (void)addText:(NSString *)text;
- (void)addComment:(NSString *)comment;

- (void)suppressPrettyPrintingInCurrentScope;

@end
