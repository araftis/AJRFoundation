//
//  NSThread-Extensions.m
//  AJRFoundation
//
//  Created by Alex Raftis on 4/28/09.
//  Copyright 2009 Apple, Inc.. All rights reserved.
//

#import "NSThread-Extensions.h"

static const NSString *managedObjectContextKey = @"managedObjectContext";

@implementation NSThread (Extensions)

- (NSString*)keyForEnvironment:(AJREnvironment*)environment
{
    return [NSString stringWithFormat:@"%p", environment];
}

- (NSManagedObjectContext *)managedObjectContextForEnvironment:(AJREnvironment*)env
{
    // Note: This method is inherently thread safe, because no two different threads would ever be
    // calling this method from different threads.

    NSDictionary    *environmentDictionary = [[self threadDictionary] objectForKey:[self keyForEnvironment:env]];

    NSManagedObjectContext    *context = [environmentDictionary objectForKey:managedObjectContextKey];
    
    if (context == nil) {
        /* TODO: Create the managed object context and set in on our threadDictionary here. */
    }
    
    return context;
}

- (void)setManagedObjectContext:(NSManagedObjectContext*)aContext forEnvironment:(AJREnvironment*)env
{

    // 7480581-Q&A: Exception raised on startup

    NSMutableDictionary    *environmentDictionary = [[self threadDictionary] objectForKey:[self keyForEnvironment:env]];

    if (environmentDictionary == nil) {

        environmentDictionary = [NSMutableDictionary dictionary];
                
        [[self threadDictionary] setObject:environmentDictionary forKey:[self keyForEnvironment:env]];
        
    } else {
                
        NSManagedObjectContext *oldContext = [environmentDictionary objectForKey:managedObjectContextKey];
        
        if (oldContext) {
            NSLog(@"NSThread-Extensions: Managed object context exists already.Old context: %@. New context: %@", oldContext, aContext);
        }
    }
    
    [environmentDictionary setObject:aContext forKey:managedObjectContextKey];
}

- (void)assignContextOnThreadForStore:(NSPersistentStoreCoordinator*)storeCoordinator forEnvironment:(AJREnvironment*)env
{
    if (!storeCoordinator) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Persistent store coordinator cannot be nil." userInfo:nil];
    }        
    
    NSManagedObjectContext *existingContext = [self managedObjectContextForEnvironment:env];
    if (existingContext) {
        return;
    }
    
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
    [newContext setPersistentStoreCoordinator:storeCoordinator];
    [newContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    [self setManagedObjectContext:newContext forEnvironment:env];
    [newContext release];
}

@end
