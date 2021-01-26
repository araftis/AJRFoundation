//
//  NSBundle+Extensions.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 12/1/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Extensions)

/*!
 @method bundleWithName:
 @abstract Finds a bundle with the given file name.
 @discussion This method scans all known executable bundles in your application and returns a matching bundle, by name, if it matches. For example, you might have a bundle called Services.osm. In this case, if you passed in “Services” for `name` you’d get a bundle for Service.osm returns. Note that the first bundle found is returned, so if you have multiple bundles with the same “name”, but different extensions, you will not get both of them returned.
 @param name The name of the bundle to find.
 @return The found bundle, or nil if no bundle is found.
 */
+ (nullable NSBundle *)bundleWithName:(NSString *)name;

/*!
 @method pathForResource:ofType:
 @abstract Scans all bundles in the application looking for resource.
 @discussion This class method works much like the instance method, but rather than just looking in one bundle, it looks in all known bundles for the resource. Note that only one path is returned, so the first resource found will be returned and search order is indeterminate, so you may need to exhibit some care with your resource names if you wish to leverage this method.
 @param name The name of the resource
 @param type The resource's type, usually it's file extension. May be nil.
 @return The path to the found resource or nil if not found.
 */
+ (NSString *)pathForResource:(NSString *)name ofType:(nullable NSString *)type;

- (nullable NSData *)machOTextDataNamed:(NSString *)name;
- (nullable NSData *)machODataOfType:(NSString *)type named:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
