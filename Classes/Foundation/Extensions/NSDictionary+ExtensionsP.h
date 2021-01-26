//
//  NSDictionary+ExtensionsP.h
//  AJRFoundation
//
//  Created by AJ Raftis on 9/30/19.
//

#ifndef NSDictionary_ExtensionsP_h
#define NSDictionary_ExtensionsP_h

#import <AJRFoundation/NSDictionary+Extensions.h>

@interface AJRDictionaryLoader : NSObject

@end


@interface AJRXMLDictionaryPlaceholder : NSObject <AJRXMLDecoding> {
    Class _finalClass;
    
    id __strong *_objects;
    id __strong *_keys;
    NSInteger _index;
    NSInteger _max;
    
    id _key;    // Current key being decoded.
}

- (id)initWithFinalClass:(Class)finalClass;

- (void)appendKey:(id)key andObject:(id)object;

@end

#endif /* NSDictionary_ExtensionsP_h */
