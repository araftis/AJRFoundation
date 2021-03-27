
#import "AJRProtocolPropertyEnumerator.h"

@implementation AJRProtocolPropertyEnumerator
{
    objc_property_t *_list;
    
    unsigned int _count;
    unsigned int _index;
    
    BOOL _enumeratingRequired;
    BOOL _enumeratingClassProperties;
}

+ (id)propertyEnumeratorWithProtocol:(Protocol *)enumeratedProtocol {
    return [[self alloc] initWithProtocol:enumeratedProtocol];
}

- (id)initWithProtocol:(Protocol *)protocol {
    if ((self = [super init])) {
        _enumeratedProtocol = protocol;
        
        _enumeratingRequired = YES;
        _enumeratingClassProperties = YES;
        
        _list = protocol_copyPropertyList2(_enumeratedProtocol, &_count, _enumeratingRequired, _enumeratingClassProperties);
    }
    return self;
}

- (id)nextObject {
    objc_property_t next = [self nextProperty];
    return next ? [NSValue valueWithPointer:next] : nil;
}

- (objc_property_t)nextProperty {
    if (_enumeratedProtocol == nil) {
        return nil;
    }
    
    if (_index >= _count || _list == NULL) { // _list == NULL happens when a protcol has no required or class properties.
        _index = 0;
        if (_enumeratingRequired && _enumeratingClassProperties) {
            _enumeratingRequired = YES;
            _enumeratingClassProperties = NO;
        } else if (_enumeratingRequired && !_enumeratingClassProperties) {
            _enumeratingRequired = NO;
            _enumeratingClassProperties = YES;
        } else if (!_enumeratingRequired && _enumeratingClassProperties) {
            _enumeratingClassProperties = NO;
            _enumeratingRequired = NO;
        } else {
            _enumeratedProtocol = nil;
            _count = 0;
        }
        
        if (_enumeratedProtocol) {
            _list = protocol_copyPropertyList2(_enumeratedProtocol, &_count, _enumeratingRequired, _enumeratingClassProperties);
        }
        
        return [self nextProperty];
    }
    
    return _list[_index++];
}

@end
