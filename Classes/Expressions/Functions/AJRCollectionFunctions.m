
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
