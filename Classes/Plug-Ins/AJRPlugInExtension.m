/*
AJRPlugInExtension.m
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

#import "AJRPlugInExtension.h"

#import "AJRPlugInAttribute.h"
#import "AJRPlugInElement.h"

@implementation AJRPlugInExtension

+ (instancetype)extensionWithName:(NSString *)extensionName class:(Class)extensionClass properties:(NSDictionary<NSString *, id> *)properties owner:(AJRPlugInExtensionPoint *)extensionPoint {
    return [[self alloc] initWithName:extensionName class:extensionClass properties:properties owner:extensionPoint];
}

- (id)initWithName:(NSString *)extensionName class:(Class)extensionClass properties:(NSDictionary<NSString *, id> *)properties owner:(AJRPlugInExtensionPoint *)extensionPoint {
    if ((self = [super init])) {
        _name = extensionName;
        _extensionClass = extensionClass;
        _properties = [properties copy];
        _extensionPoint = extensionPoint;
    }
    return self;
}

- (id)valueForKey:(NSString *)propertyName {
    return [_extensionPoint propertyForName:propertyName] != nil ? [_properties valueForKey:propertyName] : [super valueForKey:propertyName];
}

@end
