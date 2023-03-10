/*
 AJRPropertyEnumerator.m
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

#import "AJRPropertyEnumerator.h"

#import "AJRFunctions.h"

#import <objc/runtime.h>

@implementation AJRPropertyEnumerator {
    Class _currentClass;
    
    objc_property_t *_list;

    unsigned int _count;
    unsigned int _subindex;
    BOOL _enumeratingClassMethods;
    
    objc_property_t _property;
    BOOL _hasParsed;
    NSString *_propertyName;
    BOOL _isCopy;
    BOOL _isReadOnly;
    BOOL _isWeak;
    BOOL _isStrong;
    BOOL _isNonatomic;
    BOOL _isDynamic;
    BOOL _isGarbageCollectable;
    char *_type;
    Class _propertyClass;
    SEL _propertySetter;
    SEL _propertyGetter;
}

+ (instancetype)propertyEnumeratorWithClass:(Class)enumeratedClass {
    return [[self alloc] initWithEnumeratorClass:enumeratedClass];
}

- (instancetype)initWithEnumeratorClass:(Class)enumeratedClass {
    if ((self = [super init])) {
        _enumeratedClass = enumeratedClass;
        
        _count = 0;
        _subindex = 0;
        _enumeratesSuperclasses = NO;
        _currentClass = _enumeratedClass;
        _enumeratingClassMethods = YES;
        _list = class_copyPropertyList(object_getClass(_enumeratedClass), &_count);
        
    }
    return self;
}

- (void)dealloc {
    [self _clearParsed];
}

- (id)nextObject {
    // Because we're an enumerator and we have to implement this.
    objc_property_t nextProperty = [self nextProperty];
    return nextProperty ? [NSValue valueWithPointer:nextProperty] : nil;
}

- (objc_property_t)nextProperty {
    [self _clearParsed];

    if (!_enumeratedClass) {
        return NULL;
    }
    
    while (_subindex >= _count) {
        _currentClass = class_getSuperclass(_currentClass);
        if (_currentClass == Nil || !_enumeratesSuperclasses) {
            if (_enumeratingClassMethods) {
                _currentClass = _enumeratedClass;
                _enumeratingClassMethods = NO;
            } else {
                _currentClass = Nil;
                _enumeratedClass = Nil;
                _count = 0;
                _subindex = 0;
                return NULL;
            }
        }
        _subindex = 0;
        if (_list) {
            free(_list);
            _list = NULL;
        }
        _list = class_copyPropertyList(_currentClass, &_count);

        return [self nextProperty];
    }
    
    _property = _list[_subindex];
    return _list[_subindex++];
}

- (void)_clearParsed {
    _hasParsed = NO;
    _property = NULL;
    _propertyName = nil;
    _isWeak = NO;
    _isReadOnly = NO;
    _isStrong = NO;
    _isCopy = NO;
    _isNonatomic = NO;
    _isDynamic = NO;
    _isGarbageCollectable = NO;
    if (_type) {
        free(_type);
        _type = nil;
    }
    _propertyClass = nil;
    _propertySetter = NULL;
    _propertyGetter = NULL;
}

// See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
- (void)_parseAttribute:(const char *)attribute {
    if (strncmp(attribute, "R", 1) == 0) {
        _isReadOnly = YES;
    } else if (strncmp(attribute, "C", 1) == 0) {
        _isCopy = YES;
    } else if (strncmp(attribute, "&", 1) == 0) {
        _isStrong = YES;
    } else if (strncmp(attribute, "N", 1) == 0) {
        _isNonatomic = YES;
    } else if (strncmp(attribute, "G", 1) == 0) {
        if (strlen(attribute) > 1) {
            _propertyGetter = sel_registerName(attribute + 1);
        }
    } else if (strncmp(attribute, "S", 1) == 0) {
        if (strlen(attribute) > 1) {
            _propertySetter = sel_registerName(attribute + 1);
        }
    } else if (strncmp(attribute, "D", 1) == 0) {
        _isDynamic = YES;
    } else if (strncmp(attribute, "W", 1) == 0) {
        _isWeak = YES;
    } else if (strncmp(attribute, "P", 1) == 0) {
        _isWeak = YES;
    } else if (strncmp(attribute, "T", 1) == 0) {
        size_t length = strlen(attribute);
        if (length >= 1) {
            //AJRPrintf(@"parse: (%ld): %s\n", (long)length, attribute);
            _type = (char *)malloc(sizeof(char) * (length + 1));
            strncpy(_type, attribute + 1, length);
            if (length > 3 && _type[0] == '@' && _type[1] == '"') {
                char className[length - 3];
                strncpy(className, _type + 2, length - 4);
                className[length - 4] = '\0';
                _propertyClass = objc_getClass(className);
            }
        }
    }
}

- (void)_parseAttributes {
    if (!_hasParsed && _property != NULL) {
        char buffer[1024];
        strncpy(buffer, property_getAttributes(_property), 1023);
        
        char *start = buffer;
        uint16_t index = 0;
        while (buffer[index] && index < 1024) {
            if (buffer[index] == ',') {
                buffer[index] = '\0';
                [self _parseAttribute:start];
                start = buffer + index + 1;
            }
            index++;
        }
        // Make sure to pick up the last one.
        if (strlen(start) > 0) {
            [self _parseAttribute:start];
        }
        
        // Make sure we've set the setter / getter properties
        if (_propertyGetter == nil) {
            _propertyGetter = sel_registerName(property_getName(_property));
        }
        if (!_isReadOnly && _propertySetter == nil) {
            const char *name = property_getName(_property);
            size_t length = strlen(name);
            char buffer[length + 5];
            buffer[length] = '\0';
            strncpy(buffer, "set", length + 4);
            strncat(buffer, name, length + 1);
            strncat(buffer, ":", 1);
            _propertySetter = sel_registerName(buffer);
        }
        
        _hasParsed = YES;
    }
}

- (NSString *)propertyName {
    if (_propertyName == nil && _property != NULL) {
        [self _parseAttributes];
        _propertyName = [NSString stringWithCString:property_getName(_property) encoding:NSUTF8StringEncoding];
    }
    return _propertyName;
}

- (BOOL)propertyIsReadOnly {
    [self _parseAttributes];
    return _isReadOnly;
}

- (BOOL)propertyIsCopy {
    [self _parseAttributes];
    return _isCopy;
}

- (BOOL)propertyIsStrong {
    [self _parseAttributes];
    return _isStrong;
}

- (BOOL)propertyIsWeak {
    [self _parseAttributes];
    return _isWeak;
}

- (BOOL)propertyIsClassProperty {
    return _enumeratingClassMethods;
}

- (BOOL)propertyIsNonatomic {
    [self _parseAttributes];
    return _isNonatomic;
}

- (BOOL)propertyIsGarbageCollectable {
    [self _parseAttributes];
    return _isGarbageCollectable;
}

- (NSString *)propertyType {
    [self _parseAttributes];
    return _type == NULL ? nil : [NSString stringWithCString:_type encoding:NSUTF8StringEncoding];
}

-  (Class)propertyClass {
    [self _parseAttributes];
    return _propertyClass;
}

- (SEL)propertySetter {
    [self _parseAttributes];
    return _propertySetter;
}

- (SEL)propertyGetter {
    [self _parseAttributes];
    return _propertyGetter;
}

@end
