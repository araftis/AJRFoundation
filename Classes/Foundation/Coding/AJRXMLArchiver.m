/*
AJRXMLArchiver.m
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

#import "AJRXMLArchiver.h"

#import "AJRLogging.h"
#import "AJRXMLCoder.h"
#import "AJRXMLCoding.h"
#import "AJRXMLOutputStream.h"
#import "AJRFunctions.h"
#import "NSData+Extensions.h"

typedef void (^AJRXMLEncodingBlock)(void);

@interface AJRXMLEncodingScope : NSObject

@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSMutableArray *objectEncoders;
@property (nonatomic,strong) AJRXMLEncodingBlock encodingBlock;

@end

typedef void (^AJRXMLObjectEncoder)(void);

@implementation AJRXMLEncodingScope

- (id)initWithKey:(NSString *)key encodingBlock:(AJRXMLEncodingBlock)block {
    if ((self = [super init])) {
        _key = key;
        _encodingBlock = block;
    }
    return self;
}

- (NSMutableArray *)objectEncoders {
    if (_objectEncoders == nil) {
        _objectEncoders = [NSMutableArray array];
    }
    return _objectEncoders;
}

- (void)addObjectEncoder:(AJRXMLObjectEncoder)objectEncoder {
    [[self objectEncoders] addObject:objectEncoder];
}

- (void)encodeObjects {
    for (AJRXMLObjectEncoder objectEncoder in _objectEncoders) {
        objectEncoder();
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p: %@>", NSStringFromClass([self class]), self, _key];
}

@end

@implementation AJRXMLArchiver {
    AJRXMLOutputStream *_outputStream;
    NSMutableArray *_scopes;
    NSMapTable *_objectIDsByObject;
    NSHashTable *_forcedObjectRefs;
    NSHashTable *_encodedObjects;
    NSMapTable *_objectsByObjectIDs;
}

#pragma mark - Creation

- (id)initWithStream:(NSStream *)stream {
    if ((self = [super initWithStream:stream])) {
        _outputStream = [[AJRXMLOutputStream alloc] initWithStream:[self outputStream]];
        [_outputStream setPrettyOutput:YES];
        _scopes = [[NSMutableArray alloc] init];
        _objectIDsByObject = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality capacity:100];
        _objectsByObjectIDs = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality capacity:100];
        _forcedObjectRefs = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality capacity:100];
        _encodedObjects = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality capacity:100];
    }
    return self;
}

+ (instancetype)archiverWithOutputStream:(NSOutputStream *)outputStream {
    return [[AJRXMLArchiver alloc] initWithStream:outputStream];
}

+ (BOOL)archiveRootObject:(id)rootObject forKey:(NSString *)key toFile:(NSString *)path error:(NSError **)error {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    AJRXMLArchiver *archiver = [AJRXMLArchiver archiverWithOutputStream:outputStream];
    BOOL success = YES;
    
    [outputStream open];
    [archiver encodeRootObject:rootObject forKey:key];
    [outputStream close];
    
    if ([outputStream streamError]) {
        if (error) {
            *error = [outputStream streamError];
        }
        success = NO;
    }
    
    return success;
}

+ (BOOL)archiveRootObject:(id)rootObject forKey:(NSString *)key toOutputStream:(NSOutputStream *)outputStream error:(NSError **)error {
    AJRXMLArchiver *archiver = [AJRXMLArchiver archiverWithOutputStream:outputStream];
    BOOL success = YES;

    [outputStream open];
    [archiver encodeRootObject:rootObject forKey:key];
    [outputStream close];

    if ([outputStream streamError]) {
        if (error) {
            *error = [outputStream streamError];
        }
        success = NO;
    }

    return success;
}

+ (NSData *)archivedDataWithRootObject:(id)rootObject forKey:(NSString *)key {
    NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
    AJRXMLArchiver *archiver = [AJRXMLArchiver archiverWithOutputStream:outputStream];
    
    [outputStream open];
    [archiver encodeRootObject:rootObject forKey:key];
    [outputStream close];
    
    return [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path error:(NSError **)error {
    return [self archiveRootObject:rootObject forKey:nil toFile:path error:error];
}

+ (BOOL)archiveRootObject:(id)rootObject toOutputStream:(NSOutputStream *)outputStream error:(NSError **)error {
    return [self archiveRootObject:rootObject forKey:nil toOutputStream:outputStream error:error];
}

+ (NSData *)archivedDataWithRootObject:(id)rootObject {
    return [self archivedDataWithRootObject:rootObject forKey:nil];
}

- (NSOutputStream *)outputStream {
    return (NSOutputStream *)[self stream];
}

#pragma mark - Encoding

- (AJRXMLEncodingScope *)currentScope {
    return [_scopes lastObject];
}

- (NSString *)identifierForObject:(id)object generated:(BOOL *)generated {
    NSString *identifier = [_objectIDsByObject objectForKey:object];
    if (identifier == nil) {
        do {
            identifier = AJRSemiuniqueIdentifier();
        } while ([_objectsByObjectIDs objectForKey:identifier] != nil);
        [_objectsByObjectIDs setObject:object forKey:identifier];
        [_objectIDsByObject setObject:identifier forKey:object];
        if (generated) {
            *generated = YES;
        }
    }
    return identifier;
}

- (void)beginScopeForKey:(NSString *)key scope:(AJRXMLEncodingBlock)block {
    [_scopes addObject:[[AJRXMLEncodingScope alloc] initWithKey:key encodingBlock:block]];
    block();
    [_scopes removeLastObject];
}

- (void)_encodeObject:(id <AJRXMLCoding>)object forKey:(NSString *)keyIn forceReference:(BOOL)flag {
    [self beginScopeForKey:keyIn scope:^{
        NSString *key = keyIn ?: [(NSObject *)object ajr_nameForXMLArchiving];
        BOOL generatedID = NO;
        BOOL needsClassName = ![key isEqualToString:[(id)object ajr_nameForXMLArchiving]];
        NSString *objectIdentifier = nil;
        if (object == nil) {
            key = [NSString stringWithFormat:@"nil:%@", key];
        } else {
            objectIdentifier = [self identifierForObject:object generated:&generatedID];
        }
        [self->_outputStream push:key scope:^{
            if (object != nil && flag) {
                // Doing this this way will generate some duplicated code, but interwaving the logic gets a little hairy to read.
                if (generatedID && self->_scopes.count == 1) {
                    AJRLog(AJRXMLCodingLogDomain, AJRLogLevelError, @"Attemping to encode the root object by ref, which is going to cause problems. Your archive is likely to be corrupt.");
                }
                if (objectIdentifier != nil) {
                    BOOL first = NO;
                    if (![self->_encodedObjects containsObject:object]) {
                        // Let's note which objects were were asked to encode by ref, but only if we haven't yet encoded it.
                        [self->_forcedObjectRefs addObject:object];
                        first = YES;
                    }
                    // And then we'll write the object ref.
                    [self encodeString:objectIdentifier forKey:@"ajr:ref"];
                    if (first) {
                        // This is necessary on the very first forced reference, because we'll need it in order to alloc the object.
                        [self encodeString:NSStringFromClass([(id)object ajr_classForXMLArchiving]) forKey:@"ajr:class"];
                    }
                }
            } else {
                if (generatedID || [self->_forcedObjectRefs containsObject:object]) {
                    // If we either generated the ID (outputting the object for the first time), or if we previously outputted is as a forced ref, then we're going to write the actual object.
                    if ([self->_scopes count] == 1) {
                        // This is the root element, so add our special name space information
                        [self encodeString:@"http://www.raftis.net/~aj" forKey:@"xmlns:nil"];
                        [self encodeString:@"http://www.raftis.net/~aj" forKey:@"xmlns:ajr"];
                    }
                    [self encodeString:objectIdentifier forKey:@"ajr:id"];
                    if (needsClassName) {
                        [self encodeString:NSStringFromClass([(id)object ajr_classForXMLArchiving]) forKey:@"ajr:class"];
                    }
                    [object encodeWithXMLCoder:self];
                    // And we're going to remove it from the dictionary of forced refs. This will allow us to emit warnings if we never actually archive the object.
                    [self->_forcedObjectRefs removeObject:object];
                    // And add it to the set of objects we've encoded.
                    [self->_encodedObjects addObject:object];
                } else if (objectIdentifier) {
                    [self encodeString:objectIdentifier forKey:@"ajr:ref"];
                }
            }
            [[self currentScope] encodeObjects];
        }];
    }];
}

- (void)encodeRootObject:(id <AJRXMLCoding>)object forKey:(NSString *)key {
    [_outputStream begin];
    [self _encodeObject:object forKey:key forceReference:NO];
    [_outputStream finish];
}

- (void)encodeObject:(id)object {
    [self encodeObject:object forKey:[object ajr_nameForXMLArchiving]];
}

- (void)encodeObject:(id <AJRXMLCoding>)object forKey:(NSString *)key {
    [[self currentScope] addObjectEncoder:^{
        [self _encodeObject:object forKey:key forceReference:NO];
    }];
}

- (void)encodeObjectReference:(id)object {
    [self encodeObjectReference:object forKey:[object ajr_nameForXMLArchiving]];
}

- (void)encodeObjectReference:(nullable id)object forKey:(NSString *)key {
    [[self currentScope] addObjectEncoder:^{
        [self _encodeObject:object forKey:key forceReference:YES];
    }];
}

- (void)encodeString:(NSString *)value forKey:(NSString *)key {
    [_outputStream addAttribute:key withValue:value];
}

- (void)encodeBool:(BOOL)number forKey:(NSString *)key {
    [_outputStream addAttribute:key withCStringValue:number ? "true" : "false"];
}

- (void)encodeInteger:(NSInteger)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%ld", (long)number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeInt:(int)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%d", number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeInt32:(int32_t)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%d", number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeInt64:(int64_t)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%lld", number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeUInteger:(NSUInteger)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%lu", (long)number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeUInt:(unsigned int)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%u", number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeUInt32:(uint32_t)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%u", number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeUInt64:(uint64_t)number forKey:(NSString *)key {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%llu", number);
    [_outputStream addAttribute:key withCStringValue:buffer];
}

- (void)encodeFloat:(float)number forKey:(NSString *)key {
    [_outputStream addAttribute:key withValue:[AJRXMLCoderGetFloatFormatter() stringFromNumber:@(number)]];
}

- (void)encodeDouble:(double)number forKey:(NSString *)key {
    [_outputStream addAttribute:key withValue:[AJRXMLCoderGetDoubleFormatter() stringFromNumber:@(number)]];
}

- (void)encodeCGFloat:(CGFloat)number forKey:(NSString *)key {
    [_outputStream addAttribute:key withValue:[AJRXMLCoderGetDoubleFormatter() stringFromNumber:@(number)]];
}

- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length forKey:(NSString *)key {
    [[self currentScope] addObjectEncoder:^{
        [self beginScopeForKey:key scope:^{
            [self->_outputStream push:nil scope:^{
                [self->_outputStream addBytes:bytes length:length];
            }];
        }];
    }];
}

- (void)encodeBytes:(const uint8_t *)bytes length:(NSUInteger)length {
    [[self currentScope] addObjectEncoder:^{
        [self beginScopeForKey:@"data" scope:^{
            [self->_outputStream push:nil scope:^{
                [self->_outputStream addBytes:bytes length:length];
            }];
        }];
    }];
}

#pragma mark - Encoding conveniences

- (void)encodeObjectIfNotNil:(id <AJRXMLCoding>)object forKey:(NSString *)key {
    if (object) {
        [self encodeObject:object forKey:key];
    }
}

- (void)encodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block {
    [[self currentScope] addObjectEncoder:^{
        [self beginScopeForKey:key scope:^{
            [self->_outputStream push:key scope:^{
                block();
                [[self currentScope] encodeObjects];
            }];
        }];
    }];
}

- (void)encodeCString:(const char *)value forKey:(NSString *)key {
    [_outputStream addAttribute:key withCStringValue:value];
}

- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format arguments:(va_list)args {
    char buffer[1024];
    
    vsnprintf(buffer, 1024, format, args);
    [self encodeCString:buffer forKey:key];
}

- (void)encodeKey:(NSString *)key withCStringFormat:(const char *)format, ... {
    va_list ap;
    va_start(ap, format);
    [self encodeKey:key withCStringFormat:format arguments:ap];
    va_end(ap);
}

- (void)encodeText:(NSString *)text {
    [_outputStream suppressPrettyPrintingInCurrentScope];
    [_outputStream push:nil suppressingPrettyPrinting:YES scope:^{
        [self->_outputStream addText:text];
    }];
}

- (void)encodeText:(NSString *)text forKey:(NSString *)key {
    [[self currentScope] addObjectEncoder:^{
        [self beginScopeForKey:key scope:^{
            [self->_outputStream push:nil scope:^{
                [self->_outputStream addText:text];
            }];
        }];
    }];
}

- (void)encodeComment:(NSString *)text {
    [[self currentScope] addObjectEncoder:^{
        [self beginScopeForKey:nil scope:^{
            [self->_outputStream push:nil scope:^{
                [self->_outputStream addComment:text];
            }];
        }];
    }];
}

- (void)encodeRange:(NSRange)range forKey:(NSString *)key {
    [self encodeGroupForKey:key usingBlock:^{
        [self encodeUInteger:range.location forKey:@"location"];
        [self encodeUInteger:range.length forKey:@"length"];
    }];
}

- (void)encodeURL:(NSURL *)url forKey:(NSString *)key {
    [_outputStream addAttribute:key withValue:url.absoluteString];
}

- (void)encodeURLBookmark:(NSURL *)url forKey:(NSString *)key {
#if defined(AJRFoundation_iOS)
    NSURLBookmarkCreationOptions options = 0;
#else
    NSURLBookmarkCreationOptions options = NSURLBookmarkCreationWithSecurityScope;
#endif
    NSData *data = [url bookmarkDataWithOptions:options includingResourceValuesForKeys:nil relativeToURL:nil error:NULL];
    if (data) {
        [self _encodeObject:data forKey:key forceReference:NO];
    } else {
        AJRLog(AJRXMLCodingLogDomain, AJRLogLevelError, @"Failed to encode URL as bookmark. This will likely result in an incomplete archive: %@", url);
    }
}

@end
