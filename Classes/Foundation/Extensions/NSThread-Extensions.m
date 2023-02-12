/*
 NSThread-Extensions.m
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
