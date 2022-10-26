/*
AJRXMLUnarchiver.m
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

#import "AJRXMLUnarchiver.h"

#import "AJRClassEnumerator.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "AJRMutableOrderedDictionary.h"
#import "AJRRuntime.h"
#import "AJRXMLCoding.h"
#import "NSData+Base64.h"
#import "NSError+Extensions.h"
#import "NSObject+Extensions.h"

NSString * const AJRXMLDecodingErrorDomain = @"AJRXMLDecodingErrorDomain";
NSString * const AJRXMLDecodingLoggingDomain = @"AJRXMLDecodingLoggingDomain";

static NSString * const AJRXMLGenericKeySentinel = @"__GENERIC__";
static NSString * const AJRXMLTextKeySentinel = @"__TEXT__";

@class AJRXMLUnarchiverSetterNode;

@interface AJRXMLUnarchiverFrame : NSObject {
    AJRMutableOrderedDictionary<NSString *, AJRXMLUnarchiverSetterNode *> *_keysToSetters;
    NSMutableArray<id> *_genericChildren;
}

+ (instancetype)frameWithKey:(NSString *)name object:(id)object;

@property (readonly,strong) NSString *key;
@property (readonly,strong) id object;
@property (nullable,nonatomic,strong) NSString *objectID;
@property (nonatomic,assign) BOOL isReferenceObject;
@property (nonatomic,strong) AJRXMLUnarchiverFinalizer finalizer;
@property (nonatomic,readonly) AJRMutableOrderedDictionary<NSString *, void (^)(void)> *keysToGroupDecoders;
@property (nonatomic,strong) NSMutableDictionary<NSString *, NSString *> *unassociatedRawValues;

- (BOOL)isGroupKey:(NSString *)key;

- (void)setSetter:(AJRXMLUnarchiverGenericSetter)setter forKey:(NSString *)key;
- (nullable AJRXMLUnarchiverSetterNode *)setterForKey:(NSString *)key;

- (BOOL)finalizeWithError:(NSError **)error;

@end


@interface AJRXMLUnarchiver ()

@property NSArray<AJRXMLUnarchiverFrame *> *stack;

@end


@interface AJRXMLDecoderGroup : NSObject <AJRXMLCoding> {
}

@property (nonatomic,readonly) AJRMutableOrderedDictionary<NSString *, void (^)(void)> *groupDecoders;

@end

@implementation AJRXMLDecoderGroup

- (id)initWithGroupDecoders:(AJRMutableOrderedDictionary<NSString *, void (^)(void)> *)groupDecoders {
    if ((self = [super init])) {
        _groupDecoders = groupDecoders;
    }
    return self;
}

- (void)encodeWithXMLCoder:(AJRXMLCoder *)coder {
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    AJRXMLUnarchiver *archiver = AJRObjectIfKindOfClass(coder, AJRXMLUnarchiver);
    if (archiver) {
        AJRXMLUnarchiverFrame *frame = [[archiver stack] lastObject];
        void (^decoder)(void) = _groupDecoders[frame.key];
        if (decoder != NULL) {
            decoder();
        }
    } else {
        // This will probably never be called?
        [_groupDecoders enumerateKeysAndObjectsUsingBlock:^(NSString *key, void (^decoder)(void), BOOL *stop) {
            decoder();
        }];
    }
}

@end

@interface AJRXMLUnarchiverSetterNode : NSObject {
    NSMutableString *_characters;
}

@property (nonatomic,strong) AJRXMLUnarchiverGenericSetter setter;
@property (nullable,nonatomic,strong) id rawValue;
@property (nonatomic,assign) BOOL hadRawValueInXML;
@property (nonatomic,strong) NSMutableArray<id> *childValues;
@property (nonatomic,readonly) NSString *characters;

+ (instancetype)setterNodeWithSetter:(AJRXMLUnarchiverGenericSetter)setter;

- (void)addChildValue:(id)child;

- (void)appendCharacters:(NSString *)characters;

@end

@implementation AJRXMLUnarchiverSetterNode

+ (instancetype)setterNodeWithSetter:(AJRXMLUnarchiverGenericSetter)setter {
    return [[self alloc] initWithSetter:setter];
}

- (id)initWithSetter:(AJRXMLUnarchiverGenericSetter)setter {
    if ((self = [super init])) {
        _setter = setter;
    }
    return self;
}

- (void)addChildValue:(id)child {
    if (_childValues == nil) {
        _childValues = [NSMutableArray array];
    }
    [_childValues addObject:child];
}

- (NSString *)characters {
    return _characters;
}

- (void)appendCharacters:(NSString *)characters {
    if (_characters == nil) {
        _characters = [[NSMutableString alloc] init];
    }
    [_characters appendString:characters];
}

// Because we have a getter and setter...
@synthesize rawValue = _rawValue;

- (void)setRawValue:(id)rawValue {
    _rawValue = rawValue;
    _hadRawValueInXML = YES;
}

- (id)rawValue {
    return _rawValue == [NSNull null] ? nil : _rawValue;
}

@end

@implementation AJRXMLUnarchiverFrame

+ (instancetype)frameWithKey:(NSString *)key object:(id)object {
    return [[self alloc] initWithKey:key object:object];
}

- (id)initWithKey:(NSString *)key object:(id)object {
    if ((self = [super init])) {
        _key = key;
        _object = object;
        _keysToSetters = [AJRMutableOrderedDictionary dictionary];
    }
    return self;
}

- (BOOL)isGroupKey:(NSString *)key {
    return [_keysToGroupDecoders objectForKey:key] != nil;
}

- (void)setSetter:(AJRXMLUnarchiverGenericSetter)setter forKey:(NSString *)key {
    _keysToSetters[key] = [AJRXMLUnarchiverSetterNode setterNodeWithSetter:setter];
    NSString *unassociatedValue = _unassociatedRawValues[key];
    if (unassociatedValue != nil) {
        // We have a value that wasn't previously associated with a node, so let's associate it now.
        _keysToSetters[key].rawValue = unassociatedValue;
        [_unassociatedRawValues removeObjectForKey:key];
    }
}

- (AJRXMLUnarchiverSetterNode *)setterForKey:(NSString *)key {
    return _keysToSetters[key];
}

- (void)setRawValue:(id)rawValue forKey:(NSString *)key {
    AJRXMLUnarchiverSetterNode *node = _keysToSetters[key];
    
    if ([key isEqualToString:AJRXMLTextKeySentinel]) {
        node = _keysToSetters[AJRXMLTextKeySentinel];
        if (node != nil) {
            [node appendCharacters:rawValue];
        }
    } else if (node == nil) {
        node = _keysToSetters[AJRXMLGenericKeySentinel];
        if (node != nil) {
            [node addChildValue:rawValue];
        } else {
            // Keep track of this, in case the decoder is set later.
            if (_unassociatedRawValues == nil) {
                // Only create this is we have unassociated values. This should actually be somewhat rare.
                _unassociatedRawValues = [NSMutableDictionary dictionary];
            }
            _unassociatedRawValues[key] = rawValue;
        }
    } else {
        node.rawValue = rawValue;
    }
}

- (void)setGroupDecoder:(void (^)(void))decoder forKey:(NSString *)key {
    if (_keysToGroupDecoders == nil) {
        _keysToGroupDecoders = [AJRMutableOrderedDictionary dictionary];
    }
    [_keysToGroupDecoders setObject:decoder forKey:key];
}

- (BOOL)finalizeWithError:(NSError **)error {
    __block NSError *localError;
    NSMutableSet<NSString *> *decodedKeys = [NSMutableSet set];
    NSArray<NSString *> *keys = [_keysToSetters allKeys];
    while (keys.count != decodedKeys.count) {
        // So, it's possible for some decoding blocks to include additional requests for decoding. When that happens, new keys will be added to _keysToSetters. As such, we're going to enumerate over keys until we've decoded the same number of keys in the keys list.
        for (NSString *key in keys) {
            if (![decodedKeys containsObject:key]) {
                [decodedKeys addObject:key];
                AJRXMLUnarchiverSetterNode *node = [_keysToSetters objectForKey:key];
                if (node.setter != NULL) {
                    if (key == AJRXMLGenericKeySentinel) {
                        for (id value in node.childValues) {
                            if (!node.setter(value, &localError)) {
                                break;
                            }
                        }
                    } else if (key == AJRXMLTextKeySentinel) {
                        if (!node.setter(node.characters, &localError)) {
                            break;
                        }
                    } else {
                        if (node.hadRawValueInXML && !node.setter(node.rawValue, &localError)) {
                            break;
                        }
                    }
                }
            }
        }
        keys = [_keysToSetters allKeys];
    }
    if (!_isReferenceObject && [_object respondsToSelector:@selector(finalizeXMLDecodingWithError:)]) {
        _object = [_object finalizeXMLDecodingWithError:&localError];
    }
    return AJRAssertOrPropagateError(localError == nil, error, localError);
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p: elementName=\"%@\": object: <%C: %p>>", self, self, _key, _object, _object);
}

@end

@interface AJRXMLUnarchiver () <NSXMLParserDelegate>

@end

@implementation AJRXMLUnarchiver {
    NSXMLParser *_parser;
    Class _topLevelClass;
    NSMutableDictionary *_objectIDsToObjects;
    NSMutableArray<AJRXMLUnarchiverFrame *> *_stack;
    NSError *_error;
    NSMutableDictionary<NSString *, id> *_objectsByID; // Tracks all objects by their ID.
    NSMutableDictionary<NSString *, id> *_forwardObjectsByID; // Tracks forward declared objects by their ID up until they're initialized.
    id<AJRXMLCoding> _rootObject;
}

static NSDictionary<NSString *, Class> *_xmlNamesToClasses = nil;

+ (NSDictionary<NSString *, Class> *)xmlNamesToClasses {
    if (_xmlNamesToClasses == nil) {
        Method base = class_getClassMethod(objc_getClass("NSObject"), @selector(ajr_nameForXMLArchiving));
        NSMutableDictionary<NSString *, Class> *work = [NSMutableDictionary dictionary];
        
        for (Class runtimeClass in [AJRClassEnumerator classEnumerator]) {
            Method imp = class_getClassMethod(runtimeClass, @selector(ajr_nameForXMLArchiving));
            if (imp != base) {
                //AJRPrintf(@"class: %s (%p [%p]/%p [%p])\n", class_getName(runtimeClass), base, method_getImplementation(base), imp, method_getImplementation(imp));
                if (strncmp(class_getName(runtimeClass), "Web", 3) == 0) {
                    // So, oddly, and only sometimes, Web* classes are causing an allocation error when we try to call ajr_nameForXMLArchiving. Not good, but what can we do? This is a hacky workaround, but it's got us running.
                    // TODO: Figure out why this crashes Papel, but not AI Explorer.
                    continue;
                }
                NSString *name = [runtimeClass ajr_nameForXMLArchiving];
                if (name != nil) {
                    if (work[name] != nil) {
                        // Ignore system classes. They make for a lot of noise.
                        NSString *path = [[NSBundle bundleForClass:runtimeClass] bundlePath];
                        if (![path hasPrefix:@"/System"]
                            && ![path hasPrefix:@"/usr"]) {
                            AJRLog(AJRXMLCodingLogDomain, AJRLogLevelWarning, @"Class %C has already registered the xml name \"%@\", but %C is also trying to do this. This is likely going to cause problems in your document.", work[name], name, runtimeClass);
                        }
                    }
                    work[name] = runtimeClass;
                }
            }
        }
        
        _xmlNamesToClasses = work;
    }
    return _xmlNamesToClasses;
}

+ (Class)classForXMLName:(NSString *)name {
    Class possible = [self xmlNamesToClasses][name];
    if (possible == Nil) {
        possible = NSClassFromString(name);
    }
    return possible;
}

+ (nullable id)unarchivedObjectWithStream:(NSInputStream *)stream topLevelClass:(Class)class error:(NSError **)error {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:stream];
    AJRXMLUnarchiver *unarchiver = [[AJRXMLUnarchiver alloc] initWithParser:parser topLevelClass:class];
    
    return [unarchiver unarchivedObjectWithError:error];
}

+ (nullable id)unarchivedObjectWithData:(NSData *)data topLevelClass:(Class)class error:(NSError **)error {
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:data];
    return [self unarchivedObjectWithStream:inputStream topLevelClass:class error:error];
}

+ (nullable id)unarchivedObjectWithURL:(NSURL *)url topLevelClass:(nullable Class)class error:(NSError * _Nullable * _Nullable)error {
    NSInputStream *stream = [[NSInputStream alloc] initWithURL:url];
    NSError *localError = nil;
    AJRXMLUnarchiver *unarchiver = nil;

    if (stream) {
        unarchiver = [AJRXMLUnarchiver unarchivedObjectWithStream:stream topLevelClass:class error:&localError];
    } else {
        localError = [NSError errorWithDomain:AJRXMLDecodingErrorDomain format:@"Failed to open URL: %@: %s", url, strerror(errno)];
    }

    return AJRAssertOrPropagateError(unarchiver, error, localError);
}

+ (nullable id)unarchivedObjectWithStream:(NSInputStream *)stream error:(NSError **)error {
    return [self unarchivedObjectWithStream:stream topLevelClass:Nil error:error];
}

+ (nullable id)unarchivedObjectWithData:(NSData *)data error:(NSError **)error {
    return [self unarchivedObjectWithData:data topLevelClass:Nil error:error];
}

+ (nullable id)unarchivedObjectWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    return [self unarchivedObjectWithURL:url topLevelClass:nil error:error];
}

- (id)initWithParser:(NSXMLParser *)parser topLevelClass:(Class)class {
    if ((self = [super init])) {
        _parser = parser;
        _topLevelClass = class;
        _objectIDsToObjects = [NSMutableDictionary dictionary];
        _parser.delegate = self;
        _stack = [NSMutableArray array];
        _objectsByID = [NSMutableDictionary dictionary];
        _forwardObjectsByID = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - AJRXMLCoding

- (BOOL)callBlock:(void (^)(void))block catchingExceptionUsingError:(NSError **)error {
    NSError *localError = nil;
    @try {
        block();
    } @catch (NSException *localException) {
        localError = [NSError errorWithDomain:NSXMLParserErrorDomain format:@"Call to setter failed: %@", [localException description]];
        AJRLogError(@"Exception while calling setter block: %@\n%@\n", localException, [localException callStackSymbols]);
    }
    return AJRAssertOrPropagateError(localError == nil, error, localError);
}

- (void)finalizeDecodeWithBlock:(AJRXMLUnarchiverFinalizer)finalizer {
    [_stack lastObject].finalizer = finalizer;
}

- (nullable id)unarchivedObjectWithError:(NSError **)error {
    NSError *localError = nil;
    BOOL success = [_parser parse];

    // Let's see if we have any foward instantiations that were' handled
    if (_forwardObjectsByID.count > 0) {
        success = NO;
        localError = [NSError errorWithDomain:AJRXMLCodingErrorDomain format:@"Some objects that were forward declared were never instantiated. This happens when an archive writes out an object reference without later writing the actual object, and results in the corruption of the archive. The following object IDs were never instantiated: %@", [[_forwardObjectsByID allKeys] componentsJoinedByString:@", "]];
        _rootObject = nil;
    } else if (!success) {
        localError = [_parser parserError];
    }
    
    return AJRAssertOrPropagateError(_rootObject, error, localError);
}

- (void)decodeObjectForKey:(NSString *)key setter:(void (^)(id object))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        if (setter != NULL) {
            setter(rawValue);
        }
        return YES;
    } forKey:key];
}

- (void)decodeObjectUsingSetter:(void (^)(id object))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError **error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter(rawValue);
            }
        } catchingExceptionUsingError:error];
    } forKey:AJRXMLGenericKeySentinel];
}

- (void)decodeStringForKey:(NSString *)key setter:(void (^)(NSString *string))setter {
    [[_stack lastObject] setSetter:^BOOL(NSString *rawValue, NSError **error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter(rawValue);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeCStringForKey:(NSString *)key setter:(nullable void (^)(const char *string))setter {
    [[_stack lastObject] setSetter:^BOOL(NSString *rawValue, NSError **error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeBoolForKey:(NSString *)key setter:(void (^)(BOOL value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue boolValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeIntegerForKey:(NSString *)key setter:(void (^)(NSInteger value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue integerValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeIntForKey:(NSString *)key setter:(void (^)(int value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue intValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeInt32ForKey:(NSString *)key setter:(void (^)(int32_t value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue intValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeInt64ForKey:(NSString *)key setter:(void (^)(int64_t value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue longValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeUIntegerForKey:(NSString *)key setter:(void (^)(NSUInteger value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue unsignedIntegerValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeUIntForKey:(NSString *)key setter:(void (^)(unsigned int value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue unsignedIntValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeUInt32ForKey:(NSString *)key setter:(void (^)(uint32_t value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue unsignedIntValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeUInt64ForKey:(NSString *)key setter:(void (^)(uint64_t value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue unsignedLongValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeFloatForKey:(NSString *)key setter:(void (^)(float value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue floatValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeDoubleForKey:(NSString *)key setter:(void (^)(double value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue doubleValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeCGFloatForKey:(NSString *)key setter:(void (^)(CGFloat value))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter([rawValue doubleValue]);
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeBytesForKey:(NSString *)key setter:(void (^)(uint8_t *, NSUInteger length))setter {
    [[_stack lastObject] setSetter:^BOOL(NSString *rawValue, NSError **error) {
        NSError *localError = nil;
        BOOL success = YES;

        if (setter != NULL) {
            uint8_t *bytes;
            NSInteger length;
            localError = AJRBase64DecodedBytes(rawValue, &bytes, &length);
            if (localError == nil) {
                success = [self callBlock:^{
                    if (setter != NULL) {
                        setter(bytes, length);
                    }
                } catchingExceptionUsingError:error];
            } else {
                success = NO;
            }
        }
        
        return AJRAssertOrPropagateError(success, error, localError);
    } forKey:key];
}

- (void)decodeBytesUsingSetter:(void (^)(uint8_t *, NSUInteger length))setter {
    [self decodeBytesForKey:AJRXMLTextKeySentinel setter:setter];
}

- (void)decodeGroupForKey:(NSString *)key usingBlock:(void (^)(void))block setter:(void (^)(void))setter {
    [_stack.lastObject setGroupDecoder:block forKey:key];
    [_stack.lastObject setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter();
            }
        } catchingExceptionUsingError:error];
    } forKey:key];
}

- (void)decodeTextUsingSetter:(void (^)(NSString *))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError *__autoreleasing *error) {
        return [self callBlock:^{
            if (setter != NULL) {
                setter(rawValue);
            }
        } catchingExceptionUsingError:error];
    } forKey:AJRXMLTextKeySentinel];
}

- (void)decodeRangeForKey:(NSString *)key setter:(void (^)(NSRange range))setter {
    __block NSRange range = { NSNotFound, 0 };

    [self decodeGroupForKey:key usingBlock:^{
        [self decodeUIntegerForKey:@"location" setter:^(NSUInteger value) { range.location = value; }];
        [self decodeUIntegerForKey:@"length" setter:^(NSUInteger value) { range.length = value; }];
    } setter:^{
        setter(range);
    }];
}

- (void)decodeURLForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError **error) {
        NSString *string = AJRObjectIfKindOfClass(rawValue, NSString);
        if (string != nil) {
            NSURL *url = [NSURL URLWithString:rawValue];
            if (url != nil) {
                return [self callBlock:^{
                    if (setter != NULL) {
                        setter(url);
                    }
                } catchingExceptionUsingError:error];
            }
        }
        NSError *localError = [NSError errorWithDomain:AJRXMLCodingErrorDomain format:@"Unable to decode value for URL: %@", rawValue];
        AJRSetOutParameter(error, localError);
        return NO;
    } forKey:key];
}

- (void)decodeURLBookmarkForKey:(NSString *)key setter:(nullable void (^)(NSURL *url))setter {
    [[_stack lastObject] setSetter:^BOOL(id rawValue, NSError **error) {
        // Maybe we have a bookmark...
        NSData *data = AJRObjectIfKindOfClass(rawValue, NSData);
        NSError *localError = nil;
        if (data != nil) {
#if defined(AJRFoundation_iOS)
            NSURLBookmarkResolutionOptions options = 0;
#else
            NSURLBookmarkResolutionOptions options = NSURLBookmarkResolutionWithSecurityScope;
#endif
            NSURL *url = [NSURL URLByResolvingBookmarkData:data options:options relativeToURL:nil bookmarkDataIsStale:NULL error:&localError];
            if (url != nil) {
                return [self callBlock:^{
                    if (setter != NULL) {
                        setter(url);
                    }
                } catchingExceptionUsingError:error];
            }
        }
        localError = [NSError errorWithDomain:AJRXMLCodingErrorDomain format:@"Unable to decode value for URL: %@", rawValue];
        AJRSetOutParameter(error, localError);
        return NO;
    } forKey:key];
}

#pragma mark - NSXMLParserDelegate

- (nullable Class)resolveClassForAttributeValue:(nullable NSString *)possibleClassName orElementName:(nullable NSString *)elementName error:(NSError * _Nullable * _Nullable)error {
    Class objectClass = Nil;
    NSError *localError = nil;

    if (possibleClassName != nil) {
        objectClass = NSClassFromString(possibleClassName);
        if (objectClass == nil) {
            localError = [NSError errorWithDomain:AJRXMLCodingErrorDomain format:@"Unknown class: \"%@\"", possibleClassName];
        }
    }
    if (objectClass == Nil) {
        objectClass = [self.class classForXMLName:elementName] ?: NSObject.class;
//        if (objectClass == Nil) {
//            localError = [NSError errorWithDomain:AJRXMLCodingErrorDomain format:@"No mapping from element name \"%@\" to a class.", elementName];
//        }
    }
    if (localError != nil) {
        AJRLog(nil, AJRLogLevelWarning, @"%@", localError.localizedDescription);
    }
    return AJRAssertOrPropagateError(objectClass, error, localError);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
    NSError *localError = nil; // An error we can use in various places below.

    // We'll do a real quick short circuit here.
    if ([elementName hasPrefix:@"nil:"]) {
        if (elementName.length > 4) {
            NSString *actualElementName = [elementName substringFromIndex:4];
            [_stack.lastObject setRawValue:[NSNull null] forKey:actualElementName];
            AJRXMLUnarchiverFrame *frame = [AJRXMLUnarchiverFrame frameWithKey:actualElementName object:nil];
            [_stack addObject:frame];
        }
        return;
    }

    // Otherwise, decode as usual.
    Class objectClass = Nil;
    NSString *objectID = attributeDict[@"ajr:id"];
    // If the element has the "ref" name space, it's an object reference.
    NSString *referenceID = [attributeDict objectForKey:@"ajr:ref"];
    id<AJRXMLCoding> object = nil;
    
    if (_stack.count == 0 && _topLevelClass != Nil) {
        objectClass = _topLevelClass;
    } else {
        objectClass = [self resolveClassForAttributeValue:attributeDict[@"ajr:class"] orElementName:elementName error:&localError];
    }
    if (objectClass == nil) {
        // We failed to find a class. There's no way we can unarchive in this situation, so abort.
        _error = localError;
        [parser abortParsing];
        return;
    }

    if (referenceID != nil) {
        // Now look up the object.
        object = _objectsByID[referenceID];
        if (object == nil && objectClass != Nil) {
            // This means we have a placeholder reference, so we need to instantiate the class for later initialization.
            object = [objectClass instantiateWithXMLCoder:self];
            _objectsByID[referenceID] = object;
            _forwardObjectsByID[referenceID] = object;
        } else if (object == nil) {
            // This means we had an unresolved reference, which generally means our archice is corrupt.
            _error = [NSError errorWithDomain:NSXMLParserErrorDomain format:@"Found an object reference \"%@\", but it does not point to a decoded object.", referenceID];
            [parser abortParsing];
            return;
        }
    } else if ([_stack.lastObject isGroupKey:elementName]) {
        object = [[AJRXMLDecoderGroup alloc] initWithGroupDecoders:_stack.lastObject.keysToGroupDecoders];
    } else {
        // See if we've forward instantiated the object
        object = _forwardObjectsByID[objectID];
        if (object == nil) {
            // Nope, so the object is new, so instantiate one.
            object = [objectClass instantiateWithXMLCoder:self];
            _objectsByID[objectID] = object;
        }
    }

    // Create a stack frame for the object. We do this whether or not it's a reference or a new object, because we'll deal with associated the object into it's place in the object graph in the close element code below.
    AJRXMLUnarchiverFrame *frame = [AJRXMLUnarchiverFrame frameWithKey:elementName object:object];
    // Mark the frame as being a reference object. This is important, because we'll use this flag to prevent "finalizing" the object, which can happen with self referential object graphs, which an object can contain an object which points back to the source object.
    frame.isReferenceObject = referenceID != nil;
    frame.objectID = objectID;
    // Add the frame to our stack.
    [_stack addObject:frame];

    // If the element isn't a reference, we have to decode it.
    if (referenceID == nil) {
        if (objectID != nil) {
            // Since we're now instantiating the object, let's remove it from the forward instantiations, should it be there.
            // NOTE: objectID can be nil for special XML nodes, like groups. For example, these are used for the "entry" node of an encoded dictionary.
            [_forwardObjectsByID removeObjectForKey:objectID];
        }

        // Call decodeWithXMLCoder. This allows the object to register all the "setter" handlers it'll need.
        if ([object respondsToSelector:@selector(decodeWithXMLCoder:)]) {
            [object decodeWithXMLCoder:self];
        } else {
            AJRLogWarning(@"No mapping from \"%@\" to a class that supports XML decoding.", elementName);
        }
        
        // If the object is the root object, it'll be at stack frame 0 with just one object on the stack. When this happens, we want to ignore attributes with the "xmlns" key, because those are added by the archiver to make the XML valid, but they're ignorable as far as the objects in the XML are concerned.
        BOOL isRootObject = _stack.count == 1;
        [attributeDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
            if (isRootObject && [key hasPrefix:@"xmlns:"]) {
                // Do nothing
            } else if ([key hasPrefix:@"ajr:"]) {
                // Do nothing
            } else {
                [frame setRawValue:value forKey:key];
            }
        }];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    AJRXMLUnarchiverFrame *frame = [_stack lastObject];
    NSError *localError = nil;
    id oldObject = frame.object;
    BOOL success = [frame finalizeWithError:&localError];
    if (oldObject != frame.object && frame.objectID != nil) {
        // This happens when a placeholder decoder is replaced with an actual object. When this happens, we need to update the object cache to the new object.
        _objectsByID[frame.objectID] = frame.object;
    }
    if (_warnOfUndecodedKeys && frame.unassociatedRawValues.count != 0) {
        AJRLog(AJRXMLDecodingLoggingDomain, AJRLogLevelWarning, @"Some XML keys were not decoded: %@", [frame.unassociatedRawValues.allKeys componentsJoinedByString:@", "]);
    }
    [_stack removeLastObject];

    if ([_stack.lastObject isGroupKey:elementName]) {
        AJRXMLUnarchiverSetterNode *node = [_stack.lastObject setterForKey:elementName];
        if (node) {
            node.setter(nil, NULL);
        }
    } else {
        if (_stack.count == 0) {
            // If we just emptied the stack, then we've just decoded our root object.
            _rootObject = frame.object;
        } else {
            // Otherwise, we'll give the current frame the opportunity to do something with the object we just decoded.
            [[_stack lastObject] setRawValue:frame.object forKey:frame.key];
        }
    }
    
    if (!success) {
        _error = localError;
        [parser abortParsing];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [[_stack lastObject] setRawValue:string forKey:AJRXMLTextKeySentinel];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (parseError.code != NSXMLParserDelegateAbortedParseError) {
        // When we abort the parse, we'll already have the error.
        _error = parseError;
    }
    AJRLog(AJRXMLCodingLogDomain, AJRLogLevelError, @"Error occurred while parsing XML: line: %d, column: %d: (%ld) %@", parser.lineNumber, parser.columnNumber, _error.code, _error.localizedDescription);
    [parser abortParsing];
}

@end
