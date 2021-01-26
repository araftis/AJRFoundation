//
//  AJRXMLOutputStream.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/23/14.
//
//

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
