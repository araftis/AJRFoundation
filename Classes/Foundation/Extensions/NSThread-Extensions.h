/*!
 @header NSThread-Extensions.h

 @author Alex Raftis
 @updated 4/28/09.
 @copyright 2009 Apple, Inc.. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <CoreData/CoreData.h>

/*!
 @class NSThread_Extensions
 @abstract A brief about the class
 @discussion A long talk about the class.
 */

@class AJREnvironment;

@interface NSThread (Extensions)

- (NSManagedObjectContext *)managedObjectContextForEnvironment:(AJREnvironment*)env;
- (void)setManagedObjectContext:(NSManagedObjectContext*)aContext forEnvironment:(AJREnvironment*)env;
- (void)assignContextOnThreadForStore:(NSPersistentStoreCoordinator*)storeCoordinator forEnvironment:(AJREnvironment*)env;

@end
