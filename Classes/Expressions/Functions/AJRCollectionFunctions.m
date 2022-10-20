/*
AJRCollectionFunctions.m
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

#import "AJRCollectionFunctions.h"

#import "AJRCollection.h"
#import "AJRExpression.h"
#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRFunctionExpression.h"
#import "NSError+Extensions.h"
#import "NSNumber+Extensions.h"

@implementation AJRArrayFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    NSMutableArray *array = [NSMutableArray array];
    
    for (id argument in self.arguments) {
        id    value = [AJRExpression evaluateValue:argument withObject:object error:&localError];
        if (localError) {
            array = nil;
            break;
        }
        if (value == nil) {
            [array addObject:[NSNull null]];
        } else {
            [array addObject:value];
        }
    }
    
    return AJRAssertOrPropagateError(array, error, localError);
}

@end

@implementation AJRSetFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSMutableSet *set = [NSMutableSet set];
    NSError *localError;
    
    for (id argument in self.arguments) {
        id    value = [AJRExpression evaluateValue:argument withObject:object error:&localError];
        if (localError != nil) {
            set = nil;
            break;
        }
        if (value == nil) {
            [set addObject:[NSNull null]];
        } else {
            [set addObject:value];
        }
    }
    
    return AJRAssertOrPropagateError(set, error, localError);
}

@end

@implementation AJRDictionaryFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = nil;
    NSMutableDictionary    *dictionary = [NSMutableDictionary dictionary];
    NSInteger x, max = self.arguments.count;
    
    for (x = 0; x < max && localError == nil; x += 2) {
        id key = [AJRExpression evaluateValue:[self.arguments objectAtIndex:x + 0] withObject:object error:&localError];
        id value = localError == nil ? [AJRExpression evaluateValue:[self.arguments objectAtIndex:x + 1] withObject:object error:&localError] : nil;

        if (localError == nil) {
            if (value == nil) {
                [dictionary setObject:[NSNull null] forKey:key];
            } else {
                [dictionary setObject:value forKey:key];
            }
        } else {
            dictionary = nil;
        }
    }
    
    return AJRAssertOrPropagateError(dictionary, error, localError);
}

@end

@implementation AJRCountFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:1];
    id returnValue = nil;
    if (localError == nil) {
        id value = [self collectionAtIndex:0 withObject:object error:&localError];
        if (localError == nil) {
            returnValue = @([value count]);
        }
    }
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRContainsFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    NSError *localError = [self checkArgumentCount:2];
    id returnValue = nil;
    if (localError == nil) {
        id collection = [self collectionAtIndex:0 withObject:object error:&localError];
        id value = localError == nil ? [AJRExpression evaluateValue:[self.arguments objectAtIndex:1] withObject:object error:&localError] : nil;
        if (localError == nil) {
            returnValue = @([collection containsObject:value]);
        }
    }
    return AJRAssertOrPropagateError(returnValue, error, localError);
}

@end

@implementation AJRIterateFunction

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
    __block NSError *localError = [self checkArgumentCount:2];
    id <AJRCollection> collection;
    __block id newCollection;
    AJRFunctionExpression *functionExpression;
    AJRFunction *function;
    
    if (localError == nil) {
        collection = [self collectionAtIndex:0 withObject:object error:&localError];
        if (localError == nil) {
            functionExpression = AJRObjectIfKindOfClass([self.arguments objectAtIndex:1], AJRFunctionExpression);
            if (functionExpression == nil) {
                localError = [NSError errorWithDomain:AJRExpressionErrorDomain format:@"Invalid argument to function \"%@\": %@. Expected a function.", [[self class] name], [self.arguments objectAtIndex:1]];
            }
            
            if (localError == nil) {
                if ([collection isKindOfClass:[NSArray class]]) {
                    newCollection = [NSMutableArray array];
                } else {
                    newCollection = [NSMutableSet set];
                }
                
                function = [functionExpression function];
                [collection ajr_enumerateObjectsUsingBlock:^(id argument, BOOL *stop) {
                    id    result;
                    
                    [function setArguments:[NSArray arrayWithObject:argument]];
                    
                    result = [function evaluateWithObject:object error:&localError];
                    if (localError) {
                        newCollection = nil;
                        *stop = YES;
                    } else {
                        if (result) {
                            [newCollection addObject:result];
                        } else {
                            [newCollection addObject:[NSNull null]];
                        }
                    }
                }];
            }
        }
    }
    
    return AJRAssertOrPropagateError(newCollection, error, localError);
}

@end
