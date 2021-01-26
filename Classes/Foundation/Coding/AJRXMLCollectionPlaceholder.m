//
//  AJRXMLCollectionPlaceholder.m
//  AJRFoundation
//
//  Created by AJ Raftis on 10/29/19.
//

#import "AJRXMLCollectionPlaceholder.h"

#import "AJRXMLArchiver.h"

@implementation AJRXMLCollectionPlaceholder

- (id)initWithFinalClass:(Class)finalClass {
    if ((self = [super init])) {
        _finalClass = finalClass;
        _max = 16;
        _index = 0;
        _objects = (id __strong *)NSZoneCalloc(NULL, _max, sizeof(id));
    }
    return self;
}

- (void)dealloc {
    // Make sure these are freed. They usually are down in the finalizeXMLDecoding method, but if an error occurred, they could be sticking around.
    for (NSInteger x = 0; x < _index; x++) {
        _objects[x] = nil;
    }
    _index = 0;
    NSZoneFree(NULL, _objects);
}

- (void)appendObject:(id)object {
    if (_index >= _max) {
        NSInteger oldMax = _max;
        if (_max < 256) {
            _max = _max + _max;
        } else {
            _max += 128;
        }
        _objects = (id __strong *)NSZoneRealloc(NULL, _objects, _max * sizeof(id));
        // Make sure to zero these, or we're going to crash when ARC tries to release a random pointer.
        memset(_objects + oldMax, 0, sizeof(id) * (_max - oldMax));
    }
    _objects[_index] = object;
    _index += 1;
}

- (void)decodeWithXMLCoder:(AJRXMLCoder *)coder {
    [coder decodeObjectUsingSetter:^(id object) {
        [self appendObject:object];
    }];
}

- (id)finalizeXMLDecodingWithError:(NSError * _Nullable * _Nullable)error {
    NSSet *result = [[_finalClass alloc] initWithObjects:_objects count:_index];
    // For now, give up ownership of the objects immediately. This can help with tracking down bugs.
    for (NSInteger x = 0; x < _index; x++) {
        _objects[x] = nil;
    }
    _index = 0;
    return result;
}

@end
