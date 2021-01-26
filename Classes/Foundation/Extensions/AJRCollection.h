//
//  AJRCollection.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 4/27/18.
//

#import <Foundation/Foundation.h>

@protocol AJRCollection <NSObject, NSFastEnumeration>

- (NSUInteger)count;

- (BOOL)ajr_containsObject:(id)object;
- (void)ajr_enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id object, BOOL *stop))block;

- (id <AJRCollection>)ajr_collectionByUnioningWithCollection:(id <AJRCollection>)collection;
- (id <AJRCollection>)ajr_collectionByIntersectingWithCollection:(id <AJRCollection>)collection;

@end

@interface NSArray (AJRCollection) <AJRCollection>

@end

@interface NSSet (AJRCollection) <AJRCollection>

@end

@interface NSDictionary (AJRCollection) <AJRCollection>

@end
