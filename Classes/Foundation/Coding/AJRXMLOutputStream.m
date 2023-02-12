/*
 AJRXMLOutputStream.m
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

#import "AJRXMLOutputStream.h"

#import "AJRFunctions.h"
#import "NSData+Base64.h"
#import "NSOutputStream+Extensions.h"

typedef void (^AJRXMLStreamInitialAttributesBlock)(void);

@interface AJRXMLStreamNode : NSObject

- (id)initWithName:(NSString *)string;

@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) BOOL hasChildren;
@property (nonatomic,assign) BOOL suppressPrettyPrinting; // Control whether or not extra newlines should be added, even when pretty printing the output.
@property (nonatomic,strong) AJRXMLStreamInitialAttributesBlock initialAttributesBlock;

@end

@implementation AJRXMLStreamNode

- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        _name = name;
    }
    return self;
}

- (void)doInitialAttributesBlock {
    if (_initialAttributesBlock) {
        _initialAttributesBlock();
        _initialAttributesBlock = NULL;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p: %@>", NSStringFromClass([self class]), self, _name];
}

@end


@interface AJRXMLOutputStream ()

@property (nonatomic,strong) NSMutableArray<AJRXMLStreamNode *> *stack;

@end

@implementation AJRXMLOutputStream

+ (void)XMLDocumentStreamedInto:(NSOutputStream *)output scope:(AJRXMLOutputStreamInitialElementBlock)scope {
    AJRXMLOutputStream *stream = [[AJRXMLOutputStream alloc] initWithStream:output];
    
    [stream begin];
    scope(stream);
    [stream finish];
}

- (id)initWithStream:(NSOutputStream *)output {
    if ((self = [super init])) {
        _prettyOutput = NO;
        _outputStream = output;
        _stack = [[NSMutableArray alloc] init];
        _indentSize = 2;
        _encoding = [_outputStream encoding];
        _version = @"1.0";
    }
    return self;
}

- (void)begin {
    AJRXMLStreamNode *node = [[AJRXMLStreamNode alloc] initWithName:@"xml"];
    [node setInitialAttributesBlock:^{
        [self _outputCStringAttribute:"version" withValue:self->_version];
        CFStringEncoding    cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(self->_encoding);
        CFStringRef            ianaName = CFStringConvertEncodingToIANACharSetName(cfStringEncoding);
        if (ianaName) {
            [self _outputCStringAttribute:"encoding" withValue:(__bridge NSString *)ianaName];
        } else {
            [self _outputCStringAttribute:"encoding" withCStringValue:"utf-8"];
        }
    }];
    [_stack addObject:node];
    [_outputStream writeString:@"<?xml"];
}

- (void)finish {
}

#pragma mark - Conveniences

- (AJRXMLStreamNode *)currentNode {
    return [_stack lastObject];
}

#pragma mark - Elements

- (void)_outputCStringAttribute:(const char *)key withCStringValue:(const char *)value {
    [_outputStream writeString:@" " error:NULL];
    [_outputStream writeString:[NSString stringWithCString:key encoding:NSASCIIStringEncoding] error:NULL];
    [_outputStream writeString:@"=\"" error:NULL];
    [_outputStream writeString:[NSString stringWithCString:value encoding:NSASCIIStringEncoding] error:NULL];
    [_outputStream writeString:@"\"" error:NULL];
}

- (void)_outputCStringAttribute:(const char *)key withValue:(NSString *)value {
    [_outputStream writeString:@" " error:NULL];
    [_outputStream writeString:[NSString stringWithCString:key encoding:NSASCIIStringEncoding] error:NULL];
    [_outputStream writeString:@"=\"" error:NULL];
    [_outputStream writeString:value error:NULL];
    [_outputStream writeString:@"\"" error:NULL];
}

- (void)_outputAttribute:(NSString *)key withCStringValue:(const char *)value {
    [_outputStream writeString:@" " error:NULL];
    [_outputStream writeString:key];
    [_outputStream writeString:@"=\"" error:NULL];
    [_outputStream writeString:[NSString stringWithCString:value encoding:NSASCIIStringEncoding] error:NULL];
    [_outputStream writeString:@"\"" error:NULL];
}

- (void)_outputAttribute:(NSString *)key withValue:(NSString *)value {
    [_outputStream writeString:@" " error:NULL];
    [_outputStream writeString:key];
    [_outputStream writeString:@"=\"" error:NULL];
    [_outputStream writeString:value];
    [_outputStream writeString:@"\"" error:NULL];
}

- (void)_outputAttributes:(NSDictionary *)attributes {
    for (NSString *key in [[attributes allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        [self _outputAttribute:key withValue:[attributes objectForKey:key]];
    }
}

- (void)_outputNodeStart:(AJRXMLStreamNode *)node {
    NSUInteger indent = [_stack count] - 2;
    
    if (_prettyOutput && !node.suppressPrettyPrinting) {
        [_outputStream writeIndent:indent width:_indentSize error:NULL];
    }
    if ([node name]) {
        [_outputStream writeString:@"<" error:NULL];
        [_outputStream writeString:[node name]];
    }
}

- (void)_outputNodeClose:(AJRXMLStreamNode *)node {
    if ([node hasChildren]) {
        if (_prettyOutput && !node.suppressPrettyPrinting) {
            [_outputStream writeIndent:[_stack count] - 1 width:_indentSize error:NULL];
        }
        [_outputStream writeString:@"</" error:NULL];
        [_outputStream writeString:[node name]];
        [_outputStream writeString:@">" error:NULL];
        if (_prettyOutput) {
            [_outputStream writeString:@"\n"];
        }
    } else {
        if ([node name]) {
            [_outputStream writeFormat:@"/>"];
        }
        if (_prettyOutput && !node.suppressPrettyPrinting) {
            [_outputStream writeString:@"\n"];
        }
    }
}

- (void)push:(NSString *)name scope:(AJRXMLOutputStreamElementBlock)scope {
    [self push:name suppressingPrettyPrinting:NO scope:scope];
}

- (void)push:(NSString *)name suppressingPrettyPrinting:(BOOL)suppressPrettyPrinting scope:(AJRXMLOutputStreamElementBlock)scope {
    AJRXMLStreamNode *node = [self currentNode];
    AJRXMLStreamNode *newNode;
    
    if ([_stack count] == 1) {
        AJRXMLStreamNode *XMLNode = [_stack firstObject];
        [XMLNode doInitialAttributesBlock];
        [_outputStream writeString:@"?>\n" error:NULL];
    } else if (![node hasChildren]) {
        [_outputStream writeString:@">" error:NULL];
        if (_prettyOutput && !node.suppressPrettyPrinting) {
            [_outputStream writeString:@"\n" error:NULL];
        }
        [node setHasChildren:YES];
    }
    newNode = [[AJRXMLStreamNode alloc] initWithName:name];
    newNode.suppressPrettyPrinting = suppressPrettyPrinting;
    [_stack addObject:newNode];
    [self _outputNodeStart:newNode];
    scope();
    [_stack removeLastObject];
    [self _outputNodeClose:newNode];
}

- (void)suppressPrettyPrintingInCurrentScope {
    _stack.lastObject.suppressPrettyPrinting = YES;
}

#pragma mark - Attributes

#define AJRXMLDoInitialAttributes() [[self currentNode] doInitialAttributesBlock]

- (void)addCStringAttribute:(const char *)name withCStringValue:(const char *)value {
    AJRXMLDoInitialAttributes();
    [self _outputCStringAttribute:name withCStringValue:value];
}

- (void)addCStringAttribute:(const char *)name withValue:(NSString *)value {
    AJRXMLDoInitialAttributes();
    [self _outputCStringAttribute:name withValue:value];
}

- (void)addAttribute:(NSString *)name withCStringValue:(const char *)value {
    AJRXMLDoInitialAttributes();
    [self _outputAttribute:name withCStringValue:value];
}

- (void)addAttribute:(NSString *)name withValue:(NSString *)value {
    AJRXMLDoInitialAttributes();
    [self _outputAttribute:name withValue:value];
}

- (void)addBytes:(const uint8_t *)bytes length:(NSUInteger)length {
    if (_prettyOutput) {
        NSInteger allowed = ((100 - ([_stack count] - 2) * _indentSize) / 4) * 3;
        if (allowed < 12) {
            // This happens when we start to indent really deeply. When that happens, we'll always go ahead and output at least 10 characters.
            allowed = 12;
        }
        for (NSInteger x = 0; x < length; x += allowed) {
            if (x != 0) {
                [_outputStream writeString:@"\n" error:NULL];
                [_outputStream writeIndent:[_stack count] - 2 width:_indentSize error:NULL];
            }
            // D'oh. When we're controlling the line breaks, we have to make sure we enumerate the output in sets of 3 bytes.
            [_outputStream writeString:AJRBase64EncodedString(bytes, length, (NSRange){x, allowed - 1}, AJRBase64NoLineBreak)];
        }
//        for (NSInteger x = 0; x < length; x++) {
//            if (x && x % allowed == 0) {
//                [_outputStream writeString:@"\n"];
//                [_outputStream writeIndent:[_stack count] - 2 width:_indentSize];
//            }
//            [_outputStream writeCFormat:"%02x", bytes[x]];
//        }
    } else {
        [_outputStream writeString:AJRBase64EncodedString(bytes, length, (NSRange){0, length}, AJRBase64NoLineBreak)];
    }
}

- (void)addText:(NSString *)text {
    // TODO: Naïve right now. This needs to encode special characters.
    [_outputStream writeString:text];
}

- (void)addComment:(NSString *)comment {
    [_outputStream writeString:@"<!-- " error:NULL];
    [_outputStream writeString:comment];
    [_outputStream writeString:@" -->" error:NULL];
}

@end
