/*
 AJRRuntime.m
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

#import "AJRRuntime.h"

#import "AJRAutoreleasedMemory.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"

@class _AJRRuntimeType;

static NSString *_AJRStringFromEncodedType(const char * const string, const char *possibleBlockOrFuntionName);
static objc_property_attribute_t *_AJRPropertyAttributeForType(const char * const type, objc_property_attribute_t *list, unsigned int count);
static NSString *_AJRStringFromEncodedType(const char * const string, const char *possibleBlockOrFuntionName);
static NSArray<_AJRRuntimeType *> *_AJRTypesFromEncodedTypes(char *encodedType);

@interface _AJRRuntimeType : NSObject

@property (nonatomic,assign) char *type;
@property (nonatomic,assign) NSInteger offset;

@end

@implementation _AJRRuntimeType

- (void)dealloc {
    if (_type) {
        free(_type);
    }
}

- (void)setType:(char *)type {
    if (_type) {
        free(_type);
    }
    _type = (char *)malloc((strlen(type) + 1) * sizeof(char));
    strcpy(_type, type);
}

- (NSString *)description {
    return AJRFormat(@"<%C: %p: type: %s, offset: %d>", self, self, _type, (int)_offset);
}

@end

void _AJRRunInternalTestsForUnitTesting(void) {
    // Misc tests on _AJRRuntimeType
    _AJRRuntimeType *testType = [[_AJRRuntimeType alloc] init];
    testType.offset = 16;
    testType.type = "*";
    testType.type = "^?";
    NSCAssert(strcmp(testType.type, "^?") == 0, @"setType: failed on _AJRRuntimeType");
    NSCAssert(testType.offset == 16, @"setOffset: failed on _AJRRuntimeType");
    NSCAssert([[testType description] hasSuffix:@"type: ^?, offset: 16>"], @"-[_AJRRuntimeType description] produced unexpected results.");
    
    // We'll want to update our code if this ever happens.
    // OK: This first one happened, as bool is now encoding to B, not c. Not sure when that happened. Anyways, this is OK, because in the AJRStringFromEncodingType() function, we check against @encode(BOOL) before @encode(uint8_t), so we're now actually doing to more right thing, as we'll output both BOOL and uint8_t, whereas we use to only output BOOL.
    //NSCAssert(strcmp(@encode(BOOL), @encode(int8_t)) == 0, @"BOOL and char don't seem to encode to the same thing anymore.");
    NSCAssert(strcmp(@encode(NSInteger), @encode(int64_t)) == 0, @"NSInteger and int64_t don't seem to encode to the same thing anymore.");
    NSCAssert(strcmp(@encode(NSUInteger), @encode(uint64_t)) == 0, @"NSUInteger and uint64_6 don't seem to encode to the same thing anymore.");
    
    // Make sure this failure case works.
    objc_property_t property = class_getProperty([NSObject class], "autoContentAccessingProxy");
    NSCAssert(property, @"Couldn't find NSObject's @property autoContentAccessingProxy");
    unsigned int count;
    objc_property_attribute_t *list = property_copyAttributeList(property, &count);
    NSCAssert(_AJRPropertyAttributeForType("Z", list, count) == NULL, @"Expected a failure, but didn't get it.");
    
    // Test decoding failure case, because we can't make it happy under normal circumstances
    NSCAssert([_AJRStringFromEncodedType("z", NULL) isEqualToString:@"unknown(z)"], @"We actually found an encoding type z?");
    
}

static NSArray<_AJRRuntimeType *> *_AJRTypesFromEncodedTypes(char *encodedType) {
    NSMutableArray<_AJRRuntimeType *> *types = [NSMutableArray array];
    NSInteger x = 0;
    NSInteger length = strlen(encodedType);
    
    while (x < length) {
        char tempType[strlen(encodedType) + 1];
        int tempTypeX = 0;

        // Gather up pointer types
        while (encodedType[x] == '^') {
            tempType[tempTypeX++] = encodedType[x++];
        }

        if (encodedType[x] == '(') {
            // Skip to closing paren
            NSInteger parenCount = 0;
            do {
                if (encodedType[x] == '(') {
                    parenCount++;
                } else if (encodedType[x] == ')') {
                    parenCount--;
                }
                tempType[tempTypeX++] = encodedType[x++];
                tempType[tempTypeX] = '\0';
            } while (parenCount != 0);
        } else if (encodedType[x] == '{') {
            // Skip to closing paren
            NSInteger braceCount = 0;
            do {
                if (encodedType[x] == '{') {
                    braceCount++;
                } else if (encodedType[x] == '}') {
                    braceCount--;
                }
                tempType[tempTypeX++] = encodedType[x++];
                tempType[tempTypeX] = '\0';
            } while (braceCount != 0);
        } else {
            tempType[tempTypeX++] = encodedType[x++];
            tempType[tempTypeX] = '\0';
        }
        
        // We should now be on a number.
        NSInteger tempOffset = 0;
        while (isdigit(encodedType[x])) {
            tempOffset *= 10;
            tempOffset += (encodedType[x++] - '0');
        }
        
        // We should now have a valid type and offset.
        _AJRRuntimeType *runtimeType = [[_AJRRuntimeType alloc] init];
        runtimeType.offset = tempOffset;
        runtimeType.type = tempType;
        [types addObject:runtimeType];
    }
    
    return types;
}

/*! Generally speaking, the first type is the return type, the second is "self", the third is _cmd, and the forths starts the actually method's parameters. */
static NSString *_AJRStringFromEncodedType(const char * const string, const char *possibleBlockOrFuntionName) {
    static NSDictionary *commonStructMapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commonStructMapping = @{
                                @"struct CGRect":@"CGRect",
                                @"struct CGSize":@"CGSize",
                                @"struct CGPoint":@"CGPoint",
                                @"struct _NSRange":@"NSRange",
                                @"struct _NSZone":@"NSZone",
                                };
    });
    
    if (strcmp(string, @encode(void)) == 0) {
        return @"void";
    } else if (strcmp(string, @encode(BOOL)) == 0) {
        return @"BOOL"; // Usuaully true, and we're going to ajrsume this, but technically, this is just "char", but those are way more uncommon than BOOL.
    } else if (strcmp(string, @encode(id)) == 0) {
        return @"id";
    } else if (strcmp(string, @encode(uint8_t)) == 0) {
        return @"unsigned char";
    } else if (strcmp(string, @encode(int16_t)) == 0) {
        return @"int16_t";
    } else if (strcmp(string, @encode(uint16_t)) == 0) {
        return @"uint16_t";
    } else if (strcmp(string, @encode(int32_t)) == 0) {
        return @"int32_t";
    } else if (strcmp(string, @encode(uint32_t)) == 0) {
        return @"uint32_t";
    } else if (strcmp(string, @encode(NSInteger)) == 0) {
        return @"NSInteger";
    } else if (strcmp(string, @encode(NSUInteger)) == 0) {
        return @"NSUInteger";
    } else if (strcmp(string, @encode(float)) == 0) {
        return @"float";
    } else if (strcmp(string, @encode(double)) == 0) {
        return @"double";
    } else if (strcmp(string, @encode(long double)) == 0) {
        return @"long double";
    } else if (strcmp(string, @encode(CGRect)) == 0) {
        return @"CGRect";
    } else if (strcmp(string, @encode(CGSize)) == 0) {
        return @"CGSize";
    } else if (strcmp(string, @encode(CGPoint)) == 0) {
        return @"CGPoint";
    } else if (strcmp(string, @encode(NSRange)) == 0) {
        return @"NSRange";
    } else if (strncmp(string, "{", 1) == 0 && strlen(string) > 1) { // Struct, but not one of the common ones we handle from above.
        char *equals = strchr(string + 1, '=');
        if (equals) {
            NSInteger sublength = equals - (string + 1);
            if (strlen(string) > sublength + 1) {
                char buffer[sublength + 1];
                strncpy(buffer, string + 1, sublength);
                buffer[sublength] = '\0';
                NSString *possibleStruct = AJRFormat(@"struct %s", buffer);
                return [commonStructMapping objectForKey:possibleStruct] ?: possibleStruct;
            }
        }
    } else if (strncmp(string, "(", 1) == 0) { // Union
        char *equals = strchr(string + 1, '=');
        if (equals) {
            NSInteger sublength = equals - (string + 1);
            if (strlen(string) > sublength + 1) {
                char buffer[sublength + 1];
                strncpy(buffer, string + 1, sublength);
                buffer[sublength] = '\0';
                return AJRFormat(@"union %s", buffer);
            }
        }
    } else if (strcmp(string, @encode(void (^)(BOOL))) == 0) {
        if (possibleBlockOrFuntionName) {
            return AJRFormat(@"... (^%s)(...)", possibleBlockOrFuntionName);
        }
        return @"... (^)(...)";
    } else if (strcmp(string, @encode(void (*)(BOOL))) == 0) {
        if (possibleBlockOrFuntionName) {
            return AJRFormat(@"... (*%s)(...)", possibleBlockOrFuntionName);
        }
        return @"... (*)(...)";
    } else if (strcmp(string, @encode(char *)) == 0) {
        return @"char *";
    } else if (strcmp(string, @encode(SEL)) == 0) {
        return @"SEL";
    } else if (strcmp(string, @encode(Class)) == 0) {
        return @"Class";
    } else if (strncmp(string, @encode(void *), 1) == 0) {
        // Using void * to detech any pointer type.
        if (strlen(string) > 1) {
            return AJRFormat(@"%@ *", AJRStringFromEncodedType(string + 1));
        }
        // Unknown pointer type, so fall through.
    } else if (strncmp(string, "@", 1) == 0 && strlen(string) > 2 && string[1] == '"') {
        // We have a named object, woo-hoo!
        char *closeQuote = strchr(string + 2, '"');
        NSInteger sublength = closeQuote - (string + 2);
        if (strlen(string) > sublength + 2) {
            char buffer[sublength + 1];
            strncpy(buffer, string + 2, sublength);
            buffer[sublength] = '\0';
            return AJRFormat(@"%s *", buffer);
        }
    }
    return AJRFormat(@"unknown(%s)", string);
}

NSString *AJRStringFromEncodedType(const char * const string) {
    return _AJRStringFromEncodedType(string, NULL);
}

static NSString *AJRAppendMethodToString(Method method, BOOL isClassMethod, NSMutableString *string) {
    NSArray *parts;
    
    [string appendString:isClassMethod ? @"+" : @"-"];
    [string appendString:@" ("];
    char * const returnType = method_copyReturnType(method);
    [string appendString:AJRStringFromEncodedType(returnType)];
    free(returnType);
    [string appendString:@")"];
    
    parts = [NSStringFromSelector(method_getName(method)) componentsSeparatedByString:@":"];
    int numberOfArguments = method_getNumberOfArguments(method);

    if (numberOfArguments == 2) { // Only self & _cmd
        // Append the first part of the selector, because that's always there.
        [string appendString:[parts firstObject]];
    } else {
        // Now let's look at parameters.
        for (NSInteger x = 2; x < numberOfArguments; x++) {
            NSString *part = [parts objectAtIndex:x - 2];
            if (x > 2) {
                [string appendString:@" "];
            }
            [string appendString:part];
            [string appendString:@":("];
            char *argType = method_copyArgumentType(method, (int)x);
            if (argType) {
                [string appendString:AJRStringFromEncodedType(argType)];
                free(argType);
            }
            [string appendString:@")"];
            [string appendFormat:@"arg%d", (int)x - 1];
        }
    }
    
    return string;
}

NSString *AJRStringFromMethod(Method method, BOOL isClassMethod) {
    return AJRAppendMethodToString(method, isClassMethod, [NSMutableString string]);
}

static NSString *AJRAppendMethodDescriptionToString(struct objc_method_description description, BOOL isClassMethod, BOOL isRequired, NSMutableString *string) {
    NSArray<_AJRRuntimeType *> *runtimeTypes = _AJRTypesFromEncodedTypes(description.types);
    _AJRRuntimeType *runtimeType;
    
    if (isClassMethod) {
        [string appendFormat:@"+ ("];
    } else {
        [string appendFormat:@"- ("];
    }
    runtimeType = [runtimeTypes firstObject];
    [string appendString:AJRStringFromEncodedType(runtimeType.type)];
    [string appendFormat:@")"];
    
    NSArray *parts = [NSStringFromSelector(description.name) componentsSeparatedByString:@":"];
    NSInteger numberOfArguments = [runtimeTypes count];
    
    if (numberOfArguments == 3) { // Only return type, self & _cmd
        // Append the first part of the selector, because that's always there.
        [string appendString:[parts firstObject]];
    } else {
        // Now let's look at parameters.
        for (NSInteger x = 3; x < numberOfArguments; x++) {
            _AJRRuntimeType *type = [runtimeTypes objectAtIndex:x];
            NSString *part = [parts objectAtIndex:x - 3];
            if (x > 3) {
                [string appendString:@" "];
            }
            [string appendString:part];
            [string appendString:@":("];
            [string appendString:AJRStringFromEncodedType(type.type)];
            [string appendString:@")"];
            [string appendFormat:@"arg%d", (int)x - 1];
        }
    }

    return string;
}

NSString *AJRStringFromMethodDescription(struct objc_method_description description, BOOL isClassMethod, BOOL isRequired) {
    return AJRAppendMethodDescriptionToString(description, isClassMethod, isRequired, [NSMutableString string]);
}

static objc_property_attribute_t *_AJRPropertyAttributeForType(const char * const type, objc_property_attribute_t *list, unsigned int count) {
    for (NSInteger x = 0; x < count; x++) {
        if (strcmp(type, list[x].name) == 0) {
            return &list[x];
        }
    }
    return NULL;
}

static NSString *_AJRStringFromPropertyAttribute(objc_property_attribute_t attribute) {
    if (strncmp(attribute.name, "T", 1) == 0 || strncmp(attribute.name, "V", 1) == 0) {
        return nil;
    }
    
    NSMutableString *string = [NSMutableString string];
    
    if (strncmp(attribute.name, "&", 1) == 0) {
        [string appendString:@"strong"];
    } else if (strncmp(attribute.name, "N", 1) == 0) {
        [string appendString:@"nonatomic"];
    } else if (strncmp(attribute.name, "W", 1) == 0) {
        [string appendString:@"weak"];
    } else if (strncmp(attribute.name, "C", 1) == 0) {
        [string appendString:@"copy"];
    } else if (strncmp(attribute.name, "R", 1) == 0) {
        [string appendString:@"readwrite"];
    } else if (strncmp(attribute.name, "G", 1) == 0) {
        [string appendString:@"getter="];
        [string appendFormat:@"%s", attribute.value];
    } else if (strncmp(attribute.name, "S", 1) == 0) {
        [string appendString:@"setter="];
        [string appendFormat:@"%s", attribute.value];
    }
    
    return string;
}

static NSString *AJRAppendPropertyToString(objc_property_t property, BOOL isClassProperty, NSMutableString *string) {
    unsigned int attributeCount;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);

    [string appendString:@"@property "];
    if (attributeCount > 2) {
        [string appendString:@"("];
        BOOL hasAppended = NO;
        for (NSInteger x = 0; x < attributeCount; x++) {
            NSString *value = _AJRStringFromPropertyAttribute(attributes[x]);
            if (value) {
                if (hasAppended) {
                    [string appendString:@","];
                }
                [string appendString:value];
                hasAppended = YES;
            }
        }
        [string appendString:@") "];
    }
    objc_property_attribute_t *attribute = _AJRPropertyAttributeForType("T", attributes, attributeCount);
    BOOL suppressName = NO;

    NSCAssert(attribute != NULL, @"We failed to find type attribute for property %s, which probably means your runtime is corrupt.", property_getName(property));
    [string appendString:_AJRStringFromEncodedType(attribute->value, property_getName(property))];
    if (strncmp(attribute->value, "@?", 2) == 0 || strncmp(attribute->value, "^?", 2) == 0) {
        suppressName = YES;
    }

    if (!suppressName) {
        [string appendString:@" "];
        [string appendFormat:@"%s", property_getName(property)];
    }

    free(attributes);
    
    return string;
}

NSString *AJRStringFromProperty(objc_property_t property, BOOL isClassProperty) {
    NSCAssert(property != nil, @"property may not be nil!");
    return AJRAppendPropertyToString(property, isClassProperty, [NSMutableString string]);
}

static NSString *AJRAppendVariableToString(Ivar variable, NSMutableString *string) {
    [string appendString:AJRStringFromEncodedType(ivar_getTypeEncoding(variable))];
    [string appendString:@" "];
    [string appendFormat:@"%s", ivar_getName(variable)];
    
    return string;
}

NSString *AJRStringFromVariable(Ivar variable) {
    NSCAssert(variable != nil, @"variable may not be nil!");
    return AJRAppendVariableToString(variable, [NSMutableString string]);
}

NSString *AJRStringFromProtocol(Protocol *protocol) {
    NSCAssert(protocol != nil, @"protocol may not be nil!");
    return [NSString stringWithUTF8String:protocol_getName(protocol)];
}

static BOOL _AJRVariableIsAlsoProperty(Ivar variable, Class class) {
    char const * const name = ivar_getName(variable);
    objc_property_t property = class_getProperty(class, name);
    if (property == nil && strlen(name) > 1 && name[0] == '_') {
        property = class_getProperty(class, name + 1); // Try ignoring leading '_'
    }
    return property != nil;
}

static BOOL _AJRMethodIsAlsoProperty(Method method, Class class) {
    objc_property_t property = NULL;
    char const * const name = sel_getName(method_getName(method));
    
    if (strncmp(name, "set", 3) == 0 && strlen(name) > 3) {
        char *pliableName = strdup(name + 3);
        if (isupper(pliableName[0])) {
            pliableName[0] = tolower(pliableName[0]);
        }
        if (pliableName[strlen(pliableName) - 1] == ':') {
            pliableName[strlen(pliableName) - 1] = '\0';
        }
        property = class_getProperty(class, pliableName);
        free(pliableName);
    } else {
        property = class_getProperty(class, name);
    }
    return property != nil;
}

NSString *AJRClassInterfaceFromClass(Class class) {
    NSMutableString *string = [NSMutableString string];
    
    [string appendString:@"@interface "];
    [string appendString:NSStringFromClass(class)];
    Class superclass = class_getSuperclass(class);
    if (superclass) {
        [string appendString:@" : "];
        [string appendString:NSStringFromClass(superclass)];
    }
    
    BOOL hadProtocol = NO;
    AJRProtocolEnumerator *protocolEnumerator = [AJRProtocolEnumerator protocolEnumeratorWithClass:class];
    Protocol *protocol;
    while ((protocol = [protocolEnumerator nextProtocol])) {
        if (!hadProtocol) {
            [string appendString:@" <"];
            hadProtocol = YES;
        } else {
            [string appendString:@", "];
        }
        [string appendString:AJRStringFromProtocol(protocol)];
    }
    if (hadProtocol) {
        [string appendString:@">"];
    }
    
    [string appendString:@"\n"];
    
    BOOL hadIvar = NO;
    AJRVariableEnumerator *variableEnumerator = [AJRVariableEnumerator variableEnumeratorWithClass:class];
    Ivar variable;
    while ((variable = [variableEnumerator nextVariable])) {
        if (!_AJRVariableIsAlsoProperty(variable, class)) {
            if (!hadIvar) {
                [string appendString:@"{\n"];
            }
            hadIvar = YES;
            [string appendString:@"    "];
            [string appendString:AJRStringFromVariable(variable)];
            [string appendString:@";\n"];
        }
    }
    if (hadIvar) {
        [string appendString:@"}\n"];
    }
    [string appendString:@"\n"];
    
    AJRPropertyEnumerator *propertyEnumerator = [AJRPropertyEnumerator propertyEnumeratorWithClass:class];
    objc_property_t property;
    BOOL hadProperty = NO;
    while ((property = [propertyEnumerator nextProperty])) {
        [string appendString:AJRStringFromProperty(property, [propertyEnumerator isClassProperty])];
        [string appendString:@"\n"];
        hadProperty = YES;
    }
    if (hadProperty) {
        [string appendString:@"\n"];
    }
    
    AJRMethodEnumerator *methodEnumerator = [AJRMethodEnumerator methodEnumeratorWithClass:class];
    Method method;
    BOOL hadMethod = NO;
    while ((method = [methodEnumerator nextMethod])) {
        if (!_AJRMethodIsAlsoProperty(method, class)) {
            [string appendString:AJRStringFromMethod(method, [methodEnumerator isClassMethod])];
            [string appendString:@";\n"];
            hadMethod = YES;
        }
    }
    if (hadMethod) {
        [string appendString:@"\n"];
    }
    
    [string appendString:@"@end\n"];
    
    return string;
}

NSString *AJRStringFromClassSansModule(Class class) {
    NSString *name = NSStringFromClass(class);
    NSRange range = [name rangeOfString:@"."];
    if (range.location != NSNotFound) {
        name = [name substringFromIndex:NSMaxRange(range)];
    }
    return name;
}

@implementation NSObject (SwiftToObjCExceptionHandling)

+ (BOOL)catchException:(void(^)(void))tryBlock error:(NSError * __autoreleasing *)error {
    BOOL succeeded = NO;
    NSError *localError;
    @try {
        tryBlock();
        succeeded = YES;
    } @catch (NSException *exception) {
        NSMutableDictionary *userInfo = [exception.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = exception.description;
        localError = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:userInfo];
    }
    return AJRAssertOrPropagateError(succeeded, error, localError);
}

+ (void)ajr_testMethodThatThrowsException {
    @throw [NSException exceptionWithName:@"Test" reason:@"Because we needed a reliable exception" userInfo:nil];
}

@end

const char *AJRPrimitiveMethodSignatureWithTypes(const char *firstEncodedType, ...) {
    va_list args;
    
    va_start(args, firstEncodedType);
    const char *encodedType = firstEncodedType;
    NSMutableData *data = [NSMutableData data];
    while (encodedType) {
        [data appendBytes:encodedType length:strlen(encodedType)];
        encodedType = va_arg(args, const char *);
    }
    va_end(args);
    
    char *buffer = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:data.length + 1];
    memcpy(buffer, data.bytes, data.length);
    buffer[data.length - 1] = '\0';
    return buffer;
}

#pragma mark - Method Swizzling & Implementations

static void _AJRRegisterMethod(IMP methodImp, Class class, const char *methodTypes, SEL selector) {
    class_addMethod(class, selector, methodImp, methodTypes);
}

IMP AJRRegisterInstanceMethodWithSelector(Class aClass, SEL oldSelector, SEL newSelector) {
    Method thisMethod;
    IMP oldImp = NULL;
    
    if ((thisMethod = class_getInstanceMethod(aClass, oldSelector))) {
        oldImp = method_getImplementation(thisMethod);
        _AJRRegisterMethod(oldImp, aClass, method_getTypeEncoding(thisMethod), newSelector);
    }
    
    return oldImp;
}

IMP AJRGetMethodImplementation(Class class, SEL selector) {
    Method method;
    
    if ((method = class_getInstanceMethod(class, selector)) != NULL) {
        return method_getImplementation(method);
    }
    
    return NULL;
}

IMP AJRGetMethodImplementationExcludingSuperclass(Class class, SEL selector) {
    AJRMethodEnumerator *enumerator = [AJRMethodEnumerator methodEnumeratorWithClass:class];
    enumerator.enumerateSuperclasses = NO;
    Method method;

    while ((method = [enumerator nextMethod])) {
        if (method_getName(method) == selector) {
            return method_getImplementation(method);
        }
    }

    return NULL;
}

IMP AJRReplaceMethodImplementation(Class aClass, SEL oldSelector, IMP newImp) {
    Method thisMethod;
    IMP oldImp = NULL;
    
    if ((thisMethod = class_getInstanceMethod(aClass, oldSelector))) {
        oldImp = method_getImplementation(thisMethod);
        
        // Replace the method in place
        method_setImplementation(thisMethod, newImp);
    }
    
    return oldImp;
}

IMP AJRReplaceMethodImplementationWithSelector(Class aClass, SEL oldSelector, SEL newSelector) {
    return AJRReplaceMethodImplementation(aClass, oldSelector, [aClass instanceMethodForSelector:newSelector]);
}

void AJRSwizzleMethods(Class originalClass, SEL originalSelector, Class replacementClass, SEL replacementSelector) {
    Method method1 = class_getInstanceMethod(originalClass, originalSelector);
    if (method1) {
        Method method2 = class_getInstanceMethod(replacementClass, replacementSelector);
        if (method2) {
            IMP imp1 = method_getImplementation(method1);
            IMP imp2 = method_getImplementation(method2);
            method_setImplementation(method1, imp2);
            method_setImplementation(method2, imp1);
        }
    } else {
        AJRLogWarning(@"Failed to Swizzle, as %C does not implement %S.", originalClass, originalSelector);
    }
}

void AJRSwizzleClassMethods(Class originalClass, SEL originalSelector, Class replacementClass, SEL replacementSelector) {
    Method method1 = class_getClassMethod(originalClass, originalSelector);
    if (method1) {
        Method method2 = class_getClassMethod(replacementClass, replacementSelector);
        IMP imp1 = method_getImplementation(method1);
        IMP imp2 = method_getImplementation(method2);
        method_setImplementation(method1, imp2);
        method_setImplementation(method2, imp1);
    }
}

BOOL AJRIsKindOfClass(Class class, Class baseClass) {
    Class superClass = class;
    
    while (superClass) {
        if (superClass == baseClass || object_getClass(superClass) == baseClass) {
            return YES;
        }
        superClass = class_getSuperclass(superClass);
    }
    return NO;
}

Class AJRClassFromString(NSString *className, NSBundle *bundle) {
    Class extensionClass = NSClassFromString(className);
    if (extensionClass == Nil && bundle != nil) {
        NSString *nameWithModule = AJRFormat(@"%@.%@", [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension], className);
        extensionClass = NSClassFromString(nameWithModule);
    }
    return extensionClass;
}

