//
//  AJRProtocolEnumerator.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/11/18.
//

#import "AJRProtocolEnumerator.h"

#import <objc/runtime.h>

@implementation AJRProtocolEnumerator {
    Protocol * __unsafe_unretained *_list;
    
    unsigned int _count;
    unsigned int _subindex;
}

+ (instancetype)protocolEnumeratorWithClass:(Class)class {
    return [[self alloc] initWithClass:class];
}

- (instancetype)initWithClass:(Class)aClass {
    if ((self = [super init])) {
        //AJRLogDebug(@"enumerate: %s (0x%x, 0x%x)\n", aClass->name, aClass->info, aClass->isa->info);
        _enumeratedClass = aClass;
        _count = 0;
        _subindex = 0;
        _list = class_copyProtocolList(_enumeratedClass, &_count);
    }
    return self;
}

- (void)dealloc {
    if (_list) {
        free(_list);
    }
}

- (id)nextObject {
    return [self nextProtocol];
}

- (Protocol *)nextProtocol {
    return _subindex < _count ? _list[_subindex++] : nil;
}

@end
